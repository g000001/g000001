;;;; g000001.twitter.asd -*- Mode: Lisp;-*- 

(cl:in-package :asdf)


(defsystem :g000001.twitter
  :serial t
  :depends-on (
               ;;#-(:or :lispworks7)
               :named-readtables
               :arc-compat
               :cl-oauth
               :cl-json
               :srfi-19
               :g000001.ja
               :g000001.tools
               :lambda.output)
  :components ((:file "package")
               #|(:file "readtable")|#
               ;;#-(:or :lispworks7)
               (:file "g000001.twitter")
               ;; #+(:or :lispworks7)(:file "g000001.twitter.cl")
               ))


(defmethod perform ((o test-op) (c (eql (find-system :g000001.twitter))))
  (load-system :g000001.twitter)
  (or (flet (($ (pkg sym)
               (intern (symbol-name sym) (find-package pkg))))
        (let ((result (funcall ($ :fiveam :run) ($ :g000001.twitter.internal :g000001.twitter))))
          (funcall ($ :fiveam :explain!) result)
          (funcall ($ :fiveam :results-status) result)))
      (error "test-op failed") ))


;;; *EOF*
