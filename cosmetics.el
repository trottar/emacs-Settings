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

;; (toggle-maxframe)
(setq default-frame-alist
      '(
        (width . 160) ; character
        (height . 42) ; lines
(cursor-color . "red") 
        ))
;; (zenburn)
;; (monaco-font)
;; (minuscule-type)
(turn-on-olivetti-mode)

(recenter-top-bottom)
;; (deja-vu-font)

(flyspell-mode-on)

(defun add-word-to-personal-dictionary ()
  (interactive)
  (let ((current-location (point))
        (word (flyspell-get-word)))
    (when (consp word)
      (flyspell-do-correct 'save nil (car word) current-location (cadr word) (caddr word) current-location))))

(use-package 'guide-key)
(setq guide-key/guide-key-sequence '("s-m" "C-x 4"))
(guide-key-mode 1)  ; Enable guide-key-mode
(setq guide-key/guide-key-sequence '("C-x"))
(setq guide-key/recursive-key-sequence-flag t)

(defun guide-key/my-hook-function-for-org-mode ()
  (guide-key/add-local-guide-key-sequence "C-c")
  (guide-key/add-local-guide-key-sequence "C-c C-x")
  (guide-key/add-local-highlight-command-regexp "org-"))
(add-hook 'org-mode-hook 'guide-key/my-hook-function-for-org-mode)

;; (require 'org-serenity-mode)
;;(defun serenity-mode ()
;;  "serenity"
;;  (interactive)
;;  (setq org-bullets-bullet-list (quote ("  ")))
;;  (org-serenity-mode)  
;;  (org-bullets-mode)
;; )
