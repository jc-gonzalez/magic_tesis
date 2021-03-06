##################################################################
#
# makefile -- Makefile for processing Ph.D.Thesis
#
# $RCSfile$
# $Revision$
# $Author$ 
# $Date$
#
##################################################################
#

# NEEDS GNUMake !!!

THIS=$(shell pwd)

RUN=texis
RUNPDF=pdf$(RUN)

RUNBIB=bibtex

RUNIDX=makeindex

DVIPS=dvips

DOC=tesis
DOCPDF=pdf$(DOC)

OUTDVI=$(TESIS).dvi
OUTPDF=$(TESIS).pdf
OUTPS=$(TESIS).ps

COMMON_PATH=$(THIS)/common
SCRATCH_PATH=$(THIS)/scratch
FIGS_PATH=$(THIS)/figs
ENG_PATH=$(THIS)/eng
ESP_PATH=$(THIS)/esp

ADD_TEXINPUTS_ENG=$(THIS):$(COMMON_PATH):$(FIGS_PATH):$(ENG_PATH)
ADD_TEXINPUTS_ESP=$(THIS):$(COMMON_PATH):$(FIGS_PATH):$(ESP_PATH)

LOGFILE=$(SCRATCH_PATH)/$(DOC).out
WRNFILE=$(SCRATCH_PATH)/warning
FULFILE=$(SCRATCH_PATH)/overfuls
LSTFILE=$(SCRATCH_PATH)/filelist
MEMFILE=$(SCRATCH_PATH)/memory

ANALYZELOG=$(COMMON_PATH)/log.awk

NOTATIONLST=$(COMMON_PATH)/notation.lst
NOTATIONAWK=$(COMMON_PATH)/notation.awk
NOTATIONTBL=$(COMMON_PATH)/notation.tbl

DOCSRC=$(COMMON_PATH)/$(DOC).tex
BIBSRC=$(COMMON_PATH)/jc.bst
BIBLIO=$(COMMON_PATH)/tesis.bib $(COMMON_PATH)/magic.bib
ENGINES=$(COMMON_PATH)/$(RUN) $(COMMON_PATH)/$(RUNPDF)
FORMATS1=$(COMMON_PATH)/$(RUN).fmt $(COMMON_PATH)/$(RUNPDF).fmt
FORMATS2=$(COMMON_PATH)/supp-mis.tex $(COMMON_PATH)/supp-pdf.tex 
FORMATS=$(FORMATS1) $(FORMATS2)

COMMON_FILES=$(DOCSRC) $(BIBSRC) $(BIBLIO) $(ENGINES) $(FORMATS)

.PHONY: eng esp ps pdf dvi all prepare banner log notation
.PHONY: lastday last5days last10days
.PHONY: clean mrproper redo
.PHONY: clearlang lang 
.PHONY: engpdf pdfeng esppdf pdfesp
.PHONY: engps pseng espps psesp
.PHONY: draft nodraft color bw virtex 
.PHONY: common $(COMMON_FILES)
.PHONY: $(OUTDVI) $(OUTPDF) $(OUTPS)

#----------------------------------------------------------------------

engpdf pdfeng: eng pdf

esppdf pdfesp: esp pdf

engps pseng: eng ps

espps psesp: esp ps

esp eng ::
	echo $@ > .$@
	echo $@ > .lang

ps pdf::
	echo $@ > .$@
	echo $@ > .fmt

ps:: dvi $(OUTPS) clearlang

dvi: prepare $(OUTDVI) log clearlang

pdf:: prepare $(OUTPDF) log clearlang

prepare: banner common lang notation

draft:
	-echo Next version generated will be a DRAFT version . . .
	cd $(COMMON_PATH);\
	echo '\newif\ifdraft \drafttrue' > $(COMMON_PATH)/isdraft.tex

nodraft:
	-echo Next version generated will be a NO DRAFT version . . .
	cd $(COMMON_PATH);\
	echo '\newif\ifdraft \draftfalse' > $(COMMON_PATH)/isdraft.tex

