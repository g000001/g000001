;;;; g000001.comic-natalie-utils.asd -*- Mode: Lisp;-*- 

(cl:in-package :asdf)

(defsystem :g000001.comic-natalie-utils
  :serial t
  :depends-on (:fiveam
               :named-readtables
               :arc-compat
               :cool
               :cl-ppcre
               :xpath
               :closure-html
               :cxml-stp)
  :components ((:file "package")
               (:file "g000001.comic-natalie-utils")))

(defmethod perform ((o test-op) (c (eql (find-system :g000001.comic-natalie-utils))))
  (load-system :g000001.comic-natalie-utils)
  (or (flet ((_ (pkg sym)
               (intern (symbol-name sym) (find-package pkg))))
         (let ((result (funcall (_ :fiveam :run) (_ :g000001.comic-natalie-utils.internal :comic-natalie-utils))))
           (funcall (_ :fiveam :explain!) result)
           (funcall (_ :fiveam :results-status) result)))
      (error "test-op failed") ))

