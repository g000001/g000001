;;;; g000001.arc-ref.asd -*- Mode: Lisp;-*- 

(cl:in-package :asdf)


(defsystem :g000001.arc-ref
  :serial t
  :depends-on (:named-readtables
               :yaclml
               :kmrcl
               :cool)
  :components ((:file "package")
               #|(:file "readtable")|#
               (:file "g000001.arc-ref")))


(defmethod perform ((o test-op) (c (eql (find-system :g000001.arc-ref))))
  (load-system :g000001.arc-ref)
  (or (flet (($ (pkg sym)
               (intern (symbol-name sym) (find-package pkg))))
        (let ((result (funcall ($ :fiveam :run) ($ :g000001.arc-ref.internal :g000001.arc-ref))))
          (funcall ($ :fiveam :explain!) result)
          (funcall ($ :fiveam :results-status) result)))
      (error "test-op failed") ))


;;; *EOF*
