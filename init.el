;; init.el ---                                      -*- lexical-binding: t; -*-

;; Copyright (C) 2019  trottar

;; Author: trottar <trottar@trottar-PC>
;; Keywords: 

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; 

;;; Code:

;; (require 'auto-complete)

;; Start org mode so we can use it for lisp files
(package-initialize)
(require 'org-bullets)
(add-hook 'org-mode-hook (lambda () (org-bullets-mode 1)))

;; How to make org mode into an init file and run it with this bootstrap
(org-babel-load-file (expand-file-name "~/.emacs.d/startinit.org"))

;; langtool file, Need to download from http://www.languagetool.org/
(require 'langtool)

;; Load other lisp files, pointless for now
;; (add-to-list 'load-path "~/.emacs.d/lisp-files")

(provide 'init)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(Custom-mode-hook (quote (ignore)))
 '(auto-insert-mode t)
 '(custom-buffer-done-kill nil)
 '(custom-enabled-themes (quote (misterioso)))
 '(electric-pair-inhibit-predicate (quote ignore))
 '(electric-pair-mode t)
 '(electric-pair-pairs (quote ((34 . 34))))
 '(electric-pair-text-pairs (quote ((34 . 34))))
 '(global-auto-revert-mode t)
 '(global-company-mode t)
 '(ido-enable-flex-matching t)
 '(ido-mode (quote both) nil (ido))
 '(inhibit-startup-screen t)
 '(menu-bar-mode nil)
 '(org-hide-macro-markers nil)
 '(org-highlight-latex-and-related (quote (latex)))
 '(org-latex-classes
   (quote
    (("beamer" "\\documentclass[presentation]{beamer}"
      ("\\section{%s}" . "\\section*{%s}")
      ("\\subsection{%s}" . "\\subsection*{%s}")
      ("\\subsubsection{%s}" . "\\subsubsection*{%s}")
      ("\\paragraph{%s}" . "\\paragraph*{%s}")
      ("\\subparagraph{%s}" . "\\subparagraph*{%s}"))
     ("list" "\\documentclass[11pt]{article}"
      ("\\heading{%s}" . "\\heading*{%s}")
      ("\\heading{%s}" . "\\heading*{%s}"))
     ("article" "\\documentclass[11pt]{article}"
      ("\\section{%s}" . "\\section*{%s}")
      ("\\subsection{%s}" . "\\subsection*{%s}")
      ("\\subsubsection{%s}" . "\\subsubsection*{%s}")
      ("\\paragraph{%s}" . "\\paragraph*{%s}")
      ("\\subparagraph{%s}" . "\\subparagraph*{%s}"))
     ("report" "\\documentclass[11pt]{report}"
      ("\\part{%s}" . "\\part*{%s}")
      ("\\chapter{%s}" . "\\chapter*{%s}")
      ("\\section{%s}" . "\\section*{%s}")
      ("\\subsection{%s}" . "\\subsection*{%s}")
      ("\\subsubsection{%s}" . "\\subsubsection*{%s}"))
     ("book" "\\documentclass[11pt]{book}"
      ("\\chapter{%s}" . "\\chapter*{%s}")
      ("\\section{%s}" . "\\section*{%s}")
      ("\\subsection{%s}" . "\\subsection*{%s}")
      ("\\subsubsection{%s}" . "\\subsubsection*{%s}")))))
 '(org-latex-default-class "list")
 '(org-latex-prefer-user-labels nil)
 '(org-latex-remove-logfiles t)
 '(org-level-color-stars-only nil)
 '(org-modules
   (quote
    (org-bbdb org-bibtex org-ctags org-docview org-gnus org-info org-irc org-mhe org-rmail org-w3m org-bullets)))
 '(org-pretty-entities t)
 '(org-startup-truncated nil)
 '(org-startup-with-latex-preview t)
 '(org-support-shift-select (quote always))
 '(package-archives
   (quote
    (("gnu" . "http://elpa.gnu.org/packages/")
     ("org" . "http://orgmode.org/elpa/")
     ("melpa" . "https://stable.melpa.org/packages/"))))
 '(package-selected-packages
   (quote
    (langtool ox-pandoc define-word all auto-correct guide-key org-redmine org-ref olivetti writeroom-mode writegood-mode auctex ox-json org-agenda-property visual-fill-column smooth-scroll orgtbl-show-header org-pdfview org-gcal org-edit-latex org-bullets org-beautify-theme literate-elisp latex-unicode-math-mode latex-math-preview latex-extra elpy common-lisp-snippets calfw-org avy autopair auto-yasnippet auctex-latexmk angular-snippets)))
 '(python-indent-guess-indent-offset nil)
 '(python-indent-offset 4)
 '(server-mode t)
 '(term-scroll-to-bottom-on-output t)
 '(tool-bar-mode nil)
 '(truncate-lines nil)
 '(truncate-partial-width-windows 80)
 '(uniquify-buffer-name-style (quote post-forward) nil (uniquify))
 '(word-wrap t)
 '(xterm-mouse-mode t))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:inherit nil :stipple nil :inverse-video nil :box nil :strike-through nil :overline nil :underline nil :slant normal :weight normal :height 113 :width normal :foundry "unknown" :family "DejaVu Sans Mono"))))
 '(company-scrollbar-bg ((t (:background "deep sky blue"))))
 '(company-scrollbar-fg ((t (:background "dark cyan"))))
 '(company-tooltip ((t (:background "cyan" :foreground "black"))))
 '(company-tooltip-selection ((t (:background "dim gray"))))
 '(custom-button ((t (:background "black" :foreground "white smoke" :box (:line-width 2 :color "black" :style released-button))))))
;;; init.el ends here
