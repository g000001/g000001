;;;; g000001.euler.asd -*- Mode: Lisp;-*- 

(cl:in-package :asdf)


(defsystem :g000001.euler
  :serial t
  :depends-on (:arc-compat
               :named-readtables)
  :components ((:file "package")
               (:file "g000001.euler")))


(defmethod perform ((o test-op) (c (eql (find-system :g000001.euler))))
  (load-system :g000001.euler)
  (or (flet (($ (pkg sym)
               (intern (symbol-name sym) (find-package pkg))))
        (let ((result (funcall ($ :fiveam :run) ($ :g000001.euler.internal :g000001.euler))))
          (funcall ($ :fiveam :explain!) result)
          (funcall ($ :fiveam :results-status) result)))
      (error "test-op failed") ))


;;; *EOF*
