-- preamble6.lua: the preamble-ish TeX definitions for the .dnt file.
-- This file:
-- http://angg.twu.net/dednat6/dednat6/preamble6.lua
-- http://angg.twu.net/dednat6/dednat6/preamble6.lua.html
--         (find-angg "dednat6/dednat6/preamble6.lua")
--
-- See: (find-dn6 "preamble.lua")

-- «.preamble0»		(to "preamble0")
-- «.preamble1»		(to "preamble1")



-- «preamble0» (to ".preamble0")
-- LaTeX needs to run these commands BEFORE the "\begin{document}".
-- For some reason, doing "\directlua{output(preamble0)}" doesn't
-- work; the obvious workaround is to include them in the .tex file
-- explicitly.
preamble0 = [==[
\usepackage{proof}   % For derivation trees ("%:" lines)
\input diagxy        % For 2D diagrams ("%D" lines)
\xyoption{curve}     % For the ".curve=" feature in 2D diagrams
]==]


-- «preamble1» (to ".preamble1")
-- These commands can be run either before of after "\begin{document}".
-- Usage: "\directlua{output(preamble1)}".
-- See:   (find-LATEX "edrxdnt.tex" "diagxy")
--        (find-LATEX "edrx15.sty" "picture-cells")
preamble1 = [==[
% Dednat6's "preamble1":
%
\def\diagxyto{\ifnextchar/{\toop}{\toop/>/}}
\def\to     {\rightarrow}
%
\def\defded#1#2{\expandafter\def\csname ded-#1\endcsname{#2}}
\def\ifdedundefined#1{\expandafter\ifx\csname ded-#1\endcsname\relax}
\def\ded#1{\ifdedundefined{#1}
    \errmessage{UNDEFINED DEDUCTION: #1}
  \else
    \csname ded-#1\endcsname
  \fi
}
\def\defdiag#1#2{\expandafter\def\csname diag-#1\endcsname{\bfig#2\efig}}
\def\defdiagprep#1#2#3{\expandafter\def\csname diag-#1\endcsname{{#2\bfig#3\efig}}}
\def\ifdiagundefined#1{\expandafter\ifx\csname diag-#1\endcsname\relax}
\def\diag#1{\ifdiagundefined{#1}
    \errmessage{UNDEFINED DIAGRAM: #1}
  \else
    \csname diag-#1\endcsname
  \fi
}
%
\newlength{\celllower}
\newlength{\lcelllower}
\def\cellfont{}
\def\lcellfont{}
\def\cell #1{\lower\celllower\hbox to 0pt{\hss\cellfont${#1}$\hss}}
\def\lcell#1{\lower\celllower\hbox to 0pt   {\lcellfont${#1}$\hss}}
%
\def\expr#1{\directlua{output(tostring(#1))}}
\def\eval#1{\directlua{#1}}
\def\pu{\directlua{pu()}}
%
% End of preamble1.

]==]


-- Missing:
-- (find-LATEX "edrx15.sty" "savebox")
-- (find-dn6file "tests/proof.sty" "\\infer*" "many step deduction")
-- (find-dn6file "tests/proof.sty" "\\@IFnextchar *")
-- (find-dn6file "tests/proof.sty" "\\def\\DeduceSym")
-- (find-LATEXfile "2012minicats.tex" "\\def\\DeduceSym")



--[[
 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
dofile "preamble6.lua"
print(preamble1)

--]]


-- Local Variables:
-- coding: utf-8-unix
-- End:

