;;; literate-elisp.el --- literate program to write elisp codes in org mode  -*- lexical-binding: t; -*-

;; Copyright (C) 2018-2019 Jingtao Xu

;; Author: Jingtao Xu <jingtaozf@gmail.com>
;; Created: 6 Dec 2018
;; Version: 0.1
;; Package-Version: 0.2
;; Keywords: lisp docs extensions tools
;; URL: https://github.com/jingtaozf/literate-elisp
;; Package-Requires: ((cl-lib "0.6") (emacs "24"))

;;; Commentary:

;; This file is automatically generated by function `literate-elisp-tangle' from file `literate-elisp.org'.
;; It is not designed to be readable by a human and is generated to load by Emacs directly without library `literate-elisp'.
;; you should read file `literate-elisp.org' to find out the usage and implementation detail of this source file.

;;; Code:

(require 'cl-lib)

(defvar literate-elisp-debug-p nil)

(defvar literate-elisp-org-code-blocks-p nil)

(defun literate-elisp-peek (in)
  "Return the next character without dropping it from the stream.
Argument IN: input stream."
  (cond ((bufferp in)
         (with-current-buffer in
           (when (not (eobp))
             (char-after))))
        ((markerp in)
         (with-current-buffer (marker-buffer in)
           (when (< (marker-position in) (point-max))
             (char-after in))))
        ((functionp in)
         (let ((c (funcall in)))
           (when c
             (funcall in c))
           c))))

(defun literate-elisp-next (in)
  "Given a stream function, return and discard the next character.
Argument IN: input stream."
  (cond ((bufferp in)
         (with-current-buffer in
           (when (not (eobp))
             (prog1
               (char-after)
               (forward-char 1)))))
        ((markerp in)
         (with-current-buffer (marker-buffer in)
           (when (< (marker-position in) (point-max))
             (prog1
               (char-after in)
               (forward-char 1)))))
        ((functionp in)
         (funcall in))))

(defun literate-elisp-position (in)
  "Return the current position from the stream.
Argument IN: input stream."
  (cond ((bufferp in)
         (with-current-buffer in
           (point)))
        ((markerp in)
         (with-current-buffer (marker-buffer in)
           (marker-position in)))
        ((functionp in)
         "Unknown")))

(defun literate-elisp-read-while (in pred)
  "Read and return a string from the input stream, as long as the predicate.
Argument IN: input stream.
Argument PRED: predicate function."
  (let ((chars (list)) ch)
    (while (and (setq ch (literate-elisp-peek in))
                (funcall pred ch))
      (push (literate-elisp-next in) chars))
    (apply #'string (nreverse chars))))

(defun literate-elisp-read-until-end-of-line (in)
  "Skip over a line (move to `end-of-line').
Argument IN: input stream."
  (prog1
    (literate-elisp-read-while in (lambda (ch)
                              (not (eq ch ?\n))))
    (literate-elisp-next in)))

(defvar literate-elisp-test-p nil)

(defun literate-elisp-tangle-p (flag)
  "Tangle current elisp code block or not.
Argument FLAG: flag symbol."
  (cl-case flag
    ((yes nil) t)
    (test literate-elisp-test-p)
    (no nil)
    (t nil)))

(defun literate-elisp-read-header-arguments (arguments)
  "Read org code block header arguments.
Argument ARGUMENTS: a string to hold the arguments."
  (cl-loop for token in (split-string arguments)
        collect (intern token)))

(defmacro literate-elisp-fix-invalid-read-syntax (in &rest body)
  "Fix read error `invalid-read-syntax'.
Argument IN: input stream.
Argument BODY: body codes."
  `(condition-case ex
        ,@body
      (invalid-read-syntax
       (when literate-elisp-debug-p
         (message "reach invalid read syntax %s at position %s"
                  ex (literate-elisp-position in)))
       (if (equal "#" (second ex))
         ;; maybe this is #+end_src
         (literate-elisp-read-after-sharpsign in)
         ;; re-throw this signal because we don't know how to handle it.
         (signal (car ex) (cdr err))))))

(defun literate-elisp-ignore-white-space (in)
  "Skip white space characters.
Argument IN: input stream."
  (while (cl-find (literate-elisp-peek in) '(?\n ?\ ?\t))
    ;; discard current character.
    (literate-elisp-next in)))

(defvar literate-elisp-read 'read)

(defun literate-elisp-read-datum (in)
  "Read and return a Lisp datum from the input stream.
Argument IN: input stream."

  (literate-elisp-ignore-white-space in)
  (let ((ch (literate-elisp-peek in)))
    (when literate-elisp-debug-p
      (message "literate-elisp-read-datum to character '%c'(position:%s)."
               ch (literate-elisp-position in)))

    (literate-elisp-fix-invalid-read-syntax in
      (cond
        ((not ch)
         (error "End of file during parsing"))
        ((and (not literate-elisp-org-code-blocks-p)
              (not (eq ch ?\#)))
         (let ((line (literate-elisp-read-until-end-of-line in)))
           (when literate-elisp-debug-p
             (message "ignore line %s" line)))
         nil)
        ((eq ch ?\#)
         (literate-elisp-next in)
         (literate-elisp-read-after-sharpsign in))
        (t (funcall literate-elisp-read in))))))

(defvar literate-elisp-begin-src-id "#+BEGIN_SRC elisp")
(defun literate-elisp-read-after-sharpsign (in)
  "Read after #.
Argument IN: input stream."
        ;; 1. if it is not inside an elisp syntax
  (cond ((not literate-elisp-org-code-blocks-p)
         ;; 1.1 check if it is `#+begin_src elisp'
         (if (cl-loop for i from 1 below (length literate-elisp-begin-src-id)
                   for c1 = (aref literate-elisp-begin-src-id i)
                   for c2 = (literate-elisp-next in)
                   thereis (not (char-equal c1 c2)))
         ;; 1.2. if it is not, continue to use org syntax and ignore this line
           (progn (literate-elisp-read-until-end-of-line in)
                  nil)
         ;; 1.3 if it is, read source block header arguments for this code block
           (let ((org-header-arguments (literate-elisp-read-header-arguments (literate-elisp-read-until-end-of-line in))))
             (when literate-elisp-debug-p
               (message "found org elisp src block, header-arguments:%s" org-header-arguments))
             (cond ((literate-elisp-tangle-p (cl-getf org-header-arguments :tangle))
         ;; 1.4 if it should be tangled, switch to elisp syntax context
                    (when literate-elisp-debug-p
                      (message "enter into a elisp code block"))
                    (setf literate-elisp-org-code-blocks-p t)
                    nil)))))
         ;; 1.5 if it should not be tangled, continue to use org syntax and ignore this line
        (t
        ;; 2. if it is inside an elisp syntax
         (let ((c (literate-elisp-next in)))
           (when literate-elisp-debug-p
             (message "found #%c inside a org block" c))
           (cl-case c
             ;; 2.1 check if it is ~#+~, which has only legal meaning when it is equal `#+end_src'
             (?\+
              (let ((line (literate-elisp-read-until-end-of-line in)))
                (when literate-elisp-debug-p
                  (message "found org elisp end block:%s" line)))
             ;; 2.2. if it is, then switch to org mode syntax.
              (setf literate-elisp-org-code-blocks-p nil)
              nil)
             ;; 2.3 if it is not, then use original elip reader to read the following stream
             (t (funcall literate-elisp-read in)))))))

(defun literate-elisp-read-internal (&optional in)
  "A wrapper to follow the behavior of original read function.
Argument IN: input stream."
  (cl-loop for form = (literate-elisp-read-datum in)
        if form
          do (cl-return form)
             ;; if original read function return nil, just return it.
        if literate-elisp-org-code-blocks-p
          do (cl-return nil)
             ;; if it reach end of stream.
        if (null (literate-elisp-peek in))
          do (cl-return nil)))

(defun literate-elisp-read (&optional in)
  "Literate read function.
Argument IN: input stream."
  (if (and load-file-name
           (string-match "\\.org\\'" load-file-name))
    (literate-elisp-read-internal in)
    (read in)))

(defun literate-elisp-load (path)
  "Literate load function.
Argument PATH: target file to load."
  (let ((load-read-function (symbol-function 'literate-elisp-read))
        (literate-elisp-org-code-blocks-p nil))
    (load path)))

(defun literate-elisp-batch-load ()
  "Literate load file in `command-line' arguments."
  (or noninteractive
      (signal 'user-error '("This function is only for use in batch mode")))
  (if command-line-args-left
    (literate-elisp-load (pop command-line-args-left))
    (error "No argument left for `literate-elisp-batch-load'")))


(defun literate-elisp-load-file (file)
  "Load the Lisp file named FILE.
Argument FILE: target file path."
  ;; This is a case where .elc and .so/.dll make a lot of sense.
  (interactive (list (read-file-name "Load org file: " nil nil 'lambda)))
  (literate-elisp-load (expand-file-name file)))

(defun literate-elisp-byte-compile-file (file &optional load)
  "Byte compile an org file.
Argument FILE: file to compile.
Arguemnt LOAD: load the file after compiling."
  (interactive
   (let ((file buffer-file-name)
	 (file-dir nil))
     (and file
	  (derived-mode-p 'org-mode)
	  (setq file-dir (file-name-directory file)))
     (list (read-file-name (if current-prefix-arg
			     "Byte compile and load file: "
			     "Byte compile file: ")
			   file-dir buffer-file-name nil)
	   current-prefix-arg)))
  (let ((literate-elisp-org-code-blocks-p nil)
        (load-file-name buffer-file-name)
        (original-read (symbol-function 'read)))
    (fset 'read (symbol-function 'literate-elisp-read-internal))
    (unwind-protect
        (byte-compile-file file load)
      (fset 'read original-read))))

(defun literate-elisp-tangle-reader (&optional buf)
  "Tangling codes in one code block.
Arguemnt BUF: source buffer."
  (with-output-to-string
      (with-current-buffer buf
        (when (/= (point) (line-beginning-position))
          ;; if reader still in last line,move it to next line.
          (forward-line 1))

        (loop for line = (buffer-substring-no-properties (line-beginning-position) (line-end-position))
              until (or (eobp)
                        (string-equal (trim-string (downcase line)) "#+end_src"))
              do (loop for c across line
                       do (write-char c))
                 (when literate-elisp-debug-p
                   (message "tangle elisp line %s" line))
                 (write-char ?\n)
                 (forward-line 1)))))

(cl-defun literate-elisp-tangle (file &key (el-file (concat (file-name-sans-extension file) ".el"))
                                header tail
                                test-p)
  "Literate tangle
Argument FILE: target file"
  (let* ((source-buffer (find-file-noselect file))
         (target-buffer (find-file-noselect el-file))
         (org-path-name (concat (pathname-name file) "." (pathname-type file)))
         (literate-elisp-read 'literate-elisp-tangle-reader)
         (literate-elisp-test-p test-p)
         (literate-elisp-org-code-blocks-p nil))
    (with-current-buffer target-buffer
      (delete-region (point-min) (point-max))
      (when header
        (insert header "\n"))
      (insert ";; This file is automatically generated by function `literate-elisp-tangle' from file `" org-path-name "'.\n"
              ";; It is not designed to be readable by a human and is generated to load by Emacs directly without library `literate-elisp'.\n"
              ";; you should read file `" org-path-name "' to find out the usage and implementation detail of this source file.\n\n"
              ";;; Code:\n\n"))

    (with-current-buffer source-buffer
      (goto-char (point-min))
      (cl-loop for obj = (literate-elisp-read-internal source-buffer)
               if obj
               do (with-current-buffer target-buffer
                    (insert obj "\n"))
               until (eobp)))

    (with-current-buffer target-buffer
      (when tail
        (insert "\n" tail))
      (save-buffer)
      (kill-current-buffer))))


(provide 'literate-elisp)
;;; literate-elisp.el ends here