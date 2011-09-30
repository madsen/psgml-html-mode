PSGML for HTML
==============

[PSGML](http://www.lysator.liu.se/~lenst/about_psgml/) is a GNU Emacs Major Mode for editing SGML and XML coded documents. This is a collection of DTDs and Emacs Lisp code to help set up PSGML for editing HTML files (including preliminary support for HTML 5).

You can download this code using `git clone` or just get a [tarball](https://github.com/madsen/psgml-html/tarball/master).

You'll also need to download PSGML from <http://sourceforge.net/projects/psgml/>. Currently, I'm using PSGML 1.2.5 and GNU Emacs 23.2.

First, copy everything from the `dtds` directory to `/usr/local/share/sgml`.  (That is, `dtds/CATALOG` should become `/usr/local/share/sgml/CATALOG`.) You can use a different directory if you prefer; just set `psgml-base-directory` in your `.emacs`.

Second, install PSGML according to its instructions.

Finally, install `psgml-html.el` in a directory where Emacs can find it, and put this in your `.emacs`:

```lisp
(autoload 'psgml-html-mode "psgml-html"
  "Derived major mode for editing HTML with PSGML (see `sgml-mode')." t)
(add-to-list 'auto-mode-alist
             '("\\.s?html?\\(\\.[a-zA-Z_]+\\)?\\'" . psgml-html-mode))

;; This is not required, but I recommend it, or you'll get annoying
;; comments like <!-- one of (...) --> when you insert certain elements.
(setq sgml-insert-missing-element-comment nil)
```


HTML 5 Support
==============

`psgml-html-mode` has preliminary support for HTML 5.  PSGML needs a
DTD to describe the elements and attributes that can appear in a
document.  This causes two problems with HTML 5 and PSGML.

PSGML finds the DTD based on a DOCTYPE declaration in the
document.  But PSGML doesn't recognize the HTML 5 declaration
(`<!DOCTYPE html>`).  `psgml-html-mode` adds [advice](http://www.gnu.org/s/emacs/manual/html_node/elisp/Advising-Functions.html) to PSGML to
associate the HTML 5 doctype with `html5.dtd`.

The other problem is that there is no official HTML 5 DTD.  I just
copied `html4strict.dtd` to `html5.dtd`.  I'll be modifying the DTD to
incorporate HTML 5's changes as I have need for them.  Please feel
free to submit pull requests with improvements to the DTD.


Copyright and License
=====================

Copyright 2011 Christopher J. Madsen

This is free software; you can redistribute it and/or modify it under the terms of the [GNU General Public License](http://www.gnu.org/licenses/gpl.html) as published by the Free Software Foundation; either [version 2](http://www.gnu.org/licenses/gpl-2.0.html), or (at your option) any later version.
