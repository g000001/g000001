;;;; g000001.sed.asd -*- Mode: Lisp;-*- 

(cl:in-package :asdf)

(defsystem :g000001.sed
  :serial t
  :depends-on (:fiveam
               :named-readtables
               :cl-ppcre)
  :components ((:file "package")
               (:file "readtable")
               (:file "g000001.sed")))

(defmethod perform ((o test-op) (c (eql (find-system :g000001.sed))))
  (load-system :g000001.sed)
  (or (flet ((_ (pkg sym)
               (intern (symbol-name sym) (find-package pkg))))
         (let ((result (funcall (_ :fiveam :run) (_ :g000001.sed.internal :g000001.sed))))
           (funcall (_ :fiveam :explain!) result)
           (funcall (_ :fiveam :results-status) result)))
      (error "test-op failed") ))

