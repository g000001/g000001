;;;; g000001.xpath.asd -*- Mode: Lisp;-*- 

(cl:in-package :asdf)


(defsystem :g000001.xpath
  :serial t
  :depends-on (:fiveam
               :arc-compat
               :named-readtables
               :cxml-stp
               :xpath)
  :components ((:file "package")
               (:file "g000001.xpath")))


(defmethod perform ((o test-op) (c (eql (find-system :g000001.xpath))))
  (load-system :g000001.xpath)
  (or (flet (($ (pkg sym)
               (intern (symbol-name sym) (find-package pkg))))
        (let ((result (funcall ($ :fiveam :run) ($ :g000001.xpath.internal :g000001.xpath))))
          (funcall ($ :fiveam :explain!) result)
          (funcall ($ :fiveam :results-status) result)))
      (error "test-op failed") ))


;;; *EOF*
