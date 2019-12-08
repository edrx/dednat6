# (find-es "dednat" "makefile")
# (find-es "make" "clean")
# (find-TH "dednat6" "testing:script")
# (find-node "(make)Automatic Variables" "'$*'")
# (find-node "(make)Substitution Refs")

SIMPLEPDFSTEMS= tugboat-rev2			\
	tug-slides				\
	demo-minimal				\
	demo-underbrace				\
	2018dednat6-extras			\
	extra-comparisons			\
	extra-features				\
	extra-modules

SUBDIRPDFSTEMS=	demo-write-dnt			\
	demo-preproc

STEMS= $(SIMPLEPDFSTEMS) $(SUBDIRPDFSTEMS)

all:	$(STEMS:%=%.pdf) $(SUBDIRPDFSTEMS:%=%.subdirpdf)

clean:	$(STEMS:%=%.clean)

veryclean: $(STEMS:%=%.veryclean)

%.clean:
	rm -Rfv $*.aux $*.log $*.out $*.toc $*.dnt $*-sngf.tex $*.fls $*/

%.veryclean:
	rm -Rfv $*.aux $*.log $*.out $*.toc $*.dnt $*-sngf.tex $*.fls $*/ $*.pdf

tugboat-rev2.pdf:
	lualatex -record tugboat-rev2.tex
	lualatex         tugboat-rev2.tex

tug-slides.pdf:
	lualatex -record tug-slides.tex

demo-minimal.pdf:
	lualatex -record demo-minimal.tex

demo-underbrace.pdf:
	lualatex -record demo-underbrace.tex

demo-write-dnt.pdf:
	lualatex -record demo-write-dnt.tex
	pdflatex         demo-write-dnt.tex

demo-write-single.pdf:
	lualatex -record demo-write-single.tex

demo-preproc.pdf:
	./dednat6load.lua -4 demo-preproc.tex
	pdflatex -record     demo-preproc.tex

2018dednat6-extras.pdf:
	lualatex -record 2018dednat6-extras.tex

extra-comparisons.pdf:
	lualatex -record extra-comparisons.tex
	lualatex -record extra-comparisons.tex

extra-features.pdf:
	lualatex -record extra-features.tex

extra-modules.pdf:
	lualatex -record extra-modules.tex

%.subdirpdf:
	mkdir -p $*/
	cp -v $*.tex $*/
	cp -v $*.dnt $*/
	cd $*/ && pdflatex $*.tex

%.subdirpdfsingle:
	mkdir -p $*/
	cp -v $*-sngf.tex $*/
	cd $*/ && pdflatex $*-sngf.tex

