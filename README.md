eclipseword-mode
================

An Emacs minor mode for handling words (almost) like Eclipse does.

This mode considers the following in its word definition:
- camel case e.g. these|Are|Different|Words
- multiple upper-case characters e.g. THESE|are|DIFFERENT|words
- numbers e.g. these|Are|33|WORDS
- symbols e.g. these|((|are|))|words
- white space (different when going forward and backwards) e.g. these| are| words| forward       |these |are |words |backward
- end and beginning of a line


Usage
-----

To make the mode turn on automatically, put the following code in
your .emacs:
  (add-hook 'c-mode-common-hook
       (lambda () (subword-mode 1)))

Or instead add:
  (global-eclipseword-mode 1)
to automatically enable the mode for all buffers
