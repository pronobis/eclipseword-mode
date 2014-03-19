;;; eclipseword.el --- Handling words (almost) like Eclipse does

;; Copyright (C) 2014 Andrzej Pronobis

;; Author: Andrzej Pronobis

;; This mode considers the following in its word definition:
;; - camel case e.g. these|Are|Different|Words
;; - multiple upper-case characters e.g. THESE|are|DIFFERENT|words
;; - numbers e.g. these|Are|33|WORDS
;; - symbols e.g. these|((|are|))|words
;; - white space (different when going forward and backwards) e.g. these| are| words| forward       |these |are |words |backward
;; - end and beginning of a line

;; In the minor mode, all common key bindings for word oriented
;; commands are overridden by the eclipseword oriented commands:

;; Key     Word oriented command      Eclipseword oriented command
;; ============================================================
;; M-f     `forward-word'             `eclipseword-forward'
;; M-b     `backward-word'            `eclipseword-backward'
;; M-@     `mark-word'                `eclipseword-mark'
;; M-d     `kill-word'                `eclipseword-kill'
;; M-DEL   `backward-kill-word'       `eclipseword-backward-kill'
;; M-t     `transpose-words'          `eclipseword-transpose'
;; M-c     `capitalize-word'          `eclipseword-capitalize'
;; M-u     `upcase-word'              `eclipseword-upcase'
;; M-l     `downcase-word'            `eclipseword-downcase'
;;
;; Note: If you have changed the key bindings for the word oriented
;; commands in your .emacs or a similar place, the keys you've changed
;; to are also used for the corresponding eclipseword oriented commands.

;; To make the mode turn on automatically, put the following code in
;; your .emacs:
;;   (add-hook 'c-mode-common-hook
;;        (lambda () (eclipseword-mode 1)))
;;
;; Or instead add:
;;   (global-eclipseword-mode 1)
;; to automatically enable the mode for all buffers


;; Acknowledgment:
;; This mode has been built on top of the code of the subword-mode
;; provided with Emacs 24 (subword.el)

;;; Code:

(defvar eclipseword-forward-function 'eclipseword-forward-internal
  "Function to call for forward eclipseword movement.")

(defvar eclipseword-backward-function 'eclipseword-backward-internal
  "Function to call for backward eclipseword movement.")

(defvar eclipseword-forward-regexp-0
  "[^[:digit:][:upper:][:lower:] _\t\n]+\\|[[:digit:]]+\\|[[:upper:]][[:lower:]]+\\|[[:upper:]][[:upper:]]+\\|[[:lower:]]+\\|[ \t]+$\\|[\n]\\|[ \t][ \t]+")

(defvar eclipseword-forward-regexp-1
  "[[:upper:]][^[:upper:][:lower:]]")

(defvar eclipseword-backward-regexp-0
  "[\n]")

(defvar eclipseword-backward-regexp-1
  "[[:digit:][:upper:][:lower:] _\t\n][^[:digit:][:upper:][:lower:] _\t\n]+\\|[^[:digit:]][[:digit:]]+\\|[^[:upper:]][[:upper:]][[:lower:]]+\\|[^[:upper:]][[:upper:]][[:upper:]]+\\|[^[:lower:][:upper:]][[:lower:]]+\\|[^ \t][ \t][ \t]+\\|[^[:upper:][:lower:]][[:upper:]][^[:upper:][:lower:]]")

(defvar eclipseword-backward-regexp-2
  "[[:upper:]][[:upper:]][[:lower:]]+")


