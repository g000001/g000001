;;
;; 評価した結果を別バッファで表示する系
;;

;;
(defmacro define-slime-eval-and-grab-output (fn-name)
  (let ((expr        (format "(prin1 (%s %%s))(values)" fn-name))
        (main-fn     (intern (format "slime-%s" fn-name)))
        (show-fn     (intern (format "slime-show-%s" fn-name)))
        (eval-and-fn (intern (format "slime-eval-and-%s" fn-name)))
        (buffer-name (format "*SLIME %s*" (upcase (symbol-name fn-name)))))
    `(eval-after-load "slime"
       '(progn
          (defun ,main-fn ()
            (interactive)
            (,eval-and-fn
             ,(list 'list ''swank:eval-and-grab-output
                    `(format ,expr
                             (slime-defun-at-point)))))
          (defun ,eval-and-fn (form)
            (slime-eval-async form
              (slime-rcurry #',show-fn
                            (slime-current-package))))

          (defun ,show-fn (string package)
            (slime-with-popup-buffer (,buffer-name :package package :select t :mode 'lisp-mode)
              (princ (first string))
              (goto-char (point-min))))
          ',main-fn))))

;; print
(progn
  (defun slime-print-form ()
    "(Print) the form at point."
    (interactive)
    (slime-eval-and-print
     `(swank:eval-and-grab-output
       ,(format "(cl:print %s)" (slime-defun-at-point)))))

  (defun slime-eval-and-print (form)
    "Print FORM in Lisp and display the result in a new buffer."
    (slime-eval-async form (slime-rcurry #'slime-show-print
                                         (slime-current-package))))

  (defun slime-show-print (string package)
    (slime-with-popup-buffer ("*SLIME Print*" :package package :select t :mode 'lisp-mode)
      (princ (first string))
      (goto-char (point-min))))

  ;; control-shift-d
  (define-key slime-mode-map
    [(control shift ?p)] 'slime-print-form))


;; time
(progn
  (defun slime-time-form ()
    (interactive)
    (let ((defun-at-point (slime-defun-at-point)))
      (slime-eval-and-time
       defun-at-point
       `(swank:eval-and-grab-output
         ,(format "(cl:let ((cl:*trace-output* cl:*standard-output*))(cl:prog1 (cl:time %s)(cl:princ (cl:machine-version))))" defun-at-point)))))

  (defun slime-eval-and-time (orig-form form)
    (slime-eval-async form (slime-rcurry #'slime-show-time
                                         (slime-current-package)
                                         orig-form)))

  (defun slime-show-time (string package orig-form)
    (slime-with-popup-buffer ("*SLIME Time*" :package package :select t :mode 'lisp-mode)
      (princ (string-right-trim 10 orig-form))
      (princ "\n;=> ")
      (princ (second string))
      (princ "\n#|------------------------------------------------------------|\n")
      (princ (first string))
      (princ "\n |------------------------------------------------------------|#")
      (goto-char (point-min))))

  ;; control-shift-t
  (define-key slime-mode-map
    [(control shift ?t)] 'slime-time-form))

;; describe
(progn
  (defun slime-describe-form ()
    "(Describe) the form at point."
    (interactive)
    (slime-eval-and-describe
     `(swank:eval-and-grab-output
       ,(format "(cl:describe %s)" (slime-defun-at-point)))))

  (defun slime-eval-and-describe (form)
    "Describe FORM in Lisp and display the result in a new buffer."
    (slime-eval-async form (slime-rcurry #'slime-show-describe
                                         (slime-current-package))))

  (defun slime-show-describe (string package)
    (slime-with-popup-buffer ("*SLIME Describe*" :package package :select t :mode 'lisp-mode)
      (slime-popup-buffer-quit-function)
      (princ (first string))
      (goto-char (point-min))))

  ;; control-shift-d
  (define-key slime-mode-map
    [(control shift ?d)] 'slime-describe-form))

;; KMRCL依存
;; kmrcl time-iterations
(eval-after-load "slime"
  '(progn
     (defun slime-time-iterations (times)
       (interactive "p")
       (slime-eval-and-time-iterations
        `(swank:eval-and-grab-output
          ,(format "(kmrcl:time-iterations %s %s)"
                   times
                   (slime-defun-at-point)))))

     (defun slime-eval-and-time-iterations (form)
       (slime-eval-async form (slime-rcurry #'slime-show-time-iterations
                                            (slime-current-package))))

     (defun slime-show-time-iterations (string package)
       (slime-with-popup-buffer ("*SLIME TIME-ITERATIONS*" :package package :select t :mode 'lisp-mode)
         (princ (first string))
         (goto-char (point-min))))

     ;; SUPER-SHIFT-T
     (define-key slime-mode-map
       [(super shift ?t)] 'slime-time-iterations)))

;; KMRCL
(eval-after-load "slime"
  '(progn
     (defun slime-print-form-and-results ()
       "(Print-Form-And-Results) the form at point."
       (interactive)
       (slime-eval-and-print-form-and-results
        `(swank:eval-and-grab-output
          ,(format "(kmrcl::print-form-and-results %s)" (slime-defun-at-point)))))

     (defun slime-eval-and-print-form-and-results (form)
       "Print-Form-And-Results FORM in Lisp and display the result in a new buffer."
       (slime-eval-async form (slime-rcurry #'slime-show-print-form-and-results
                                            (slime-current-package))))

     (defun slime-show-print-form-and-results (string package)
       (slime-with-popup-buffer ("*SLIME Print-Form-And-Results*"
                                 :package package
                                 :select t
                                 :mode 'lisp-mode)
         (princ (first string))
         (goto-char (point-min))))

     ;; control-shift-r
     (define-key slime-mode-map
       [(control shift ?r)] 'slime-print-form-and-results)))

(define-slime-eval-and-grab-output kmrcl:ppmx)
(define-slime-eval-and-grab-output com.informatimago.common-lisp.cons-to-ascii:draw-list)

;; ltd
(eval-after-load "slime"
  '(progn
     (defun slime-ltd (times)
       (interactive "p")
       (slime-eval-and-ltd
        `(swank:eval-and-grab-output
          ,(format "(cl:WITH-INPUT-FROM-STRING (IN (cl:PRIN1-TO-STRING '%s))(LTD::LTD-EXP IN cl:*STANDARD-OUTPUT*))"
                   (slime-defun-at-point)))))

     (defun slime-eval-and-ltd (form)
       (slime-eval-async form (slime-rcurry #'slime-show-ltd
                                            (slime-current-package))))

     (defun slime-show-ltd (string package)
       (slime-with-popup-buffer ("*SLIME LtD*" :package package :select t :mode 'dylan-mode)
         (princ "// LtD")
         (terpri)
         (terpri)
         (princ (first string))
         (goto-char (point-min))))

     ;; SUPER-SHIFT-D
     (define-key slime-mode-map
       [(super shift ?d)] 'slime-ltd)))

;; 補完
(progn
  (defun slime-my-complete-form ()
    (interactive)
    ;; Find the (possibly incomplete) form around point.
    (let ((buffer-form (slime-parse-form-upto-point)))
      (let ((result (slime-eval `(swank:my-complete-form ',buffer-form))))
        (if (eq result :not-available)
            (error "Could not generate completion for the form `%s'" buffer-form)
          (progn
            (just-one-space (if (looking-back "\\s(" (1- (point)))
                                0
                              1))
            (save-excursion
              (insert result)
              (let ((slime-close-parens-limit 1))
                (slime-close-all-parens-in-sexp)))
            (save-excursion
              (backward-up-list 1)
              (indent-sexp)))))))

  (define-key slime-mode-map [(control ?c) (control shift ?s)]
     'slime-my-complete-form))

;;; -----------------------------------------------------------------------
;;; 評価した結果をバッファ内に ;=> 結果 という形で挿入
;;; quekさん作を自分好みに改造

(defun s-e-p-a-c>add-prefix (string prefix)
  (cond ((string-match "\n" string)
         (replace-regexp-in-string "\n" prefix string))
        (t string) ))

(defun s-e-p-a-c>fresh-line ()
  ;; 行頭でなければ改行を返す
  (if (not (bolp)) "\n" ""))

(defun slime-eval-print-as-comment (uarg string)
  "Eval STRING in Lisp; insert any output and the result at point."
  (lexical-let ((uarg uarg))
    (slime-eval-async `(swank:eval-and-grab-output ,string)
      (lambda (result)
        (destructuring-bind (output value) result
          (let ((output-prefix ";>>  ")
                (value-prefix ";=>  ")
                (value-prefix-rest ";    ")
                (value-oneline-sep ", ") )
            (unless (string= "" output)
              (insert
               (s-e-p-a-c>fresh-line)
               ;;
               output-prefix
               ;;
               (s-e-p-a-c>add-prefix output
                                     (concat "\n" output-prefix) )))
            (insert
             (s-e-p-a-c>fresh-line)
             ;;
             value-prefix
             ;;
             (if (string= "" value)

                 "<no values>"

                 (s-e-p-a-c>add-prefix value
                                       (if uarg
                                           value-oneline-sep
                                           (concat "\n" value-prefix-rest) )))
             ;;
             "\n" )))))))

(defun slime-que-print-last-expression (uarg string)
  "Evaluate sexp before point; print value into the current buffer"
  (interactive (list current-prefix-arg (slime-last-expression)))
  (slime-eval-print-as-comment uarg string))

(define-key slime-mode-map [(control shift ?j)]
  'slime-que-print-last-expression)

;;; -----------------------------------------------------------------------
(defun search-backward-testcase-name ()
  (save-excursion
    (re-search-backward "\\(deftest\\) +\\([^\\.]+\\)\.\\([0-9]\\)*" nil t)
    (list (match-string-no-properties 2)
          (parse-integer (match-string-no-properties 3)))))

(defun slime-eval-print-as-testcase (string)
  (lexical-let ((s string))
    (slime-eval-async `(swank:eval-and-grab-output ,string)
      (lambda (result)
        (destructuring-bind (output value) result
          (push-mark)
          (or (bolp) (insert "\n"))
          (destructuring-bind (name num)
                              (search-backward-testcase-name)
            (setq name (or name "foo"))
            (setq num (1+ (or num -1)))
            (insert (format "(deftest %s.%s\n  %s\n  %s )" name num s value) "\n")))))))

(defun slime-insert-rt-testcase (string)
  (interactive (list (slime-last-expression)))
  (slime-eval-print-as-testcase string) )

(define-key slime-mode-map [(control meta shift ?j)]
  'slime-insert-rt-testcase)

(defun slime-macroexpand-all-foo ()
  (interactive)
  (slime-eval-macroexpand 'g000001::mexp-string))

(define-key slime-mode-map [(control ?c) (control shift ?m)]
  'slime-macroexpand-all-foo)

(defun slime-source-transform ()
  (interactive)
  (slime-eval-macroexpand 'g000001::source-transform-string))

(define-key slime-mode-map [(control ?c) (meta ?t)]
  'slime-source-transform)



(define-key slime-mode-map [(control ?c) (hyper ?m)]
  (defun slime-rcw-macroexpand-all ()
    (interactive)
    (slime-eval-macroexpand 'rcw-mexp::macroexpand-all-string)))


(define-key slime-mode-map [(control ?c) (super ?m)]  ;; control-c super-mに設定
  (defun slime-macroexpand-dammit ()
    (interactive)
    (slime-eval-macroexpand 'macroexpand-dammit::macroexpand-dammit-string )))



;;
(defadvice slime-compile-defun (before critique-advice activate)
  (slime-eval-async
      `(swank:eval-and-grab-output
        ,(format "(cl:let ((cl:*standard-output* cl:*error-output*))
                     (lisp-critic:critique %s))"
                 (slime-defun-at-point)))))


;;

;; (defun slime-shorten-name ()
;;   "Display the recursively macro expanded sexp at point."
;;   (interactive)
;;   (slime-eval-macroexpand-inplace 'swank:swank-macroexpand-all))

;; (slime-macroexpand-all-inplace)


;; (slime-eval-async '(g000001::shortest-name 'kmrcl::flatten :kl)
;;   (lambda (result)
;;     (message (format "%s" result))))

;; (defun slime-shorten-package-name-inplace ()
;;   "Substitute the sexp at point with its macroexpansion.

;; NB: Does not affect slime-eval-macroexpand-expression"
;;   (interactive)
;;   (let* ((bounds (or (slime-bounds-of-sexp-at-point)
;;                      (error "No sexp at point"))))
;;     (lexical-let* ((start (copy-marker (car bounds)))
;;                    (end (copy-marker (cdr bounds)))
;;                    (point (point))
;;                    (package (slime-current-package))
;;                    (buffer (current-buffer)))
;;       (slime-eval-async
;;        `(,expander ,(buffer-substring-no-properties start end))
;;        (lambda (expansion)
;;          (with-current-buffer buffer
;;            (let ((buffer-read-only nil))
;;              (when (fboundp 'slime-remove-edits)
;;                (slime-remove-edits (point-min) (point-max)))
;;              (goto-char start)
;;              (delete-region start end)
;;              (slime-insert-indented expansion)
;;              (goto-char point))))))))

(defun slime-system-initialize-source-registry ()
  (interactive)
  (slime-eval `(asdf:initialize-source-registry)))

;; asd
(def-slime-selector-method ?a "Switch other asd file."
  (let* ((cb-name (buffer-name (current-buffer)))
         (bufs (cl-remove-if-not
                (lambda (x)
                  (let ((bname (buffer-name x)))
                    (and (string-match ".asd$" bname)
                         (not (string-equal bname cb-name)) )))
                (buffer-list) )))
    (if bufs
        (switch-to-buffer (first bufs))
        (error "No asd buffer"))))


;; package
(def-slime-selector-method ?p "Switch other package.lisp."
  (let* ((cb-name (buffer-name (current-buffer)))
         (bufs (cl-remove-if-not
                (lambda (x)
                  (let ((bname (buffer-name x)))
                    (and (string-match "package.lisp" bname)
                         (not (string-equal bname cb-name)) )))
                (buffer-list) )))
    (if bufs
        (switch-to-buffer (first bufs))
        (error "No package.lisp buffer"))))


(defun s-trim-dq-left (s)
  "Remove whitespace at the beginning of S."
  (if (string-match "\"" s)
      (replace-match "" t t s)
    s))

(defun s-trim-dq-right (s)
  "Remove whitespace at the end of S."
  (if (string-match "\"" s)
      (replace-match "" t t s)
    s))

(defun s-trim-dq (s)
  "Remove whitespace at the beginning and end of S."
  (s-trim-dq-left (s-trim-dq-right s)))

(defun insert-attribute-list ()
  (interactive)
  (save-excursion
    (goto-char 0)
    (slime-eval-async
      `(swank:eval-and-grab-output "(g1.tao::make-current-attribute-list-string)")
      (slime-rcurry (lambda (output pkg)
                      (save-excursion
                        (goto-char 0)
                        (insert (s-trim-dq (second output) )
                                "\n" )))
                    "CL-USER" ))))

(define-key slime-mode-map [(control ?\()]
  (defun find-unbalanced-parentheses ()
    "Find parenthesis error in buffer"
    (interactive)
    (slime-eval-async `(swank:eval-and-grab-output
                        ,(format "(g1::find-unbalanced-parentheses \"%s\" '%s)"
                                 (buffer-file-name (current-buffer))
                                 buffer-file-coding-system ))
      (lambda (output)
        (cond ((string-equal "T" (second output))
               (message "All parens appear balanced.") )
              (t
               (let ((pos (parse-integer (second output))))
                 (message
                  (if (minusp pos)
                      "Probably no right-paren for this left-paren."
                      "Probably extra right-paren here." ))
                 (goto-char (abs pos)) )))))))

(define-key slime-mode-map [(control meta ?&)]
  (defun slime-frob-lisp-conditional-inplace ()
    (interactive)
    (slime-eval-macroexpand-inplace 'g1.tao::frob-lisp-conditional-string)))

(define-key slime-mode-map [(control c) ?K]
  (defun slime-kill-definition (do-kill string)
    (interactive (list current-prefix-arg (slime-sexp-at-point)))
    (*slime-kill-definition do-kill string)))


(defun *slime-kill-definition (uarg string)
  (lexical-let ((uarg uarg))
    (slime-eval-async 
      `(swank:eval-and-grab-output
        ,(format "(g1::kill-definition-or-form \"%s\" %s)"
                 string
                 (not (null uarg))))
      (lambda (result)
        (destructuring-bind (output value) result
          (save-excursion
            (forward-sexp)
            (if uarg
                (message (format "%s" value))
                (insert "\n;; fmakunboud form "
                        (format "%s" value)
                        "\n"))))))))


;; eof
