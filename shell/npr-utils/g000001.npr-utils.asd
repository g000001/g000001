;;;; g000001.npr-utils.asd -*- Mode: Lisp;-*- 

(cl:in-package :asdf)

(defsystem :g000001.npr-utils
  :serial t
  :depends-on (:fiveam
               :arc-compat
               :closure-html
               :xpath
               :cl-ppcre
               :named-readtables
               :drakma)
  :components ((:file "package")
               (:file "g000001.npr-utils")))

(defmethod perform ((o test-op) (c (eql (find-system :g000001.npr-utils))))
  (load-system :g000001.npr-utils)
  (or (flet ((_ (pkg sym)
               (intern (symbol-name sym) (find-package pkg))))
         (let ((result (funcall (_ :fiveam :run) (_ :g000001.npr-utils.internal :g000001_npr-utils))))
           (funcall (_ :fiveam :explain!) result)
           (funcall (_ :fiveam :results-status) result)))
      (error "test-op failed") ))

