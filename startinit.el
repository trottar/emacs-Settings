(desktop-save-mode 1)

(setq org-agenda-files (quote ("/home/trottar/ResearchNP/org_file/google_calendar/google_calendar.org")))

(fset 'yes-or-no-p 'y-or-n-p)

(add-hook 'before-save-hook 'time-stamp)
(setq time-stamp-pattern nil)

;; packages
(when (>= emacs-major-version 24)
  (require 'package)
  (package-initialize)
  (add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
  )

(auto-insert-mode 1)

(add-hook 'find-file-hook 'auto-insert)
(defun auto-insert ()
  (interactive)
  (when (and 
         (string-match "\\.\\([C]\\|cc\\|cpp\\)\\'" (buffer-file-name))
         (eq 1 (point-max)))
    (insert-file "~/.emacs.d/insert/template.C"))
    (when (and 
         (string-match "\\.py" (buffer-file-name))
         (eq 1 (point-max)))
      (insert-file "~/.emacs.d/insert/template.py"))
    (when (and 
	   (string-match "\\.\\(sh\\|csh\\)\\'" (buffer-file-name))
	   (eq 1 (point-max)))
      (insert-file "~/.emacs.d/insert/template.sh"))
    (when (and 
	   (string-match "\\.org\\'" (buffer-file-name))
	   (eq 1 (point-max)))
      (insert-file "~/.emacs.d/insert/template.org")))

(setq  backup-directory-alist '(("." . "~/.backups"))
 backup-by-copying t
 version-control t
 delete-old-versions t
 kept-new-versions 20
 kept-old-versions 5)

(defun comment-or-uncomment-region-or-line ()
  "Comments or uncomments the region or the current line if there's no active region."
  (interactive)
  (let (beg end)
    (if (region-active-p)
	(setq beg (region-beginning) end (region-end))
      (setq beg (line-beginning-position) end (line-end-position)))
    (comment-or-uncomment-region beg end)))

(global-set-key "\M-;" 'comment-or-uncomment-region-or-line)

(org-babel-do-load-languages
   'org-babel-load-languages
   '((R . t)
     (org . t)
     (ditaa . t)
     (latex . t)
     (dot . t)
     (emacs-lisp . t)
     (gnuplot . t)
     (screen . nil)
     (shell . t)
     (sql . nil)
     (sqlite . t)))

(setq abbrev-file-name "~/.emacs.d/abbrev_defs")
(setq-default abbrev-mode t)
(global-set-key [C-tab] 'abbrev-mode)

;; Add the path to the repo
(add-to-list 'load-path "~/Programs/wc-mode/")
(require 'wc-mode)
(global-set-key "\C-cw" 'wc-mode)

(setq org-indent-mode t)
(setq org-indent-indentation-per-level 2)

(when window-system
  (setq frame-title-format '(buffer-file-name "%f" ("%b")))
  (tooltip-mode -1)
  (tool-bar-mode -1)
  (blink-cursor-mode -1)
(scroll-bar-mode -1)



)


;; (tooltip-mode -1)
;; (tool-bar-mode -1)

(add-hook 'org-mode-hook
          (lambda()
            (hl-line-mode -1)
            (global-hl-line-mode -1))
          't
          )

(setq prelude-whitespace nil)

(global-visual-line-mode)

(setq package-check-signature nil)

;; (toggle-maxframe)
(require 'olivetti)
(setq default-frame-alist
      '(
	(width . 160) ; character
	(height . 42) ; lines
(cursor-color . "red") 
	))
;; (zenburn)
;; (monaco-font)
;; (minuscule-type)
;; (turn-on-olivetti-mode)

(recenter-top-bottom)
;; (deja-vu-font)

(require 'flyspell)
(flyspell-mode-on)

;; (defun add-word-to-personal-dictionary ()
;;   (interactive)
;;   (let ((current-location (point))
;;         (word (flyspell-get-word)))
;;     (when (consp word)
;;       (flyspell-do-correct 'save nil (car word) current-location (cadr word) (caddr word) current-location)))) 
;; find aspell and hunspell automatically


;; avoid spell-checking doublon (double word) in certain major modes
(defvar flyspell-check-doublon t
  "Check doublon (double word) when calling `flyspell-highlight-incorrect-region'.")
 (make-variable-buffer-local 'flyspell-check-doublon)

(eval-after-load 'flyspell
  '(progn
     ;; {{ flyspell setup for web-mode
     (defun web-mode-flyspell-verify ()
       (let* ((f (get-text-property (- (point) 1) 'face))
	      rlt)
	 (cond
	  ;; Check the words with these font faces, possibly.
	  ;; This *blacklist* will be tweaked in next condition
	  ((not (memq f '(web-mode-html-attr-value-face
			  web-mode-html-tag-face
			  web-mode-html-attr-name-face
			  web-mode-constant-face
			  web-mode-doctype-face
			  web-mode-keyword-face
			  web-mode-comment-face ;; focus on get html label right
			  web-mode-function-name-face
			  web-mode-variable-name-face
			  web-mode-css-property-name-face
			  web-mode-css-selector-face
			  web-mode-css-color-face
			  web-mode-type-face
			  web-mode-block-control-face)))
	   (setq rlt t))
	  ;; check attribute value under certain conditions
	  ((memq f '(web-mode-html-attr-value-face))
	   (save-excursion
	     (search-backward-regexp "=['\"]" (line-beginning-position) t)
	     (backward-char)
	     (setq rlt (string-match "^\\(value\\|class\\|ng[A-Za-z0-9-]*\\)$"
				     (thing-at-point 'symbol)))))
	  ;; finalize the blacklist
	  (t
	   (setq rlt nil)))
	 rlt))
     (put 'web-mode 'flyspell-mode-predicate 'web-mode-flyspell-verify)
     ;; }}

     ;; better performance
     (setq flyspell-issue-message-flag nil)

     ;; flyspell-lazy is outdated and conflicts with latest flyspell
     ;; It only improves the performance of flyspell so it's not essential.

     (defadvice flyspell-highlight-incorrect-region (around flyspell-highlight-incorrect-region-hack activate)
       (if (or flyspell-check-doublon (not (eq 'doublon (ad-get-arg 2))))
	   ad-do-it))))


;; The logic is:
;; If (aspell installed) { use aspell}
;; else if (hunspell installed) { use hunspell }
;; English dictionary is used.
;;
;; I prefer aspell because:
;; 1. aspell is older
;; 2. looks Kevin Atkinson still get some road map for aspell:
;; @see http://lists.gnu.org/archive/html/aspell-announce/2011-09/msg00000.html
(defun flyspell-detect-ispell-args (&optional run-together)
  "If RUN-TOGETHER is true, spell check the CamelCase words.
Please note RUN-TOGETHER will make aspell less capable. So it should only be used in prog-mode-hook."
  (let* (args)
    (when ispell-program-name
      (cond
       ;; use aspell
       ((string-match "aspell$" ispell-program-name)
	;; force the English dictionary, support Camel Case spelling check (tested with aspell 0.6)
	(setq args (list "--sug-mode=ultra" "--lang=en_US"))
	;; "--run-together-min" could not be 3, see `check` in "speller_impl.cpp".
	;; The algorithm is not precise.
	;; Run `echo tasteTableConfig | aspell --lang=en_US -C --run-together-limit=16  --encoding=utf-8 -a` in shell.
	(when run-together
	  (cond
	   ;; Kevin Atkinson said now aspell supports camel case directly
	   ;; https://github.com/redguardtoo/emacs.d/issues/796
	   ((string-match-p "--camel-case"
			    (shell-command-to-string (concat ispell-program-name " --help")))
	    (setq args (append args '("--camel-case"))))

	   ;; old aspell uses "--run-together". Please note we are not dependent on this option
	   ;; to check camel case word. wucuo is the final solution. This aspell options is just
	   ;; some extra check to speed up the whole process.
	   (t
	    (setq args (append args '("--run-together" "--run-together-limit=16")))))))

       ;; use hunsepll
       ((string-match "hunspell$" ispell-program-name)
	(setq args nil))))
    args))

;; Aspell Setup (recommended):
;; Skipped because it's easy.
;;
;; Hunspell Setup:
;; 1. Install hunspell from http://hunspell.sourceforge.net/
;; 2. Download openoffice dictionary extension from
;; http://extensions.openoffice.org/en/project/english-dictionaries-apache-openoffice
;; 3. That is download `dict-en.oxt'. Rename that to `dict-en.zip' and unzip
;; the contents to a temporary folder.
;; 4. Copy `en_US.dic' and `en_US.aff' files from there to a folder where you
;; save dictionary files; I saved it to `~/usr_local/share/hunspell/'
;; 5. Add that path to shell env variable `DICPATH':
;; setenv DICPATH $MYLOCAL/share/hunspell
;; 6. Restart emacs so that when hunspell is run by ispell/flyspell, that env
;; variable is effective.
;;
;; hunspell will search for a dictionary called `en_US' in the path specified by
;; `$DICPATH'

(defvar force-to-use-hunspell nil
  "If t, force to use hunspell.  Or else, search aspell at first and fall
back to hunspell if aspell is not found.")

(cond
 ;; use aspell
 ((and (not force-to-use-hunspell) (executable-find "aspell"))
  (setq ispell-program-name "aspell"))

 ;; use hunspell
 ((executable-find "hunspell")
  (setq ispell-program-name "hunspell")
  (setq ispell-local-dictionary "en_US")
  (setq ispell-local-dictionary-alist
	'(("en_US" "[[:alpha:]]" "[^[:alpha:]]" "[']" nil ("-d" "en_US") nil utf-8))))
 (t (setq ispell-program-name nil)
    (message "You need install either aspell or hunspell for ispell")))

;; `ispell-cmd-args' contains *extra* arguments appending to CLI process
;; when (ispell-send-string). Useless!
;; `ispell-extra-args' is *always* used when start CLI aspell process
(setq-default ispell-extra-args (flyspell-detect-ispell-args t))
;; (setq ispell-cmd-args (flyspell-detect-ispell-args))
(defadvice ispell-word (around my-ispell-word activate)
  (let* ((old-ispell-extra-args ispell-extra-args))
    (ispell-kill-ispell t)
    ;; use emacs original arguments
    (setq ispell-extra-args (flyspell-detect-ispell-args))
    ad-do-it
    ;; restore our own ispell arguments
    (setq ispell-extra-args old-ispell-extra-args)
    (ispell-kill-ispell t)))

(defadvice flyspell-auto-correct-word (around my-flyspell-auto-correct-word activate)
  (let* ((old-ispell-extra-args ispell-extra-args))
    (ispell-kill-ispell t)
    ;; use emacs original arguments
    (setq ispell-extra-args (flyspell-detect-ispell-args))
    ad-do-it
    ;; restore our own ispell arguments
    (setq ispell-extra-args old-ispell-extra-args)
    (ispell-kill-ispell t)))

(defun text-mode-hook-setup ()
  ;; Turn off RUN-TOGETHER option when spell check text-mode
  (setq-local ispell-extra-args (flyspell-detect-ispell-args)))
(add-hook 'text-mode-hook 'text-mode-hook-setup)

(defun enable-flyspell-mode-conditionally ()
  (when (and (not *no-memory*)
	     ispell-program-name
	     (executable-find ispell-program-name))
    ;; I don't use flyspell in text-mode because I often use Chinese.
    ;; I'd rather manually spell check the English text
    (flyspell-mode 1)))

;; You can also use "M-x ispell-word" or hotkey "M-$". It pop up a multiple choice
;; @see http://frequal.com/Perspectives/EmacsTip03-FlyspellAutoCorrectWord.html
(global-set-key (kbd "C-c s") 'flyspell-auto-correct-word)

(defun my-clean-aspell-dict ()
  "Clean ~/.aspell.pws (dictionary used by aspell)."
  (interactive)
  (let* ((dict (file-truename "~/.aspell.en.pws"))
	 (lines (read-lines dict))
	 ;; sort words
	 (aspell-words (sort (cdr lines) 'string<)))
    (with-temp-file dict
      (insert (format "%s %d\n%s"
			"personal_ws-1.1 en"
			(length aspell-words)
			(mapconcat 'identity aspell-words "\n"))))))

;; {{ langtool setup
(eval-after-load 'langtool
  '(progn
     (setq langtool-generic-check-predicate
	   '(lambda (start end)
	      ;; set up for `org-mode'
	      (let* ((begin-regexp "^[ \t]*#\\+begin_\\(src\\|html\\|latex\\|example\\|quote\\)")
		     (end-regexp "^[ \t]*#\\+end_\\(src\\|html\\|latex\\|example\\|quote\\)")
		     (case-fold-search t)
		     (ignored-font-faces '(org-verbatim
					   org-block-begin-line
					   org-meta-line
					   org-tag
					   org-link
					   org-table
					   org-level-1
					   org-document-info))
		     (rlt t)
		     ff
		     th
		     b e)
		(save-excursion
		  (goto-char start)

		  ;; get current font face
		  (setq ff (get-text-property start 'face))
		  (if (listp ff) (setq ff (car ff)))

		  ;; ignore certain errors by set rlt to nil
		  (cond
		   ((memq ff ignored-font-faces)
		    ;; check current font face
		    (setq rlt nil))
		   ((or (string-match "^ *- $" (buffer-substring (line-beginning-position) (+ start 2)))
			(string-match "^ *- $" (buffer-substring (line-beginning-position) (+ end 2))))
		    ;; dash character of " - list item 1"
		    (setq rlt nil))

		   ((and (setq th (thing-at-point 'evil-WORD))
			 (or (string-match "^=[^=]*=[,.]?$" th)
			     (string-match "^\\[\\[" th)
			     (string-match "^=(" th)
			     (string-match ")=$" th)
			     (string= "w3m" th)))
		    ;; embedded cde like =w3m= or org-link [[http://google.com][google]] or [[www.google.com]]
		    ;; langtool could finish checking before major mode prepare font face for all texts
		    (setq rlt nil))
		   (t
		    ;; inside source block?
		    (setq b (re-search-backward begin-regexp nil t))
		    (if b (setq e (re-search-forward end-regexp nil t)))
		    (if (and b e (< start e)) (setq rlt nil)))))
		;; (if rlt (message "start=%s end=%s ff=%s" start end ff))
		rlt)))))
;; }}

(eval-after-load 'wucuo
  '(progn
     ;; do NOT turn on flyspell-mode automatically when running `wucuo-start'
     (setq wucuo-auto-turn-on-flyspell nil)))

(provide 'init-spelling)

(eval-when-compile
  (require 'cl))

(require 'flymake)

(defgroup langtool nil
  "Customize langtool"
  :group 'applications)

(defvar current-prefix-arg)
(defvar unread-command-events)
(defvar locale-language-names)

(defcustom langtool-java-bin "java"
  "*Executing java command."
  :group 'langtool
  :type 'file)

(defcustom langtool-language-tool-jar nil
  "*LanguageTool jar file."
  :group 'langtool
  :type 'file)

(defcustom langtool-default-language "en"
  "*Language name pass to LanguageTool."
  :group 'langtool
  :type 'string)

(defcustom langtool-disabled-rules nil
  "*Disabled rules pass to LanguageTool.
String that separated by comma or list of string.
"
  :group 'langtool
  :type '(choice 
          (list string)
          string))

(defvar langtool-temp-file nil)
(make-variable-buffer-local 'langtool-temp-file)

(defconst langtool-output-regexp 
  (concat
   "^[0-9]+\\.) Line \\([0-9]+\\), column \\([0-9]+\\), Rule ID: \\(.*\\)\n"
   "Message: \\(.*\\)\n"
   "Suggestion: \\(\\(?:.*\\)\n\\(?:.*\\)\n\\(?:.*\\)\\)\n"
    "\n?"
   ))

(defvar langtool-buffer-process nil)
(make-variable-buffer-local 'langtool-buffer-process)

(defvar langtool-mode-line-process 
  '(langtool-buffer-process " LanguageTool running..."))

(defun langtool-goto-next-error ()
  "Goto next error."
  (interactive)
  (let ((overlays (langtool-overlays-region (point) (point-max))))
    (langtool-goto-error 
     overlays
     (lambda (ov) (< (point) (overlay-start ov))))))

(defun langtool-goto-previous-error ()
  "Goto previous error."
  (interactive)
  (let ((overlays (langtool-overlays-region (point-min) (point))))
    (langtool-goto-error 
     (reverse overlays)
     (lambda (ov) (< (overlay-end ov) (point))))))

(defun langtool-show-message-at-point ()
  "Show error details at point"
  (interactive)
  (let ((msgs (langtool-current-error-messages)))
    (if (null msgs)
        (message "No errors")
      (let ((buf (get-buffer-create langtool-error-buffer-name)))
        (with-current-buffer buf
          (erase-buffer)
          (mapc
           (lambda (msg) (insert msg "\n"))
           msgs))
        (save-window-excursion
          (display-buffer buf)
          (let* ((echo-keystrokes)
                 (event (read-event)))
            (setq unread-command-events (list event))))))))

(defun langtool-check-done ()
  "Finish LanguageTool process and cleanup existing overlays."
  (interactive)
  (when langtool-buffer-process
    (delete-process langtool-buffer-process))
  (langtool-clear-buffer-overlays)
  (message "Cleaned up LanguageTool."))

(defun langtool-check-buffer (&optional lang)
  "Check context current buffer.
Optional \\[universal-argument] read LANG name."
  (interactive
   (when current-prefix-arg
     (list (langtool-read-lang-name))))
  (langtool-check-command)
  (add-to-list 'mode-line-process langtool-mode-line-process)
  (let ((file (buffer-file-name)))
    (unless langtool-temp-file
      (setq langtool-temp-file (make-temp-file "langtool-")))
    (when (or (null file) (buffer-modified-p))
      (save-restriction
        (widen)
        (let ((coding-system-for-write buffer-file-coding-system))
          (write-region (point-min) (point-max) langtool-temp-file nil 'no-msg))
        (setq file langtool-temp-file)))
    (langtool-clear-buffer-overlays)
    (let ((command langtool-java-bin)
          args)
      (setq args (list "-jar" (expand-file-name langtool-language-tool-jar)
                       "-c" (langtool-java-coding-system buffer-file-coding-system)
                       "-l" (or lang langtool-default-language)
                       "-d" (langtool-disabled-rules)
                       file))
      (let* ((buffer (langtool-process-create-buffer))
             (proc (apply 'start-process "LanguageTool" buffer command args)))
        (set-process-filter proc 'langtool-process-filter)
        (set-process-sentinel proc 'langtool-process-sentinel)
        (process-put proc 'langtool-source-buffer (current-buffer))
        (setq langtool-buffer-process proc)))))

(defun langtool-goto-error (overlays predicate)
  (catch 'done
    (mapc
     (lambda (ov)
       (when (funcall predicate ov)
         (goto-char (overlay-start ov))
         (throw 'done t)))
     overlays)
    nil))

(defun langtool-read-lang-name ()
  (completing-read "Lang: " locale-language-names))

(defun langtool-create-overlay (line column message)
  (save-excursion
    (goto-char (point-min))
    (condition-case nil
        (progn
          (forward-line (1- line))
          (let ((start (line-beginning-position))
                (end (line-end-position)))
            (move-to-column column)
            (backward-word)
            ;;FIXME LanguageTool column sometimes wrong!
            ;; restrict to current line
            (setq start (min end (max start (point))))
            (forward-word 2)
            (setq end (min end (point)))
            (let ((ov (make-overlay start end)))
              (overlay-put ov 'langtool-message message)
              (overlay-put ov 'priority 1)
              (overlay-put ov 'face 'flymake-errline))))
      ;;TODO ignore?
      (end-of-buffer nil))))

(defvar langtool-error-buffer-name " *LanguageTool Errors* ")
(defun langtool-current-error-messages ()
  (remove nil
          (mapcar
           (lambda (ov)
             (overlay-get ov 'langtool-message))
           (overlays-at (point)))))

(defun langtool-clear-buffer-overlays ()
  (mapc
   (lambda (ov)
     (delete-overlay ov))
   (langtool-overlays-region (point-min) (point-max))))

(defun langtool-overlays-region (start end)
  (sort
   (remove
    nil
    (mapcar
     (lambda (ov)
       (when (overlay-get ov 'langtool-message)
         ov))
     (overlays-in start end)))
   (lambda (ov1 ov2)
     (< (overlay-start ov1) (overlay-start ov2)))))

(defun langtool-check-command ()
  (when (or (null langtool-java-bin)
            (not (executable-find langtool-java-bin)))
    (error "java command is not found"))
  (when (or (null langtool-language-tool-jar)
            (not (file-readable-p langtool-language-tool-jar)))
    (error "langtool jar file is not found"))
  (when langtool-buffer-process
    (error "Another process is running")))

(defun langtool-disabled-rules ()
  (cond
   ((stringp langtool-disabled-rules)
    langtool-disabled-rules)
   ((consp langtool-disabled-rules)
    (mapconcat 'identity langtool-disabled-rules ","))
   (t
    "")))

(defun langtool-process-create-buffer ()
  (generate-new-buffer " *LanguageTool* "))

(defun langtool-process-filter (proc event)
  (with-current-buffer (process-buffer proc)
    (goto-char (point-max))
    (insert event)
    (let ((min (or (process-get proc 'langtool-process-done)
                   (point-min)))
          (buffer (process-get proc 'langtool-source-buffer))
          messages)
      (goto-char min)
      (while (re-search-forward langtool-output-regexp nil t)
        (let ((line (string-to-number (match-string 1)))
              (column (string-to-number (match-string 2)))
              (message
               (concat (match-string 3) "\n" 
                       (match-string 4) (match-string 5))))
          (setq messages (cons
                          (list line column message)
                          messages))))
      (process-put proc 'langtool-process-done (point))
      (when (buffer-live-p buffer)
        (with-current-buffer buffer
          (mapc
           (lambda (msg)
             (let ((line (nth 0 msg))
                   (col (nth 1 msg))
                   (message (nth 2 msg)))
               (langtool-create-overlay line col message)))
           messages))))))

(defun langtool-process-sentinel (proc event)
  (when (memq (process-status proc) '(exit signal))
    (let ((source (process-get proc 'langtool-source-buffer)))
      (when (buffer-live-p source)
        (with-current-buffer source
          (setq langtool-buffer-process nil))))
    (unless (= (process-exit-status proc) 0)
      (message "LanguageTool finished with code %d" 
               (process-exit-status proc)))
    (let ((buffer (process-buffer proc)))
      (when (buffer-live-p buffer)
        (kill-buffer buffer)))))

;;TODO
(defun langtool-java-coding-system (coding-system)
  (let ((cs (coding-system-base coding-system)))
    (case cs
      (utf-8 "utf-8")
      (euc-jp "euc-jp")
      (shift_jis "sjis")
      (iso-2022-7bit "iso2022jp")
      (t "ascii"))))

(provide 'langtool)

;; (require 'guide-key)
;; (setq guide-key/guide-key-sequence '("s-m" "C-x 4"))
;; (guide-key-mode 1)  ; Enable guide-key-mode
;; (setq guide-key/guide-key-sequence '("C-x"))
;; (setq guide-key/recursive-key-sequence-flag t)

;; (defun guide-key/my-hook-function-for-org-mode ()
;;   (guide-key/add-local-guide-key-sequence "C-c")
;;   (guide-key/add-local-guide-key-sequence "C-c C-x")
;;   (guide-key/add-local-highlight-command-regexp "org-"))
;; (add-hook 'org-mode-hook 'guide-key/my-hook-function-for-org-mode)

;; (require 'org-serenity-mode)
;; (defun serenity-mode ()
;;  "serenity"
;;  (interactive)
;;  (setq org-bullets-bullet-list (quote ("  ")))
;;  (org-serenity-mode)  
;;  (org-bullets-mode)
;; )

(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
(prefer-coding-system 'utf-8)
(setenv "LANG" "en_US.UTF-8")

(global-set-key [(control x) (?0)] 'delete-other-windows)
(global-set-key [(control x) (?9)] 'sticky-window-keep-window-visible)
(global-set-key  (kbd "s-0") 'delete-window)
(global-set-key  (kbd "s-1") 'delete-other-windows)
(global-set-key  (kbd "s-9") 'sticky-window-keep-window-visible)
(global-set-key  (kbd "s-2") 'split-window-vertically)
(global-set-key  (kbd "s-3") 'split-window-horizontally)

(setq-default abbrev-mode t)
(read-abbrev-file "~/.emacs.d/.abbrev_defs")
(setq abbrev-file-name "~/.emacs.d/.abbrev_defs")

(setq save-abbrevs t)
(setq save-abbrevs 'silently)
(setq only-global-abbrevs t)

(defun reflash-indentation ()
"Fix spacing on the screen."
  (interactive)
  (org-indent-mode 1)
(recenter-top-bottom)
  )

(require 'org-element) 

  (defun org-checkbox-p ()
  "Predicate: Checks whether the current line org-checkbox"
    (and
;; (org-or-orgalist-p)
      (string-match "^\s*\\([-+*]\\|[0-9]+[.\\)]\\)\s\\[.?\\]\s" (or (thing-at-point 'line) ""))))

  (defun org-plain-text-list-p ()
  "Predicate: Checks whether the current line org-plain-text-list"
    (and
;; (org-or-orgalist-p)
      (string-match "^\s*\\([-+]\\|\s[*]\\|[0-9]+[.\\)]\\)\s" (or (thing-at-point 'line) ""))))

(setq org-hierarchical-todo-statistics nil)

(setq org-todo-keywords
'((sequence "TODO(t)" "|" "DONE(d)")
(sequence "TODO(t)" "CURRENT(c)" "|" "DONE(d)")))

(defvar maxframe-maximized-p nil "maxframe is in fullscreen mode")

(defun toggle-maxframe ()
  "Toggle maximized frame"
  (interactive)
  (setq maxframe-maximized-p (not maxframe-maximized-p))
  (cond (maxframe-maximized-p (maximize-frame))
        (t (restore-frame))))

(define-key global-map [(s-return)] 'toggle-maxframe)
;; make it easy to go fullscreen
(defun toggle-fullscreen ()
  "Toggle full screen"
  (interactive)
  (set-frame-parameter
   nil 'fullscreen
   (when (not (frame-parameter nil 'fullscreen)) 'fullboth)))

;; and the keybinding
(unless (fboundp 'toggle-frame-fullscreen)
  (global-set-key (kbd "<f11>") 'toggle-fullscreen))
(unless (fboundp 'toggle-frame-fullscreen)
  (global-set-key (kbd "<f17>") 'toggle-fullscreen))

  (global-set-key (kbd "<f17>") 'toggle-fullscreen)

;; (require 'dired-details+)



;; (defadvice dired-readin
;;     (after dired-after-updating-hook first () activate)
;;   "Sort dired listings with directories first before adding marks."
;;   (mydired-sort)
;;   (let ((dired-details-internal-overlay-list  ())) (dired-details-hide)))

(defcustom dired-details-hidden-string ""
  "*This string will be shown in place of file details and symbolic links."
  :group 'dired-details
  :type 'string)

(defcustom dired-details-initially-hide t
  "*Hide dired details on entry to dired buffers."
  :group 'dired-details
  :type 'boolean)

(defun scrollbar-init ()
  (interactive)
  (scroll-bar-mode -1)
  )

(defun scrollbar-mode-turn-off-scrollbar ()
  (interactive)
  (scroll-bar-mode -1)
  )

(defun scrollbar-mode-turn-on-scrollbar ()
  (interactive)
  (scroll-bar-mode 1)
  )

;; (defadvice recover-session (around disable-dired-omit-for-recover activate)
;;   (let ((dired-mode-hook dired-mode-hook))
;;     (remove-hook 'dired-mode-hook 'enable-dired-omit-mode)
;;     ad-do-it))

(global-unset-key (kbd "s-j"))
(defvar s-j-map (make-keymap)
  "Keymap for local bindings and functions, prefixed by (Command-M)")
(define-key global-map (kbd "s-j") 's-j-prefix)
(fset 's-j-prefix s-j-map)

(defun kill-sentence-to-period ()
  "Leave the period in there."
  (interactive)
  (kill-sentence)
  (push-mark)
  (insert ".")
  (backward-char)
)

(defun my/forward-to-sentence-end ()
  "Move point to just before the end of the current sentence."
  (forward-sentence)
  (backward-char)
  (unless (looking-back "[[:alnum:]]")
    (backward-char)))

(defun my/beginning-of-sentence-p ()
  "Return  t if point is at the beginning of a sentence."
  (let ((start (point))
        (beg (save-excursion (forward-sentence) (forward-sentence -1))))
    (eq start beg)))

(defun my/kill-sentence-dwim ()
  "Kill the current sentence up to and possibly including the punctuation.
When point is at the beginning of a sentence, kill the entire
sentence. Otherwise kill forward but preserve any punctuation at the sentence end."
  (interactive)
(smart-expand)
  (if (my/beginning-of-sentence-p)
      (progn
        (kill-sentence)
        (just-one-space)
        (when (looking-back "^[[:space:]]+") (delete-horizontal-space)))
      (kill-region (point) (progn (my/forward-to-sentence-end) (point)))
      (just-one-space 0))

;; don't leave two periods in a row
(when
(or
(looking-at "\\.\\. ")
(and
(looking-at "\\.")
(looking-back "\\.")
)
)
(delete-forward-char 1))

(when
    (and
     (looking-at ".")
     (looking-back ",")
     )
  (delete-backward-char 1)
  (forward-char 1)
  )

)

(defun my/kill-line-dwim ()
  "Kill the current line."
  (interactive)
;; don't leave stray stars behind when killing a line
(when
(or
(looking-back "\\[")
(looking-back "\* ")
(looking-back "\* TODO ")
(looking-back "^\*+")
(looking-back "- ")
(looking-back "# ")
)
(beginning-of-line)
)
;;  (expand-abbrev)
  (org-kill-line)
;;  (save-excursion
;;    (when (my/beginning-of-sentence-on)
;;      (capitalize-unless-org-heading)))
)

(defun kill-sentence-maybe-else-kill-line ()
  (interactive)
(when
    (not (looking-at "$"))
  (my/kill-sentence-dwim))
  (when
      (looking-at "$")
    (my/kill-line-dwim))
)
;; and the keybinding
(global-set-key (kbd "M-k") 'kill-sentence-maybe-else-kill-line)

(setq browse-url-browser-function 'browse-url-default-macosx-browser)

(defun smart-period-or-smart-space ()
"double space adds a period!"
(interactive)
  (if
(looking-back "[A-Za-z0-9] ")
(smart-period)
(smart-space)
))

(defun smart-space ()
  "Insert space and then clean up whitespace."
  (interactive)
(cond (mark-active
 (progn (delete-region (mark) (point)))))

;; (if (org-at-heading-p)
 ;;    (insert-normal-space-in-org-heading)

  (unless
      (or
(let ((case-fold-search nil)
(looking-back "\\bi\.e[[:punct:][:punct:]]*[ ]*") ; don't add extra spaces to ie.
)
(looking-back "\\bvs.[ ]*") ; don't add extra spaces to vs.
(looking-back "\\be\.\g[[:punct:]]*[ ]*") ; don't add extra spaces to eg.

(looking-back "^[[:punct:]]*[ ]*") ; don't expand previous lines - brilliant!

(looking-back ">") ; don't expand days of the week inside timestamps

(looking-back "][\n\t ]*") ; don't expand past closing square brackets ]
       ))
  (smart-expand))

(insert "\ ")
(just-one-space)
)




;; this is probably convuluted logic to invert the behavior of the SPC key when in org-heading
(defun insert-smart-space-in-org-heading ()
 "Insert space and then clean up whitespace."
 (interactive)
(unless
   (or
(looking-back "\\bvs.[ ]*") ; don't add extra spaces to vs.
(looking-back "\\bi\.e[[:punct:][:punct:]]*[ ]*") ; don't add extra spaces to ie.
(looking-back "\\be\.\g[[:punct:][:punct:]]*[ ]*") ; don't add extra spaces to eg.

(looking-back "^[[:punct:][:punct:]]*[ ]*") ; don't expand previous lines---brilliant!

(looking-back ">") ; don't expand days of the week inside timestamps

(looking-back "][\n\t ]*") ; don't expand past closing square brackets ]
    )
 (smart-expand))
(insert "\ ")
 (just-one-space))



; (define-key org-mode-map (kbd "<SPC>") 'smart-period-or-smart-space) ; I disabled this for DragonSpeak 
(define-key org-mode-map (kbd "<SPC>") 'smart-space)
;; (define-key orgalist-mode-map (kbd "<SPC>") 'smart-period-or-smart-space)
(global-set-key (kbd "M-SPC") 'insert-space)
(define-key org-mode-map (kbd "<M-SPC>") 'insert-space)
;; (define-key orgalist-mode-map (kbd "<M-SPC>") 'insert-space)

;;; I changed this a)) bunch, not sure if it still works correctly.
;; (defun my/fix-space ()
;;   "Delete all spaces and tabs around point, leaving one space except at the beginning of a line and before a punctuation mark."
;;   (interactive)
;;   (just-one-space)
;;
;;     (when (or
;;            (looking-back "^[[:space:]]+")
;;            (looking-back "-[[:space:]]+")
;;            (looking-at "[.,:;!?»)-]")
;;            (looking-back"( ")
;;            (looking-at " )")
;;            ))
;;       (unless
;;       (looking-back "^-[[:space:]]+")
;;   (delete-horizontal-space))
;;
;; (unless
;;  (looking-back "^")
;; (just-one-space)
;; )
;;
;; )

(defun my/fix-space ()
  "Delete all spaces and tabs around point, leaving one space except at the beginning of a line and before a punctuation mark."
  (interactive)
  (just-one-space)
  (when (and (or
              (looking-back "^[[:space:]]+")
              (looking-back "-[[:space:]]+")
              (looking-at "[.,:;!?»)-]")
              (looking-back"( ")
              (looking-at " )")
              )
             (not (looking-back "^-[[:space:]]+"))
             (not (looking-back " - "))

)
    (delete-horizontal-space)))

(defun insert-space ()
  (interactive) 
(if (org-at-heading-p)
(insert-smart-space-in-org-heading)
(cond (mark-active
   (progn (delete-region (mark) (point)))))
  (insert " ")
)) 

(defun insert-normal-space-in-org-heading ()
 (interactive)
(cond (mark-active
 (progn (delete-region (mark) (point))))) 
 (insert " ")
)

;; this is probably convuluted logic to invert the behavior of the SPC key when in org-heading


(defun insert-period ()
"Inserts a fuckin' period!"
 (interactive)
(cond (mark-active
   (progn (delete-region (mark) (point)))))

 (insert ".")
)


(defun insert-comma ()
 (interactive)
(cond (mark-active
   (progn (delete-region (mark) (point))))) 
 (insert ",")
)

(defun insert-exclamation-point ()
 (interactive)
(cond (mark-active
  (progn (delete-region (mark) (point)))))
 (insert "!")
)


(defun insert-colon ()
"Insert a goodamn colon!"
 (interactive)
(cond (mark-active
  (progn (delete-region (mark) (point))))) 
 (insert ":")
) 

(defun insert-question-mark ()
"Insert a freaking question mark!!"
 (interactive)
(cond (mark-active
 (progn (delete-region (mark) (point))))) 
 (insert "?")
)

(setq org-blank-before-new-entry
      '((heading . always)
       (plain-list-item . always)))

(defun call-rebinding-org-blank-behaviour (fn)
  (let ((org-blank-before-new-entry
         (copy-tree org-blank-before-new-entry)))
    (when (org-at-heading-p)
      (rplacd (assoc 'heading org-blank-before-new-entry) nil))
    (call-interactively fn)))

(defun smart-org-meta-return-dwim ()
  (interactive)

(if

    (and
     (looking-back "^")
     (looking-at ".+")
     )                               ; if
    (org-toggle-heading-same-level) ; then
 (call-rebinding-org-blank-behaviour 'org-meta-return)) ; else
)

(defun smart-org-insert-heading-respect-content-dwim ()
(interactive)
  (call-rebinding-org-blank-behaviour 'org-insert-heading-respect-content)
)

(defun smart-org-insert-todo-heading-dwim ()
  (interactive)
  (let ((listitem-or-checkbox (org-plain-text-list-p)))
    (call-rebinding-org-blank-behaviour 'org-insert-heading)
    (if listitem-or-checkbox
        (insert "[ ] ")
        (insert "TODO ")))
)

(defun smart-org-insert-todo-heading-respect-content-dwim ()
  (interactive)
  (call-rebinding-org-blank-behaviour 'org-insert-todo-heading-respect-content)
)

(defun smart-org-insert-subheading ()
  (interactive)
(call-rebinding-org-blank-behaviour 'org-meta-return)
(org-demote-subtree)
)

(defun smart-org-insert-todo-subheading ()
  (interactive)
(call-rebinding-org-blank-behaviour 'org-insert-todo-subheading)
)

(defun length-of-previous-line ()
 (save-excursion
  (forward-line -1)
  (end-of-line)
  (current-column)))

(defun smart-return ()
  (interactive)

  ;; don't leave stray stars or links
  (when
      (or
       (looking-back "\\[")
       (looking-back "^\*+[ ]*") ; hopefully this means: at the beginning of the line, 1 or more asterisks followed by zero or more spaces
       (looking-back "^# ")
       ;; (looking-back "* TODO ") ; actually I don't think I want this
       ;; (looking-back "^*+")
       ;; (looking-back "- ")
       )
    (beginning-of-line)
    )
  ;;
  (cond (mark-active
	 (progn (delete-region (mark) (point))
		(newline)))
	;; Lifted from `org-return'. Why isn't there an
	;; `org-at-link-p' function?!
	((and 
	  org-return-follows-link
	  (org-in-regexp org-any-link-re))
	 (cond
	  ((or
	    ;;(looking-at "\\[\\[.*")
	    (looking-back ">")
	    (looking-back "\\]\\]")
	    (and (thing-at-point 'url)
		 (let ((bnds (bounds-of-thing-at-point 'url)))
		   (or (>= (car bnds) (point))
		       (<= (cdr bnds) (point))))))
	   (newline))
	  ((char-equal (string-to-char "]") (following-char))
	   (progn (forward-char 2)
		  (newline)))
	  (t (call-interactively 'org-open-at-point))))

	;; ((and 
	;;   (let ((el (org-element-at-point)))
	;;   (and el
	;;   ;; point is at an item
	;;   (eq (first el) 'item)
	;;   ;; item is empty
	;;   (eql (getf (second el) :contents-begin)
	;;   (getf (second el) :contents-end)))))
	;;  (message "at 1")
	;;  (beginning-of-line)
	;;  (let ((kill-whole-line nil))
	;;    (kill-line))
	;;  (newline))
	;; ((and 
	;;   (let ((el (org
	;; 	     -element-at-point)))
	;;     (and (not (org--line-empty-p 1))
	;; 	 (and el
	;; 	      (or (member (first el) '(item plain-list))
	;; 		  (let ((parent (getf (second el) :parent)))
	;; 		    (and parent
	;; 			 (member (first parent) '(item plain-list)))))))))
	;;  (let ((is-org-chbs (org-checkbox-p)))
	;;    (org-run-like-in-org-mode (lambda () (interactive) (call-interactively 'org-meta-return)))
	;;    (when is-org-chbs
	;;      (insert "[ ] "))))
	;; ((and
	  ;; (not (and
		;; org-return-follows-link
		;; (looking-back ">"))))
	 ;; (org-run-like-in-org-mode (lambda () (interactive) (call-interactively 'org-return))))
	(t (newline))))

(define-key org-mode-map (kbd "<return>") 'smart-return)
;; (define-key orgalist-mode-map (kbd "<return>") 'smart-return)

(defun kill-word-correctly ()
  "Kill word."
  (interactive)
  (smart-expand)
  (if (or (re-search-forward "\\=[ 	]*\n" nil t)
          (re-search-forward "\\=\\W*?[[:punct:]]+" nil t)) ; IF there's a sequence of punctuation marks at point
      (kill-region (match-beginning 0) (match-end 0)) ; THEN just kill the punctuation marks
    (kill-word 1))                                    ; ELSE kill word
  (my/fix-space)
;; don't leave two periods in a row
(when 
(or
(looking-at "\\,\\, ")

(and 
(looking-at "\\,")
(looking-back "\\,") 
)
)
(delete-forward-char 1))
)

(defun kill-word-correctly-and-capitalize ()
  "Check to see if the point is at the beginning of the sentence. If yes, then kill-word-correctly and endless/capitalize to capitalize the first letter of the word that becomes the first word in the sentence. Otherwise simply kill-word-correctly."
  (interactive)
(when (looking-at "[ ]")
         (forward-char 1)
          )
;; capitalize correctly if there's point is before the space at the beginning of a sentence 
 
  (let ((fix-capitalization (my/beginning-of-sentence-p)))
    (call-interactively 'kill-word-correctly)
    (when fix-capitalization
      (save-excursion (capitalize-unless-org-heading)))))

(defun cycle-hyphenation ()
  (interactive)
  (cond ((re-search-forward "\\=\\w*\\(-\\)\\w+" nil t)
         (save-excursion (replace-match " " t t nil 1)))
        ((re-search-forward "\\=\\w*\\( +\\)\\w+" nil t)
         (save-excursion (replace-match "-" t t nil 1)))))

(defvar *punctuation-markers-to-cycle-between*  ".?!")

(defun cycle-punctuation ()
  (interactive)
  (save-excursion
    (forward-sentence)
    (when (re-search-backward (format "\\>\\([%s]\\)[[:space:]]*\\="
                                      *punctuation-markers-to-cycle-between*)
                              nil t)
      (let ((next (elt *punctuation-markers-to-cycle-between*
                       ;; circular string; should be abstracted
                       (mod (1+ (position (elt (match-string 1) 0)
                                          *punctuation-markers-to-cycle-between*))
                            (length *punctuation-markers-to-cycle-between*)))))
        (replace-match (format "%c" next) t t nil 1)))))

;; (define-key key-minor-mode-map (kbd "M-.") 'cycle-punctuation)

(defun jay/left-char ()
  "Move point to the left or the beginning of the region.
 Like `backward-char', but moves point to the beginning of the region
provided the (transient) mark is active."
  (interactive)
  (let ((this-command 'left-char)) ;; maintain compatibility
    (let ((left (min (point)
                     ;; `mark' returning nil is ok; we'll only use this
                     ;; if `mark-active'
                     (or (mark t) 0))))
      (if (and transient-mark-mode mark-active)
          (progn
            (goto-char left)
            (setq deactivate-mark t))
        (call-interactively 'left-char)))))


(defun jay/right-char ()
  "Move point to the right or the end of the region.
 Like `right-char', but moves point to the end of the region
provided the (transient) mark is active."
  (interactive)
  (let ((this-command 'right-char)) ;; maintain compatibility
    (let ((right (max (point)
                      ;; `mark' returning nil is ok; we'll only use this
                      ;; if `mark-active'
                      (or (mark t) 0))))
      (if (and transient-mark-mode mark-active)
          (progn (goto-char right)
		 (setq deactivate-mark t))
	(call-interactively 'right-char)))))

(define-key org-mode-map (kbd "<left>") 'jay/left-char)
(define-key org-mode-map (kbd "<right>") 'jay/right-char)

(defun kill-clause ()
  (interactive)
  (smart-expand)

(if
(let ((sm (string-match "*+\s" (thing-at-point 'line)))) (and sm (= sm 0)))
(kill-line)


  (let ((old-point (point))
        (kill-punct (my/beginning-of-sentence-p)))
    (when (re-search-forward "--\\|[][,;:?!…\"”()}]+\\|\\.+ " nil t)
      (kill-region old-point
                   (if kill-punct
                       (match-end 0)
                     (match-beginning 0)))))
  (my/fix-space)
  (save-excursion
    (when (my/beginning-of-sentence-p)
      (capitalize-unless-org-heading)))

(when
(or    (looking-back ", , ")
     (looking-back ":: ")
     )
(new-org-delete-backward-char 2)
(my/fix-space)
t)

;; fix a bug that leaves this: " : "
(when (looking-back " : ")
(progn
(left-char 2)
(new-org-delete-backward-char 1)
(right-char 2)
))


;; fix a bug that leaves this: " , "
(when (looking-back " , ")
(progn
(left-char 2)
(my/fix-space)
(right-char 2)
))


;; fix a bug that leaves this: ",."
(when (looking-back ",. ")
(left-char 2)
(delete-backward-char 1)
(right-char 2)
)


;; fix a bug that leaves this: ", . "
(when (looking-back ", . ")
(left-char 2)
(delete-backward-char 2)
(right-char 2)
)

(when
(and
(looking-back "----")
(looking-at "-"))

(delete-backward-char 4)
(delete-char 1)
(insert-space))



))

(defvar *smart-punctuation-marks*
  ".,;:!?-")

(setq *smart-punctuation-exceptions*
  (list "?!" ".." "..." "............................................." "---" ";;" "!!" "!!!" "??" "???" "! :" ". :" ") ; "))

;; How do I add an exception for ") ; "?
;; e.g. if I want to add a comment after a line of lisp?

(defun smart-punctuation (new-punct &optional not-so-smart)
    (smart-expand)
    (save-restriction
      (when (and (eql major-mode 'org-mode)
                 (org-at-heading-p))
        (save-excursion
          (org-beginning-of-line)
          (let ((heading-text (fifth (org-heading-components))))
            (when heading-text
              (search-forward heading-text)
              (narrow-to-region (match-beginning 0) (match-end 0))))))
      (cl-flet ((go-back (regexp)
                  (re-search-backward regexp nil t)
                  (ignore-errors      ; might signal `end-of-buffer'
                    (forward-char (length (match-string 0))))))
        (if not-so-smart
            (let ((old-point (point)))
              (go-back "[^ \t]")
              (insert new-punct)
              (goto-char old-point)
              (forward-char (length new-punct)))
          (let ((old-point (point)))
            (go-back (format "[^ \t%s]\\|\\`" *smart-punctuation-marks*))
            (let ((was-after-space (and (< (point) old-point)
                                        (find ?  (buffer-substring (point) old-point)))))
              (re-search-forward (format "\\([ \t]*\\)\\([%s]*\\)"
                                         *smart-punctuation-marks*)
                                 nil t)
              (let* ((old-punct (match-string 2))
                     (was-after-punct (>= old-point (point))))
                (replace-match "" nil t nil 1)
                (replace-match (or (when (and was-after-punct
                                              (not (string= old-punct "")))
                                     (let ((potential-new-punct (concat old-punct new-punct)))
                                       (find-if (lambda (exception)
                                                  (search potential-new-punct exception))
                                                *smart-punctuation-exceptions*)))
                                   new-punct)
                               nil t nil 2)
                (if was-after-space
                    (my/fix-space)
                  (when (looking-at "[ \t]*\\<")
                    (save-excursion (my/fix-space))))))))))
    (when (and (eql major-mode 'org-mode)
               (org-at-heading-p))
; (org-align-tags-here org-tags-column)
))

(defun smart-period ()
  (interactive)
(cond (mark-active
 (progn (delete-region (mark) (point))))) 
(unless
      (or
(looking-back "\\bvs.[ ]*") ; Don't add extra periods to vs.
(looking-back "\\bi\.e[[:punct:]]*[ ]*") ; don't add extra periods to ie.
(looking-back "\\be\.\g[[:punct:]]*[ ]*") ; don't add extra periods to eg.

       )
  (smart-punctuation "."))
  (save-excursion
    (unless
        (or
         (looking-at "[ ]*$")
         (looking-at "\][[:punct:]]*[ ]*$")
         (looking-at "[[:punct:]]*[ ]*$")
         (looking-at "\"[[:punct:]]*[ ]*$")
         (looking-at "\)[ ]*$")
         (looking-at "\)")
         ) ; or
    (capitalize-unless-org-heading)
      ) ; unless
) ; save excursion

;; if two periods or two commas in a row, delete the second one 
(when 
(or
(and
(looking-at "\\.")
(looking-back "\\.")
) 
(and
(looking-at ",")
(looking-back ",")
))
(delete-char 1)
)

  ) ; defun


(define-key org-mode-map (kbd ".") 'smart-period)
;; (define-key orgalist-mode-map (kbd ".") 'smart-period)

(defun smart-comma ()
  (interactive)
(cond (mark-active
 (progn (delete-region (mark) (point))))) 

  (smart-punctuation ",")
(unless
(or

(looking-at "\]*[[:punct:]]*[ ]*$")
(looking-at "[[:punct:]]*[ ]*$")
(looking-at "[ ]*I\\b")          ; never downcase the word "I"
(looking-at "[ ]*I\'")          ; never downcase the word "I'
(looking-at "[[:punct:]]*[ ]*\"")          ; beginning of a quote
)

(save-excursion (downcase-word 1)))
(when

;; if two periods or two commas in a row, delete the second one
(or
(and
(looking-at "\\.")
(looking-back "\\.")
) 
(and
(looking-at ",")
(looking-back ",")
))
(delete-char 1)
)

)


(define-key org-mode-map (kbd ",") 'comma-or-smart-comma)
;; (define-key orgalist-mode-map (kbd ",") 'comma-or-smart-comma)

(defun smart-question-mark ()
  (interactive)
  (cond (mark-active
         (progn (delete-region (mark) (point))))) 

  (smart-punctuation "?")
  (save-excursion
    (unless
        (or
         (looking-at "[ ]*$")
         (looking-at "\][[:punct:]]*[ ]*$")
         (looking-at "[[:punct:]]*[ ]*$")
         (looking-at "\"[[:punct:]]*[ ]*$")
         (looking-at "\)[ ]*$")
         (looking-at "\)")
         ) ; or
    (capitalize-unless-org-heading)
      ) ; unless
    ) ; save excursion
  ) ; defun

;; works!!

(define-key org-mode-map (kbd "?") 'smart-question-mark)
;; (define-key orgalist-mode-map (kbd "?") 'smart-question-mark)

(defun smart-exclamation-point ()
  (interactive)
(cond (mark-active
 (progn (delete-region (mark) (point))))) 

  (smart-punctuation "!")
(save-excursion
(unless (looking-at "[ ]*$")
(capitalize-unless-org-heading))
))

(define-key org-mode-map (kbd "!") 'smart-exclamation-point)
;; (define-key orgalist-mode-map (kbd "!") 'smart-exclamation-point)

(defun smart-semicolon ()
  (interactive)
(cond (mark-active
 (progn (delete-region (mark) (point))))) 
  (smart-punctuation ";")
(unless
(or
(looking-at "[[:punct:]]*[ ]*$")
(looking-at "[ ]*I\\b")     ; never downcase the word "I"
(looking-at "[ ]*I\'")     ; never downcase the word "I'
(looking-at "[[:punct:]]*[ ]*\"")     ; beginning of a quote
)

(save-excursion (downcase-word 1))))

(define-key org-mode-map (kbd ";") 'smart-semicolon)
;; (define-key orgalist-mode-map (kbd ";") 'smart-semicolon)

(defun smart-colon ()
  (interactive)
(cond (mark-active
  (progn (delete-region (mark) (point))))) 
  (smart-punctuation ":")
(unless
(or
(looking-at "[[:punct:]]*[ ]*$")
(looking-at "[ ]*I\\b")     ; never downcase the word "I"
(looking-at "[ ]*I\'")     ; never downcase the word "I'
(looking-at "[[:punct:]]*[ ]*\"")     ; beginning of a quote
)

;; (save-excursion (downcase-word 1))
))


(define-key org-mode-map (kbd ":") 'colon-or-smart-colon)
(define-key org-mode-map (kbd ",") 'comma-or-smart-comma)
;; (define-key orgalist-mode-map (kbd ":") 'smart-colon)

(defun comma-or-smart-comma ()
(interactive) 
(if 
(or
(bolp)
(org-at-heading-p)
(looking-at " \"")
) 
(insert ",")
(smart-comma))
)

(defun colon-or-smart-colon ()
(interactive)
(if
(or
(bolp)
(org-at-heading-p)
)
(insert ":")
(smart-colon))
)

(defun backward-kill-word-correctly-and-capitalize ()
  "Backward kill word correctly. Then check to see if the point is at the beginning of the sentence. If yes, then kill-word-correctly and endless/capitalize to capitalize the first letter of the word that becomes the first word in the sentence. Otherwise simply kill-word-correctly."
  (interactive)
(call-interactively 'backward-kill-word-correctly)
  (let ((fix-capitalization (my/beginning-of-sentence-p)))
    (when fix-capitalization
      (save-excursion (capitalize-unless-org-heading)))))

(defadvice capitalize-word (after capitalize-word-advice activate)
  "After capitalizing the new first word in a sentence, downcase the next word which is no longer starting the sentence."

  (unless
 
      (or
       (looking-at "[ ]*\"")          ; if looking at a quote? Might not work

       (looking-at "[[:punct:]]*[ ]*I\\b")          ; never downcase the word "I"
       (looking-at "[[:punct:]]*[ ]*I'")          ; never downcase words like I'm, I'd
       (looking-at "[[:punct:]]*[ ]*\"*I'")    ; never downcase words like I'm, I'd 

(looking-at "[ ]*I\'")   ; never downcase the word "I'

       (looking-at "[[:punct:]]*[ ]*\"I\\b")          ; never downcase the word "I"
       (looking-at "[[:punct:]]*[ ]*OK\\b")          ; never downcase the word "OK"

       ;; (looking-at "\\") ; how do you search for a literal backslash?
       (looking-at (sentence-end))

       (looking-at "[[:punct:]]*[ ]*$") ; don't downcase past line break 

       (looking-at "[[:punct:]]*[ ]*\"$") ; don't downcase past quotation then line break 
       (looking-at "[[:punct:]]*[ ]*)$") ; don't downcase past a right paren then line break 
       (looking-at "[[:punct:]]*[ ]*\")$") ; don't downcase past a quotation then a right paren then a line break 

       (looking-at "[[:punct:]]*[ ]*http") ; never capitalize http 

(looking-at "\"[[:punct:]]*[ ]*$") ; a quotation mark followed by "zero or more whitespace then end of line?"

(looking-at "\)[ ]*$") ; a right paren followed by "zero or more" whitespace, then end of line 

(looking-at ")[ ]*$") ; a right paren followed by "zero or more" whitespace, then end of line 
(looking-at ")$") ; a right paren followed by "zero or more" whitespace, then end of line 

(looking-at "[ ]*-*[ ]*$") ; dashes at the end of a line 


       (looking-at (user-full-name))

       )

    (save-excursion
      (downcase-word 1))))

(defun capitalize-unless-org-heading ()
  (interactive)
  (unless
      (or
       (looking-at "[[:punct:]]*[\n\t ]*\\*")
       ;; (looking-at "\\* TODO"); redundant
       (let ((case-fold-search nil))
         (looking-at "[ ]*[\n\t ]*[[:punct:]]*[\n\t ]*[A-Z]")
         (looking-at "[A-Z].*"))
       (looking-at "[\n\t ]*[[:punct:]]*[\n\t ]*#\\+")
       (looking-at "[\n\t ]*[[:punct:]]*[\n\t ]*\(")
       (looking-at "[\n\t ]*[[:punct:]]*[\n\t ]*<")
       (looking-at "[\n\t ]*[[:punct:]]*[\n\t ]*file:")
       (looking-at "[\n\t ]*\\[fn")
       (looking-at "[\n\t ]*)$")
       (looking-at "[\n\t ]*\"$")
       (looking-at "\"[\n\t ]*$")
       (looking-at "[[:punct:]]*[ ]*http")
       (looking-at "[[:punct:]]*[ ]*\")$"); don't capitalize past
       (looking-at "[ ]*I\'")
       (looking-at
        (concat
         "\\("
         (reduce (lambda (a b) (concat a "\\|" b))
                 auto-capitalize-words)
         "\\)")))
    (capitalize-word 1)))

(defun downcase-save-excursion ()
  (interactive)
(unless
(or
(looking-at "[[:punct:]]*[ ]*$") 
(looking-at "[ ]*I\\b") ; never downcase the word "I"
(looking-at "[[:punct:]]*[ ]*[[:punct:]]*I'")  ; never downcase I'm I've etc.
(looking-at "[[:punct:]]*[ ]*$") ; zero or more whitespaces followed by zero or more punctuation followed by zero or more whitespaces followed by a line break
(looking-at "\"[[:punct:]]*[ ]*$") ; a quotation mark followed by "zero or more whitespace then end of line?"
(looking-at "\)[ ]*$") ; a quotation mark followed by "zero or more whitespace then end of line?"
(looking-at (sentence-end)) ; quotation mark followed by "zero or more whitespace then end of line?"
       (looking-at (user-full-name))


)
  (save-excursion
      (downcase-word 1))
  ))

(defun smart-expand ()
  (interactive)

  (unless

    (or
       (looking-back "\)\n*")
(looking-back "[[:punct:]]*\)[ ]*[[:punct:]]*[\n\t ]*[[:punct:]]*>*")
(looking-back ":t[ ]*")
(looking-back "][\n\t ]*[[:punct:]]*[\n\t ]*") ; don't expand past closing square brackets ]

(looking-back ">[\n\t ]*[[:punct:]]*[\n\t ]*") ; don't expand past closing email addresses]


;; (looking-back "\\\w") ; for some reason this matches all words, not just ones that start with a backslash
)
    (expand-abbrev)
)
)

;; (load-file "/Users/jay/emacs/emacs-settings/fountain-mode.el")
;; (require 'fountain-mode)

;; (add-hook 'fountain-mode-hook 'turn-on-olivetti-mode)
(add-hook 'fountain-mode-hook '(lambda () (orgalist-mode 1)))
(add-hook 'fountain-mode-hook 'turn-on-auto-capitalize-mode 'append)

(defcustom fountain-export-default-command
  'fountain-export-shell-script
  "\\<fountain-mode-map>Default function to call with \\[fountain-export-default]."
  :type '(radio (function-item fountain-export-shell-script)
                (function-item fountain-export-buffer-to-html))
  :group 'fountain-export)

(defcustom fountain-export-shell-script
  "afterwriting --config ~/.config/afterwriting/config.json --source %s --pdf --overwrite"
  "Shell command string to convert Fountain source to ouput.
\"%s\" will be substituted with `buffer-file-name'"
  :type 'string
  :group 'fountain-export)

(defun fountain-export-shell-script (&optional buffer)
  "Call shell script defined in `fountain-export-shell-script'."
  (interactive)
  (let* ((buffer (or buffer (current-buffer)))
         (file (shell-quote-argument (buffer-file-name buffer)))
         (command (format fountain-export-shell-script file)))
    (async-shell-command command "*Fountain Export Process*")))

(setq fountain-export-include-title-page nil)
(setq fountain-export-html-replace-alist
   (quote
    (("&" "&amp;")
     ("<" "&lt;")
     (">" "&gt;")
     ("\\\\ " "&nbsp;")
     ("^\\\\$" "<br>")
     ("\\\\_" "&#95;")
     ("\\\\\\*" "&#42;")
     ("\\\\`" "&#96;")
     ("\\\\'" "&apos;")
     ("``" "&ldquo;")
     ("''" "&rdquo;")
     ("`" "&lsquo;")
     ("'" "&rsquo;")
     ("\\*\\*\\*\\(.+?\\)\\*\\*\\*" "<span class=\"underline\">\\1</span>")
     ("\\*\\*\\(.+?\\)\\*\\*" "<span class=\"underline\">\\1</span>")
     ("\\*\\(.+?\\)\\*" "<span class=\"underline\">\\1</span>")
     ("^~ *\\(.+?\\)$\\*\\*" "<i>\\1</i>")
     ("_\\(.+?\\)_" "<span class=\"underline\">\\1</span>")
     ("

+" "<br><br>")
     ("
" "<br>"))))

;; (setq frame-title-format (concat "Hey bro, just FYI, this file is called %b or something like that."))
;; Changing this for Hook app compatibility per https://discourse.hookproductivity.com/t/integrating-emacs-and-hook-with-org-mode/932/5

(setq frame-title-format '((:eval buffer-file-name))) 

(defun my/hook (hook)
 "Create an org-link target string using `hook://` url scheme."
 (shell-command (concat "open \"" hook "\"")))

 (org-add-link-type "hook" 'my/hook)

;; (defun capitalize-sentence ()
;;   (interactive)
;; (unless (my/beginning-of-sentence-p)
;; (org-backward-sentence))
;;   (endless/capitalize)
;; (org-forward-sentence 1)
;; (jay/right-char)
;; )
;; (define-key key-minor-mode-map (kbd "M-C") 'capitalize-word)

;; (defun downcase-sentence ()
;;   (interactive)
;; (unless (my/beginning-of-sentence-p)
;; (org-backward-sentence))
;;   (downcase-word 1)
;; (org-forward-sentence 1)
;; (jay/right-char)
;; )

;; (define-key key-minor-mode-map (kbd "M-L") 'downcase-sentence)

(defun return-insert-blank-line-before ()
  (interactive)
  (beginning-of-line)
(newline)
  )

(defun toggle-item-or-hyphenation ()
(interactive "P")
(if

    (region-active-p)                               ; if
    (org-toggle-item) ; then
    (cycle-hyphenation); else
)
)

(defun smart-forward-sentence ()
  (interactive)
  (org-forward-sentence)
  (my/fix-space)
  )

(defun replace-inner ()
  (interactive)
(change-inner)
  (pasteboard-paste-no-spaces)
  )

(defun embolden-or-bold (arg)
  (interactive "p")
  (if (region-active-p)
      ;;      (wrap-region-trigger arg "*")
      (let ((s (replace-regexp-in-string
                "[*]" "" (delete-and-extract-region (region-beginning) (region-end)))))
        (insert "*")
        (insert s)
        (insert "*"))
    (embolden-next-word)))

(defvar *sent-emails-org-file* "~/Documents/random/sent-emails.org")

(defun save-buffer-to-sent-emails-org-file ()
  ;; header

(write-region
   (concat "\n\n\n* "
(format-time-string "%F %l:%M%P\n\n")
           "\n\n")
   0 *sent-emails-org-file* t)
  ;; buffer
  (write-region nil 0 *sent-emails-org-file* t))

(defun send-message-without-bullets ()
  (interactive)
  (remove-hook 'org-mode-hook 'org-bullets-mode)
;; (notmuch-mua-send-and-exit)
(message-send-and-exit) 
  (add-hook 'org-mode-hook 'org-bullets-mode))

(add-hook 'message-mode-hook
          (lambda ()
            (local-set-key "\C-c\C-c" 'send-message-without-bullets)
            (local-set-key "\C-c\C-l" 'org-insert-link)
))

(defvar *mail-signature* "\n---\nRichard Trotta\nPhD Candidate, Nuclear Physics\nThe Catholic University of America\n(646) 355-8001")

(defun sign-current-email ()
  (save-excursion
    (end-of-buffer)
    (insert *mail-signature*)))

(defun custom-send-message (arg)
  (interactive "p")
  (when (and arg (= 0 (mod arg 4)))
    (sign-current-email))
  (save-buffer-to-sent-emails-org-file)
  (send-message-without-bullets))

(defun reformat-email (begin end)
  (interactive "r")
(xah-replace-pairs-region begin end
 '(
 ["> " ""]
))
  (unfill-region begin end)
  (fill-region begin end)
  (xah-replace-pairs-region begin end
 '(
 ["\n" "\n> "]
)))

(defun fix-image-links ()
(interactive)
(goto-char 1)
(while (search-forward-regexp "[[\(.*?\).jpg][\(.*?\).jpg]]" nil t)
  (replace-match "[[" (match-string 1) ".jpg]]"  t nil))

(while (search-forward-regexp "[[\(.*?\).png][\(.*?\).png]]" nil t)
  (replace-match "[[" (match-string 1) ".png]]"  t nil))
)



(defun replace-garbage-chars ()
"Replace goofy MS and other garbage characters with latin1 equivalents."
(interactive)
(save-excursion				;save the current point
  (replace-string "  " " " nil (point-min) (point-max))
  (replace-string "" "" nil (point-min) (point-max))
  (replace-string "΄" "\"" nil (point-min) (point-max))
  (replace-string "“" "\"" nil (point-min) (point-max))
  (replace-string "’" "'" nil (point-min) (point-max))
  (replace-string "“" "\"" nil (point-min) (point-max))
  (replace-string "—" "--" nil (point-min) (point-max)) ; multi-byte
  (replace-string "" "'" nil (point-min) (point-max))
  (replace-string "" "'" nil (point-min) (point-max))
  (replace-string "" "\"" nil (point-min) (point-max))
  (replace-string "" "\"" nil (point-min) (point-max))
  (replace-string "" "\"" nil (point-min) (point-max))
  (replace-string "" "\"" nil (point-min) (point-max))
  (replace-string "‘" "\"" nil (point-min) (point-max))
  (replace-string "’" "'" nil (point-min) (point-max))
  (replace-string "¡\"" "\"" nil (point-min) (point-max))
  (replace-string "¡­" "..." nil (point-min) (point-max))
  (replace-string "" "..." nil (point-min) (point-max))
  (replace-string "" " " nil (point-min) (point-max)) ; M-SPC
  (replace-string "" "`" nil (point-min) (point-max))  ; \221
  (replace-string "" "'" nil (point-min) (point-max))  ; \222
  (replace-string "" "``" nil (point-min) (point-max))
  (replace-string "" "''" nil (point-min) (point-max))
  (replace-string "" "*" nil (point-min) (point-max))
  (replace-string "" "--" nil (point-min) (point-max))
  (replace-string "" "--" nil (point-min) (point-max))
  (replace-string " " " " nil (point-min) (point-max)) ; M-SPC
  (replace-string "¡" "\"" nil (point-min) (point-max))
  (replace-string "´" "\"" nil (point-min) (point-max))
  (replace-string "»" "<<" nil (point-min) (point-max))
  (replace-string "Ç" "'" nil (point-min) (point-max))
  (replace-string "È" "\"" nil (point-min) (point-max))
  (replace-string "é" "e" nil (point-min) (point-max)) ;; &eacute;
  (replace-string "ó" "-" nil (point-min) (point-max))

  (replace-string " Ñ " "---" nil (point-min) (point-max))


  (replace-string "á" "-" nil (point-min) (point-max))
(replace-string "     " "" nil (point-min) (point-max))
(replace-string "    " "" nil (point-min) (point-max))
(replace-string " " " " nil (point-min) (point-max))
(replace-string " " "" nil (point-min) (point-max))


(replace-string "Õ" "'" nil (point-min) (point-max))
(replace-string "Ò" "\"" nil (point-min) (point-max))
(replace-string "Ó" "\"" nil (point-min) (point-max))



))

(setq flyspell-abbrev-p t)
(setq flyspell-use-global-abbrev-table-p t)
(setq global-flyspell-mode t)

;; (require 'mw-thesaurus)
;; (load "~/.emacs.d/lisp-files/secret-codes.el")
;; (define-key key-minor-mode-map (kbd "M-s-t") 'mw-thesaurus--lookup-at-point)

;;     (use-package web-mode

;; :init
;;  (add-hook 'web-mode-hook
;;       (lambda ()
;;        (rainbow-mode)
;;        (rspec-mode)
;;        (setq web-mode-markup-indent-offset 2)))

;; ;; (setq web-mode-load-hook (quote ((lambda nil (abbrev-mode -1)))))

;; (add-hook 'web-mode-hook (lambda () (abbrev-mode -1)))

;;     :bind (:map web-mode-map 


;;   ("s-O" . prelude-open-with)))

(setq user-mail-address "trotta@cua.edu")
(setq user-full-name "Richard Trotta")
(setq gnus-always-read-dribble-file t)
(setq gnus-select-method '(nnml ""))
(setq gnus-select-method '(nnimap "gmail"
(nnimap-address "imap.gmail.com")
(nnimap-server-port 993)
(nnimap-stream ssl)))
(setq gnus-use-cache t) 




(setq gnus-select-method
   '(nnimap "gmail"
	    (nnimap-address "imap.gmail.com") ; it could also be imap.googlemail.com if that's your server.
	    (nnimap-server-port "imaps")
	    (nnimap-stream ssl)))




;; store email in ~/gmail directory
(setq nnml-directory "~/gmail")
;; (setq message-directory "~/gmail") 

;; define gnus directories
;; (setq message-directory "~/emacs/gnus/mail/")
(setq gnus-directory "~/emacs/gnus/news/")
(setq nnfolder-directory "~/emacs/gnus/mail/archive") 

;; How to read HTML mail
(setq mm-text-html-renderer 'w3m)
(setq gnus-summary-line-format "%-6,6B%-15,15f |%* %-40,40s | %&user-date; | %U\n")

;; sort by most recent date
(setq gnus-article-sort-functions (quote ((not gnus-article-sort-by-date))))
(setq gnus-thread-sort-functions (quote ((not gnus-thread-sort-by-date))))


;; More attractive Summary View
;; http://groups.google.com/group/gnu.emacs.gnus/browse_thread/thread/a673a74356e7141f
(when window-system
 (setq gnus-sum-thread-tree-indent " ")
 (setq gnus-sum-thread-tree-root "") ;; "● ")
 (setq gnus-sum-thread-tree-false-root "") ;; "◯ ")
 (setq gnus-sum-thread-tree-single-indent "") ;; "◎ ")
 (setq gnus-sum-thread-tree-vertical    "│")
 (setq gnus-sum-thread-tree-leaf-with-other "├─► ")
 (setq gnus-sum-thread-tree-single-leaf   "╰─► "))
(setq gnus-summary-line-format
   (concat
    "%0{%U%R%z%}"
    "%3{│%}" "%1{%d%}" "%3{│%}" ;; date
    " "
    "%4{%-20,20f%}"        ;; name
    " "
    "%3{│%}"
    " "
    "%1{%B%}"
    "%s\n"))
(setq gnus-summary-display-arrow t)

(defun org-mime-htmlize (&optional arg)
"Export a portion of an email body composed using `mml-mode' to
html using `org-mode'. If called with an active region only
export that region, otherwise export the entire body."
 (interactive "P")
 (require 'ox-org)
 (require 'ox-html)
 (let* ((region-p (org-region-active-p))
     (html-start (or (and region-p (region-beginning))
	     (save-excursion
	      (goto-char (point-min))
	      (search-forward mail-header-separator)
	      (+ (point) 1))))
     (html-end (or (and region-p (region-end))
	    ;; TODO: should catch signature...
	    (point-max)))
     (raw-body (concat org-mime-default-header
			  (buffer-substring html-start html-end)))
     (tmp-file (make-temp-name (expand-file-name
				  "mail" temporary-file-directory)))
     (body (org-export-string-as raw-body 'org t))
     ;; because we probably don't want to export a huge style file
     (org-export-htmlize-output-type 'inline-css)
     ;; makes the replies with ">"s look nicer
     (org-export-preserve-breaks org-mime-preserve-breaks)
     ;; dvipng for inline latex because MathJax doesn't work in mail
     (org-html-with-latex 'dvipng)
     ;; to hold attachments for inline html images
     (html-and-images
      (org-mime-replace-images
       (org-export-string-as raw-body 'html t) tmp-file))
     (html-images (unless arg (cdr html-and-images)))
     (html (org-mime-apply-html-hook
	    (if arg
		(format org-mime-fixedwith-wrap body)
	      (car html-and-images)))))
   (delete-region html-start html-end)
   (save-excursion
     (goto-char html-start)
     (insert (org-mime-multipart
	      body html (mapconcat 'identity html-images "\n"))))))

(defun new-email-from-subtree-with-signature ()
 "Send the current org-mode heading as the body of an email, with headline as the subject.

use these properties
TO
CC
BCC
OTHER-HEADERS is an alist specifying additional
header fields. Elements look like (HEADER . VALUE) where both
HEADER and VALUE are strings.

Save when it was sent as a SENT property. this is overwritten on
subsequent sends."
 (interactive)
 ; store location.
 (setq *email-heading-point* (set-marker (make-marker) (point)))
 (save-excursion
  (let ((content (progn
           (unless (org-on-heading-p) (outline-previous-heading))
           (let ((headline (org-element-at-point)))
            (buffer-substring
            (org-element-property :contents-begin headline)
            (org-element-property :contents-end headline)))))
     (TO (org-entry-get (point) "TO" t))
     (CC (org-entry-get (point) "CC" t))
     (BCC (org-entry-get (point) "BCC" t))
     (SUBJECT (nth 4 (org-heading-components)))
     (OTHER-HEADERS (eval (org-entry-get (point) "OTHER-HEADERS")))
     (continue nil)
     (switch-function nil)
     (yank-action nil)
     (send-actions '((email-send-action . nil)))
     (return-action '(email-heading-return)))

   (compose-mail TO SUBJECT OTHER-HEADERS continue switch-function yank-action send-actions return-action)
   (message-goto-body)
   (insert content)
   (when CC
    (message-goto-cc)
    (insert CC))
   (when BCC
    (message-goto-bcc)
    (insert BCC))
   (if TO
     (message-goto-body)
    (message-goto-to))
(end-of-buffer)
(insert "\Best regards,\Richard Trotta\n\n---\nRichard Trotta
(610) 739-0709
[[trotta@cua.edu]]
\n")
(message-goto-to))
))


(defun new-email-from-subtree-no-signature ()
 "Send the current org-mode heading as the body of an email, with headline as the subject.

use these properties
TO
CC
BCC
OTHER-HEADERS is an alist specifying additional
header fields. Elements look like (HEADER . VALUE) where both
HEADER and VALUE are strings.

Save when it was sent as a SENT property. this is overwritten on
subsequent sends."
 (interactive)
 ; store location.
 (setq *email-heading-point* (set-marker (make-marker) (point)))
 (save-excursion
  (let ((content (progn
           (unless (org-on-heading-p) (outline-previous-heading))
           (let ((headline (org-element-at-point)))
            (buffer-substring
            (org-element-property :contents-begin headline)
            (org-element-property :contents-end headline)))))
     (TO (org-entry-get (point) "TO" t))
     (CC (org-entry-get (point) "CC" t))
     (BCC (org-entry-get (point) "BCC" t))
     (SUBJECT (nth 4 (org-heading-components)))
     (OTHER-HEADERS (eval (org-entry-get (point) "OTHER-HEADERS")))
     (continue nil)
     (switch-function nil)
     (yank-action nil)
     (send-actions '((email-send-action . nil)))
     (return-action '(email-heading-return)))

   (compose-mail TO SUBJECT OTHER-HEADERS continue switch-function yank-action send-actions return-action)
   (message-goto-body)
   (insert content)
   (when CC
    (message-goto-cc)
    (insert CC))
   (when BCC
    (message-goto-bcc)
    (insert BCC))
   (if TO
     (message-goto-body)
    (message-goto-to))
;; (end-of-buffer)
)
))

(setq org-html-validation-link nil)
(setq org-export-html-postamble nil)

(require 'package)
(add-to-list 'package-archives
             '("melpa-stable" . "https://stable.melpa.org/packages/"))
(package-initialize)

(load-file "~/.emacs.d/alias.el")

(setq gnutls-algorithm-priority "NORMAL:-VERS-TLS1.3")
