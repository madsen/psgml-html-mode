;;; psgml-html.el --- HTML helper for PSGML mode
;;
;; Copyright (C) 2011 Christopher J. Madsen
;;
;; Author: Christopher J. Madsen <cjm@cjmweb.net>
;; Created: 28 Jul 2011
;; Keywords: html
;;
;; This file is not part of GNU Emacs.
;;
;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;=========================================================================
;; Installation:
;;-------------------------------------------------------------------------
;;
;; After installing psgml-html.el in a directory where Emacs can find it,
;; put this in your .emacs:
;;
;;   (autoload 'psgml-html-mode "psgml-html"
;;     "Pseudo major mode for editing HTML with PSGML." t)
;;   (add-to-list 'auto-mode-alist
;;                '("\\.s?html?\\(\\.[a-zA-Z_]+\\)?\\'" . psgml-html-mode))
;;
;; You also need to set `psgml-base-directory' if you installed the DTD
;; files somewhere other than /usr/local/share/sgml.

(require 'psgml)

(defvar psgml-base-directory "/usr/local/share/sgml"
  "The directory where CATALOG, ECAT, and DTD files are located.")

(defvar psgml-html-inhibit-init nil
  "If non-nil, don't set `sgml-catalog-files' or `sgml-ecat-files'.")

(or psgml-html-inhibit-init
    (setq sgml-catalog-files (list (expand-file-name "CATALOG"
                                                     psgml-base-directory))
          sgml-ecat-files    (list (expand-file-name "ECAT"
                                                     psgml-base-directory))))
(defvar psgml-html-bold-face 'bold)
(defvar psgml-html-italic-face 'italic)

(defvar psgml-html-font-lock-keywords   ;Swiped from html-helper-mode 2.17
  (let (;; Titles and H1's, like function defs.
	;;   We allow for HTML 3.0 attributes, like `<h1 align=center>'.
	(tword "\\(h1\\|title\\)\\([ \t\n]+[^>]+\\)?")
	;; Names of tags to boldify.
	(bword "\\(b\\|h[2-4]\\|strong\\)\\([ \t\n]+[^>]+\\)?")
	;; Names of tags to italify.
	(iword "\\(address\\|cite\\|em\\|i\\|var\\)\\([ \t\n]+[^>]+\\)?")
	;; Regexp to match shortest sequence that surely isn't a bold end.
	;; We simplify a bit by extending "</strong>" to "</str.*".
	;; Do similarly for non-italic and non-title ends.
	(not-bend (concat "\\([^<]\\|<\\([^/]\\|/\\([^bhs]\\|"
			  "b[^>]\\|"
			  "h\\([^2-4]\\|[2-4][^>]\\)\\|"
			  "s\\([^t]\\|t[^r]\\)\\)\\)\\)"))
	(not-iend (concat "\\([^<]\\|<\\([^/]\\|/\\([^aceiv]\\|"
			  "a\\([^d]\\|d[^d]\\)\\|"
			  "c\\([^i]\\|i[^t]\\)\\|"
			  "e\\([^m]\\|m[^>]\\)\\|"
			  "i[^>]\\|"
			  "v\\([^a]\\|a[^r]\\)\\)\\)\\)"))
	(not-tend (concat "\\([^<]\\|<\\([^/]\\|/\\([^ht]\\|"
			  "h[^1]\\|t\\([^i]\\|i[^t]\\)\\)\\)\\)")))
    (list ; Avoid use of `keep', since XEmacs will treat it the same as `t'.
     ;; First fontify the text of a HREF anchor.  It may be overridden later.
     ;; Anchors in headings will be made bold, for instance.
     '("<a\\s-+href[^>]*>\\([^>]+\\)</a>"
       1 font-lock-reference-face t)
     ;; Tag pairs like <b>...</b> etc.
     ;; Cunning repeated fontification to handle common cases of overlap.
     ;; Bold complex --- possibly with arbitrary other non-bold stuff inside.
     (list (concat "<" bword ">\\(" not-bend "*\\)</\\1>")
	   3 'psgml-html-bold-face t)
     ;; Italic complex --- possibly with arbitrary non-italic kept inside.
     (list (concat "<" iword ">\\(" not-iend "*\\)</\\1>")
	   3 'psgml-html-italic-face t)
     ;; Bold simple --- first fontify bold regions with no tags inside.
     (list (concat "<" bword ">\\("  "[^<]"  "*\\)</\\1>")
	   3 'psgml-html-bold-face t)
     ;; Any tag, general rule, just after bold/italic stuff.
     '("\\(<[^>]*>\\)" 1 font-lock-type-face t)
     ;; Titles and level 1 headings (anchors do sometimes appear in h1's)
     (list (concat "<" tword ">\\(" not-tend "*\\)</\\1>")
	   3 'font-lock-function-name-face t)
     ;; Underline is rarely used. Only handle it when no tags inside.
     '("<u>\\([^<]*\\)</u>" 1 'underline t)
     ;; Forms, anchors & images (also fontify strings inside)
     '("\\(<\\(form\\|i\\(mg\\|nput\\)\\)\\>[^>]*>\\)"
       1 font-lock-variable-name-face t)
     '("</a>" 0 font-lock-keyword-face t)
     '("\\(<a\\b[^>]*>\\)" 1 font-lock-keyword-face t)
     '("=[ \t\n]*\\(\"[^\"]+\"\\)" 1 font-lock-string-face t)
     ;; Large-scale structure keywords (like "program" in Fortran).
     ;;   "<html>" "</html>" "<body>" "</body>" "<head>" "</head>" "</form>"
     '("</?\\(body\\|form\\|h\\(ead\\|tml\\)\\)>"
       0 font-lock-variable-name-face t)
     ;; HTML special characters
     '("&[^;\n]*;" 0 font-lock-string-face t)
     ;; SGML things like <!DOCTYPE ...> with possible <!ENTITY...> inside.
     '("\\(<![a-z]+\\>[^<>]*\\(<[^>]*>[^<>]*\\)*>\\)"
       1 font-lock-comment-face t)
     ;; Comments: <!-- ... -->. They traditionally override anything else.
     ;; It's complicated 'cause we won't allow "-->" inside a comment, and
     ;; font-lock colours the *longest* possible match of the regexp.
     '("\\(<!--\\([^-]\\|-[^-]\\|--[^>]\\)*-->\\)"
       1 font-lock-comment-face t)))
    "Additional expressions to highlight in PSGML HTML mode.")

;; menus for creating new documents
(defvar psgml-html-dtd-menu
  '(( "HTML 5"
      "<!DOCTYPE html>\n" )

    ( "HTML 4.01 Transitional"
      "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\"
        \"http://www.w3.org/TR/html4/loose.dtd\">\n" )

    ( "HTML 4.01 Strict"
      "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01//EN\"
        \"http://www.w3.org/TR/html4/strict.dtd\">\n" )

    ( "HTML 3.2"
      "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 3.2//EN\">\n" )

    ( "HTML 2.0"
      "<!DOCTYPE HTML PUBLIC \"-//IETF//DTD HTML//EN\">\n" )

    ( "HTML 2.0 Level 1"
      "<!DOCTYPE HTML PUBLIC \"-//IETF//DTD HTML 2.0 Level 1//EN\">\n" )

    ( "HTML 2.0 Strict"
      "<!DOCTYPE HTML PUBLIC \"-//IETF//DTD HTML 2.0 Strict//EN\">\n" )

    ( "HTML 2.0 Strict Level 1"
      "<!DOCTYPE HTML PUBLIC \"-//IETF//DTD HTML 2.0 Strict Level 1//EN\">\n" )
    ))