color:
	-echo "Next version generated will use COLOR pictures . . ."
	cd $(COMMON_PATH);\
	echo '\COLORversiontrue ' > $(COMMON_PATH)/iscolor.tex

bw:
	-echo "Next version generated will use Black & White pictures . . ."
	cd $(COMMON_PATH);\
	echo '\COLORversionfalse ' > $(COMMON_PATH)/iscolor.tex

virtex: 
	-echo Preprocessing TeXis code . . .
	cd $(COMMON_PATH);\
	cp $(COMMON_PATH)/$(RUN).tex $(COMMON_PATH)/$(RUNPDF).tex;\
	initex '&latex '$(COMMON_PATH)/$(RUN).tex' \dump' && \
	pdfinitex '&pdflatex '$(COMMON_PATH)/$(RUNPDF).tex' \dump';\
	ln -sf `which virtex` $(COMMON_PATH)/$(RUN) && \
	ln -sf `which pdfvirtex` $(COMMON_PATH)/$(RUNPDF)

all: virtex clean eng ps clean eng pdf 

common: $(COMMON_FILES)
	if [ -f $(THIS)/.esp ]; then \
	  ln -sf $(SCRATCH_PATH)/$(DOC).tex $(SCRATCH_PATH)/$(DOC)-esp.tex;\
	else \
	  ln -sf $(SCRATCH_PATH)/$(DOC).tex $(SCRATCH_PATH)/$(DOC)-eng.tex;\
	fi

$(COMMON_FILES):
	@echo Making symbolic link for $@ . . .
	@ln -sf $@ $(SCRATCH_PATH)/

lang:
	if [ -f $(THIS)/.ps ]; then \
	  echo "%% TESIS version PostScript" > language.tex;\
	else \
	  echo "%% TESIS version PDF" > language.tex;\
	fi
	echo "\newif\ifenglish" >> language.tex
	if [ -f $(THIS)/.eng ]; then \
	  echo "\englishtrue" >> language.tex;\
	else \
	  echo "\englishfalse" >> language.tex;\
	fi
	( echo "\typeout{^^J===================================}";\
	echo "\ifenglish" ;\
	echo "\typeout{Compiling THESIS, English version...}";\
	echo "\else ";\
	echo "\typeout{Compilando TESIS, version Espa�ol...}";\
	echo "\fi";\
	echo "\typeout{===================================^^J}";\
	echo "\ifenglish ";\
	echo "\usepackage[english]{babel}";\
	echo "\else ";\
	echo "\usepackage[spanish,activeacute]{babel}";\
	echo "\fi";\
	echo "\endinput" ) >> language.tex

notation:
	if [ -f $(THIS)/.esp ]; then \
	  awk -v lang=esp -f $(NOTATIONAWK) $(NOTATIONLST) > $(NOTATIONTBL) ;\
	else \
	  awk -f $(NOTATIONAWK) $(NOTATIONLST) > $(NOTATIONTBL) ;\
	fi

log:
	-rm -f $(FULFILE)
	-rm -f $(LSTFILE)
	-rm -f $(WRNFILE)
	cd $(SCRATCH_PATH);\
	awk -f $(ANALYZELOG) $(LOGFILE);\
	if [ -f $(THIS)/.esp ]; then \
	  tail -30 $(DOC)-esp.log | grep "^ [0-9]" > $(MEMFILE);\
	else \
	  tail -30 $(DOC)-eng.log | grep "^ [0-9]" > $(MEMFILE);\
	fi; \
	cd -
	echo "";echo "#### Over/Underfuls ########################"
	cat $(FULFILE)
	echo "";echo "#### List of files #########################"
	cat $(LSTFILE)
	echo "";echo "#### Warnings ##############################"
	cat $(WRNFILE)

