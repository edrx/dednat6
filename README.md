This is the README.md file for dednat6.

Dednat6 is an extensible (semi-)preprocessor for LuaLaTeX that
understands diagrams in ASCII art.

The best introduction to Dednat6 is the TUGBoat article about it:

  http://angg.twu.net/LATEX/2018tugboat-rev1.pdf

The home page of Dednat6 is:

  http://angg.twu.net/dednat6.html

Dednat6 is not in CTAN yet.

Here is a way to download Dednat6 from git and test it:

    rm -Rfv /tmp/dednat6/
    cd      /tmp/
    git clone https://github.com/edrx/dednat6
    cd      /tmp/dednat6/
    make
    make clean

The "make" will compile all its .tex files into PDFs; the "make clean"
will delete all the generated files except the PDFs. After doing
"make" and "make clean" open the file demo-minimal.tex, read its
instructions and try to modify it and recompile it. See:

  http://angg.twu.net/dednat6/demo-minimal.tex.html

  Eduardo Ochs  
  eduardoochs@gmail.com  
  http://angg.twu.net/
