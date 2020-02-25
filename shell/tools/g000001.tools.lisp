;;;; g000001.tools.lisp -*- Mode: Lisp;-*- 

(cl:in-package :g000001.tools.internal)
;; (in-readtable :g000001.tools)


;;; "g000001.tools" goes here. Hacks and glory await!

(eval-when (:compile-toplevel :load-toplevel :execute)
  (defun ?:qload (item)
    (progv '#0=
           (*break-on-signals* 
            ;; 
            *compile-file-pathname*
            *compile-file-truename*
            *compile-print*
            *compile-verbose*
            ;; 
            *debug-io*
            *debugger-hook*
            ;; 
            *default-pathname-defaults*
            ;; 
            *error-output*
            *features*
            *gensym-counter*
            *load-pathname*
            *load-print*
            *load-truename*
            *load-verbose*
            *macroexpand-hook*
            *modules*
            *package*
            *print-array*
            *print-base*
            *print-case* *print-circle* *print-escape* *print-gensym* *print-length*
            *print-level* *print-lines* *print-miser-width* *print-pprint-dispatch*
            *print-pretty* *print-radix* *print-readably* *print-right-margin*
            *query-io* *random-state* *read-base* *read-default-float-format*
            *read-eval* *read-suppress* *readtable* *standard-input* *standard-output*
            *terminal-io* *trace-output*)
            (list . #0#)
      (setq cl:*gensym-counter* (cl:get-universal-time)
            cl:*package* (cl:find-package :cl-user)
            cl:*readtable* (cl:copy-readtable nil))
      (ql:quickload item))))


(defun ?:d (obj &optional (out *standard-output*))
  (cl:describe obj out))


(defmacro ?::deftool ((&rest tags) name (&rest args) &body body)
  (let* ((name (or name
                   (expr-to-md5sum-symbol `(defun || (,@args) . ,body))))
         (expr `(defun ,name (,@args) . ,body)))
    `(progn
       (dolist (\t ',tags)
         (pushnew (list ',name) (gethash \t *defun/t-tags*)
                  :test #'equal))
       ,expr)))



#|(?::deftool (:date :iota) 
            ?::date-string-iota (n &key (start (srfi-19:current-date))
                                   (format "~m/~d(~a)"))
    (let ((stime (srfi-19:date->time-utc start))) 
      (rnrs:map (lambda (x)
                  (srfi-19:date->string 
                   (srfi-19:time-utc->date
                    (srfi-19:add-duration 
                     stime
                     (srfi-19:make-time srfi-19:time-duration
                                        0
                                        (* x 60 60 24))))
                   format))
                (srfi-1:iota n))))|#


(defun ?::tool-search (&rest tags)
  (apply #'intersection* 
         (mapcar (lambda (\t)
                   (gethash \t *defun/t-tags*))
                 tags)))

;;; *EOF*
