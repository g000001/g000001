;;;; g000001.techp.asd -*- Mode: Lisp;-*- 

(cl:in-package :asdf)


(defsystem :g000001.techp
  :serial t
  :depends-on (:named-readtables :arc-compat :drakma :babel :cl-json)
  :components ((:file "package")
               (:file "g000001.techp")))


(defmethod perform ((o test-op) (c (eql (find-system :g000001.techp))))
  (load-system :g000001.techp)
  (or (flet (($ (pkg sym)
               (intern (symbol-name sym) (find-package pkg))))
        (let ((result (funcall ($ :fiveam :run) ($ :g000001.techp.internal :g000001.techp))))
          (funcall ($ :fiveam :explain!) result)
          (funcall ($ :fiveam :results-status) result)))
      (error "test-op failed") ))


;;; *EOF*