(or sgml-custom-dtd
    (setq sgml-custom-dtd psgml-html-dtd-menu))

(defadvice sgml-setup-doctype (before psgml-html5 activate)
  "Add a fake public id for HTML 5 so PSGML can find the DTD."
  (and (string= (ad-get-arg 0) "HTML")
       (null    (ad-get-arg 1))
       (ad-set-arg 1 (cons "-//PSGML//DTD HTML 5//EN"
                           (cons nil default-directory)))))

(defvar psgml-html-mode-hook nil
  "A hook or list of hooks to be run when entering psgml-html-mode")

;;;###autoload
(defun psgml-html-mode ()
  "Pseudo major mode for editing HTML with PSGML.
It's pseudo because it does not have its own keymap or other mode-specific
variables, except for a hook: `psgml-html-mode-hook'.  For everything else,
see `sgml-mode'."
  (interactive)
  (sgml-mode)
  (set (make-local-variable 'sentence-end-double-space)    nil)
  (set (make-local-variable 'sgml-always-quote-attributes) t)
  (set (make-local-variable 'sgml-default-doctype-name)    "HTML")
  (set (make-local-variable 'sgml-general-insert-case)    'lower)
  (set (make-local-variable 'sgml-declaration)
       (expand-file-name "html4.decl" psgml-base-directory))
  (set (make-local-variable 'font-lock-defaults)
       '(psgml-html-font-lock-keywords t t))
  (setq sgml-indent-step         nil
        sgml-minimize-attributes nil
        sgml-omittag             t)
  (or sgml-auto-activate-dtd
      (set (make-local-variable 'sgml-auto-activate-dtd) t))
  (run-hooks 'psgml-html-mode-hook))

;;; psgml-html.el ends here