$(OUTDVI):
	if [ -f $(THIS)/.esp ];then \
	  TEXINPUTS=.:$(ADD_TEXINPUTS_ESP):$${TEXINPUTS};\
	else \
	  TEXINPUTS=.:$(ADD_TEXINPUTS_ENG):$${TEXINPUTS};\
	fi;\
	TEXPSHEADERS=$${TEXINPUTS};\
	export TEXINPUTS;\
	export TEXPSHEADERS;\
	cd $(SCRATCH_PATH);\
	for run in $(RUN) $(RUN) $(RUNBIB) $(RUNIDX) $(RUN); do \
	  if [ -f $(THIS)/.esp ]; then \
	    $$run $(DOC)-esp.tex 2>&1 | tee $(LOGFILE);\
	  else \
	    $$run $(DOC)-eng.tex 2>&1 | tee $(LOGFILE);\
	  fi; \
	done;\
	cd -;\
	if [ -f $(THIS)/.esp ]; then \
	  ln -sf {$(SCRATCH_PATH),$(THIS)}/$(DOC)-esp.dvi;\
	else \
	  ln -sf {$(SCRATCH_PATH),$(THIS)}/$(DOC)-eng.dvi;\
	fi

$(OUTPS): $(OUTDVI)
	cd $(FIGS_PATH); \
	if [ -f $(THIS)/.esp ]; then \
	  $(DVIPS) -o $(THIS)/$(DOC)-esp.{ps,dvi};\
	else \
	  $(DVIPS) -o $(THIS)/$(DOC)-eng.{ps,dvi};\
	fi; \
	cd -

$(OUTPDF):
	if [ -f $(THIS)/.esp ];then \
	  TEXINPUTS=.:$(ADD_TEXINPUTS_ESP):$${TEXINPUTS};\
	else \
	  TEXINPUTS=.:$(ADD_TEXINPUTS_ENG):$${TEXINPUTS};\
	fi;\
	TEXPSHEADERS=$${TEXINPUTS};\
	export TEXINPUTS;\
	export TEXPSHEADERS;\
	cd $(SCRATCH_PATH);\
	for run in $(RUNPDF) $(RUNPDF) $(RUNBIB) $(RUNIDX) $(RUNPDF); do \
	  if [ -f $(THIS)/.esp ]; then \
	    $$run $(DOC)-esp 2>&1 | tee $(LOGFILE);\
	  else \
	    $$run $(DOC)-eng 2>&1 | tee $(LOGFILE);\
	  fi; \
	done;\
	cd -;\
	if [ -f $(THIS)/.esp ]; then \
	  ln -sf {$(SCRATCH_PATH),$(THIS)}/$(DOC)-esp.pdf;\
	else \
	  ln -sf {$(SCRATCH_PATH),$(THIS)}/$(DOC)-eng.pdf;\
	fi

banner:
	@echo "----------------------------------------"
	@echo " Generating Ph.D.Thesis output" 
	@echo ""
	@echo " Language:      "`cat .lang`
	@echo " Output format: "`cat .fmt`
	@echo "----------------------------------------"

clearlang:
	cd $(THIS)
	-rm -rf .eng .esp .pdf .ps .lang .fmt language.tex

clean: clearlang
	@echo "Cleanning..."
	-rm -f FILES*
	-find $(SCRATCH_PATH)/ -type f -exec rm -rf {} \;

mrproper: clean
	@echo "Mr.Proper in action . . ."
	-find . -name "*~" -exec rm -f {} \;
	-rm -f $(THIS)/tesis-{eng,esp}.{ps,dvi,pdf}

redo: clean all

lastday:
	-echo Files modified in the last day are: > /dev/stderr
	-rm -f FILES
	-find . \( -type f -a -cmin -1440 \) | grep -v scratch | tee /tmp/FILES
	-mv /tmp/FILES .

last5days:
	-echo Files modified in the last day are: > /dev/stderr
	-rm -f /tmp/FILES
	-find . \( -type f -a -cmin -7200 \) | grep -v scratch | tee /tmp/FILES
	-mv /tmp/FILES .

last10days:
	-echo Files modified in the last day are: > /dev/stderr
	-rm -f /tmp/FILES
	-find . \( -type f -a -cmin -14400 \) | grep -v scratch | tee /tmp/FILES
	-mv /tmp/FILES .

help:
	-cat common/makefile.hlp

#EOF
