;;;; g000001.utils.booklog.asd -*- Mode: Lisp;-*- 

(cl:in-package :asdf)

(defsystem :g000001.utils.booklog
  :serial t
  :depends-on (:fiveam
               :named-readtables
               :rnrs-compat
               :cxml-stp
               :xpath
               :closure-html
               :srfi-1
               :srfi-2
               :srfi-9
               :srfi-13
               :srfi-14
               :srfi-23
               :srfi-89
               :srfi-42
               :srfi-115)
  :components ((:file "package")
               (:file "g000001.utils.booklog")))

(defmethod perform ((o test-op) (c (eql (find-system :g000001.utils.booklog))))
  (load-system :g000001.utils.booklog)
  (or (flet ((_ (pkg sym)
               (intern (symbol-name sym) (find-package pkg))))
         (let ((result (funcall (_ :fiveam :run) (_ :g000001.utils.booklog.internal :g000001.utils.booklog))))
           (funcall (_ :fiveam :explain!) result)
           (funcall (_ :fiveam :results-status) result)))
      (error "test-op failed") ))

