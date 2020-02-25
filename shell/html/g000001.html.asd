;;;; g000001.html.asd -*- Mode: Lisp;-*- 

(cl:in-package :asdf)


(defsystem :g000001.html
  :serial t
  :depends-on (:named-readtables
               :cl-ppcre
               :kmrcl
               :drakma
               :series
               :tao-compat
               :yaclml
               :xpath
               :cl-html-parse
               :g000001.ja)
  :components ((:file "package")
               (:file "g000001.html.tao")))


(defmethod perform ((o test-op) (c (eql (find-system :g000001.html))))
  (load-system :g000001.html)
  (or (flet (($ (pkg sym)
               (intern (symbol-name sym) (find-package pkg))))
        (let ((result (funcall ($ :fiveam :run) ($ :g000001.html.internal :g000001.html))))
          (funcall ($ :fiveam :explain!) result)
          (funcall ($ :fiveam :results-status) result)))
      (error "test-op failed") ))


;;; *EOF*
