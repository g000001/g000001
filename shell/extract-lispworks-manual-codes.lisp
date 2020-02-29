(eval-when (:compile-toplevel :load-toplevel :execute)
  (ql:quickload '(bcl plump clss srfi-2 arc-compat)))


(defpackage "0b2f87ed-3d97-5268-a901-36fa0eda2c23"
  (:use :bcl :series :srfi-2))


(cl:in-package "0b2f87ed-3d97-5268-a901-36fa0eda2c23")


#|||
"Code-first"
"Code-body"
"Code-body"
"Code-last"
|||#

(defun get-pgfId# (node)
  (and-let* ((attr (plump:get-attribute 
                    (plump:first-child node)
                    "name"))
             (id (subseq attr #.(length "pgfId-")))
             (id# (parse-integer id)))
    id#))


(defun code-text (file)
  (let* ((str (alexandria:read-file-into-string file))
         (dom (plump:parse str)))
    (with-output-to-string (out)
      (format out "~&#| file://~A |#~%" file)
      (iterate ((e (scan (clss:select "title" dom))))
        (format out
                "~&#| ~A |#~%"
                (arc:trim (plump:text e) :both)))
      (let ((nodes (clss:select
                        ".Code-first, .Code-body, .Code-last" dom)))
        (iterate ((x (scan (sort nodes #'< :key #'get-pgfid#))))
          (fresh-line out)
          (write-line (plump-dom:text x) out)
          (force-output out)))
      (terpri out)
      (force-output out))))


#++doit
(let ((capiman-pages
       (sort (directory "/l/lispworks/lib/7-1-0-0/manual/online/CAPI-U/html/capi-u-*.htm")
             #'<
             :key (lambda (x)
                    (parse-integer (subseq (namestring x) 58)
                                   :junk-allowed T)))))
  (with-open-stream (out (openo "/l/capi-codes.lisp"))
    (dolist (p (subseq capiman-pages 0 nil))
      (let ((code (code-text p)))
        (progn
          (fresh-line)
          (write-line code)
          (terpri)
          (write-char #\Page))
        (fresh-line out)
        (write-line code out)
        (terpri out)
        (write-char #\Page out)))))


#++
(code-text "/l/lispworks/lib/7-1-0-0/manual/online/CAPI-U/html/capi-u-19.htm")


;;; *EOF*