(defvar eclipseword-mode-map
  (let ((map (make-sparse-keymap)))
    (dolist (cmd '(forward-word backward-word mark-word kill-word
				backward-kill-word transpose-words
                                capitalize-word upcase-word downcase-word))
      (let ((othercmd (let ((name (symbol-name cmd)))
                        (string-match "\\([[:alpha:]-]+\\)-word[s]?" name)
                        (intern (concat "eclipseword-" (match-string 1 name))))))
        (define-key map (vector 'remap cmd) othercmd)))
    map)
  "Keymap used in `eclipseword-mode' minor mode.")

;;;###autoload
(define-minor-mode eclipseword-mode
  "Toggle eclipseword movement and editing (Eclipseword mode).
\\{eclipseword-mode-map}"
    nil
    nil
    eclipseword-mode-map)

;;;###autoload
(define-global-minor-mode global-eclipseword-mode eclipseword-mode
  (lambda () (eclipseword-mode 1)))

(defun eclipseword-forward (&optional arg)
  "Do the same as `forward-word' but on eclipsewords.
See the command `eclipseword-mode' for a description of eclipsewords.
Optional argument ARG is the same as for `forward-word'."
  (interactive "p")
  (unless arg (setq arg 1))
  (cond
   ((< 0 arg)
    (dotimes (i arg (point))
      (funcall eclipseword-forward-function)))
   ((> 0 arg)
    (dotimes (i (- arg) (point))
      (funcall eclipseword-backward-function)))
   (t
    (point))))

(put 'eclipseword-forward 'CUA 'move)

(defun eclipseword-backward (&optional arg)
  "Do the same as `backward-word' but on eclipsewords.
See the command `eclipseword-mode' for a description of eclipsewords.
Optional argument ARG is the same as for `backward-word'."
  (interactive "p")
  (eclipseword-forward (- (or arg 1))))

(defun eclipseword-mark (arg)
  "Do the same as `mark-word' but on eclipsewords.
See the command `eclipseword-mode' for a description of eclipsewords.
Optional argument ARG is the same as for `mark-word'."
  ;; This code is almost copied from `mark-word' in GNU Emacs.
  (interactive "p")
  (cond ((and (eq last-command this-command) (mark t))
	 (set-mark
	  (save-excursion
	    (goto-char (mark))
	    (eclipseword-forward arg)
	    (point))))
	(t
	 (push-mark
	  (save-excursion
	    (eclipseword-forward arg)
	    (point))
	  nil t))))

(put 'eclipseword-backward 'CUA 'move)

(defun eclipseword-kill (arg)
  "Do the same as `kill-word' but on eclipsewords.
See the command `eclipseword-mode' for a description of eclipsewords.
Optional argument ARG is the same as for `kill-word'."
  (interactive "p")
  (kill-region (point) (eclipseword-forward arg)))

(defun eclipseword-backward-kill (arg)
  "Do the same as `backward-kill-word' but on eclipsewords.
See the command `eclipseword-mode' for a description of eclipsewords.
Optional argument ARG is the same as for `backward-kill-word'."
  (interactive "p")
  (eclipseword-kill (- arg)))

(defun eclipseword-transpose (arg)
  "Do the same as `transpose-words' but on eclipsewords.
See the command `eclipseword-mode' for a description of eclipsewords.
Optional argument ARG is the same as for `transpose-words'."
  (interactive "*p")
  (transpose-subr 'eclipseword-forward arg))

(defun eclipseword-downcase (arg)
  "Do the same as `downcase-word' but on eclipsewords.
See the command `eclipseword-mode' for a description of eclipsewords.
Optional argument ARG is the same as for `downcase-word'."
  (interactive "p")
  (let ((start (point)))
    (downcase-region (point) (eclipseword-forward arg))
    (when (< arg 0)
      (goto-char start))))

(defun eclipseword-upcase (arg)
  "Do the same as `upcase-word' but on eclipsewords.
See the command `eclipseword-mode' for a description of eclipsewords.
Optional argument ARG is the same as for `upcase-word'."
  (interactive "p")
  (let ((start (point)))
    (upcase-region (point) (eclipseword-forward arg))
    (when (< arg 0)
      (goto-char start))))

(defun eclipseword-capitalize (arg)
  "Do the same as `capitalize-word' but on eclipsewords.
See the command `eclipseword-mode' for a description of eclipsewords.
Optional argument ARG is the same as for `capitalize-word'."
  (interactive "p")
  (let ((count (abs arg))
	(start (point))
	(advance (if (< arg 0) nil t)))
    (dotimes (i count)
      (if advance
	  (progn (re-search-forward
		  (concat "[[:alpha:]]")
		  nil t)
		 (goto-char (match-beginning 0)))
	(eclipseword-backward))
      (let* ((p (point))
	     (pp (1+ p))
	     (np (eclipseword-forward)))
	(upcase-region p pp)
	(downcase-region pp np)
	(goto-char (if advance np p))))
    (unless advance
      (goto-char start))))


;;
;; Internal functions
;;
(defun eclipseword-forward-internal ()
  (setq match-point -1)
  (if (save-excursion
	(let ((case-fold-search nil))
	  (re-search-forward eclipseword-forward-regexp-0 nil t)))
      (setq match-point (match-end 0)))
  (if (save-excursion
	(let ((case-fold-search nil))
	  (re-search-forward eclipseword-forward-regexp-1 nil t)))
      (if (or (< match-point 0) (< (1+ (match-beginning 0)) match-point ))
          (setq match-point (1+ (match-beginning 0)))
        )
    )
  (if (> match-point 0)
      (goto-char match-point)
      (forward-word 1)))


(defun eclipseword-backward-internal ()
  (setq match-point -1)
  (if (save-excursion
	(let ((case-fold-search nil))
	  (re-search-backward eclipseword-backward-regexp-0 nil t)))
      (setq match-point (match-beginning 0)))
  (if (save-excursion
	(let ((case-fold-search nil))
	  (re-search-backward eclipseword-backward-regexp-1 nil t)))
      (if (or (< match-point 0) (> (1+ (match-beginning 0)) match-point ))
          (setq match-point (1+ (match-beginning 0)))
        )
    )
  (if (save-excursion
	(let ((case-fold-search nil))
	  (re-search-backward eclipseword-backward-regexp-2 nil t)))
      (if (or (< match-point 0) (> (+ 2 (match-beginning 0)) match-point ))
          (setq match-point (+ 2 (match-beginning 0)))
        )
    ) 
  (if (> match-point 0)
      (goto-char match-point)
      (backward-word 1)))

(provide 'eclipseword)

;;; eclipseword.el ends here
