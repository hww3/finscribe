#
# $Id: Makefile,v 1.1 2006-07-05 21:19:03 jnt Exp $
#
TEX=latex
DVIPS=dvips
DVIPDF=dvipdf
DVIPDFOPTS=-dCompatibilityLevel=1.4

.PHONY: clean

%.pdf : %.dvi
	$(DVIPDF) $(DVIPDFOPTS) $<

%.ps : %.dvi
	$(DVIPS) $<

EXTRA_CLEAN=xesn_stamp

DESIGN_DEPS=xesn.tex

all: xesn.pdf

xesn.pdf: xesn_stamp

xesn.ps: xesn_stamp

xesn_stamp: xesn.dvi
	$(TEX) xesn.tex
	touch xesn_stamp

xesn.dvi: $(DESIGN_DEPS)

clean: 
	echo Cleaning crap
	-rm -f $(EXTRA_CLEAN)
	-rm -f *.aux *.log *.lof *.toc *.dvi *.out *~
