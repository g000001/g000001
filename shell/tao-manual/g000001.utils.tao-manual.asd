;;;; g000001.utils.tao-manual.asd -*- Mode: Lisp;-*- 

(cl:in-package :asdf)

(defsystem :g000001.utils.tao-manual
  :serial t
  :depends-on (:fiveam
               :named-readtables
               :rnrs-compat
               :yaclml
               :cl-ppcre
               :lambda.time
               :g000001
               :fmt
               :srfi-1
               :srfi-2
               :srfi-9
               :srfi-13
               :srfi-14
               :srfi-23
               :srfi-89
               :srfi-42
               :srfi-115
               :snow-match)
  :components ((:file "package")
               (:file "g000001.utils.tao-manual")))

(defmethod perform ((o test-op) (c (eql (find-system :g000001.utils.tao-manual))))
  (load-system :g000001.utils.tao-manual)
  (or (flet ((_ (pkg sym)
               (intern (symbol-name sym) (find-package pkg))))
         (let ((result (funcall (_ :fiveam :run) (_ :g000001.utils.tao-manual.internal :g000001.utils.tao-manual))))
           (funcall (_ :fiveam :explain!) result)
           (funcall (_ :fiveam :results-status) result)))
      (error "test-op failed") ))

