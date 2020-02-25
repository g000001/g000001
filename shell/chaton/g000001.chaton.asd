;;;; g000001.chaton.asd -*- Mode: Lisp;-*- 

(cl:in-package :asdf)


(defsystem :g000001.chaton
  :serial t
  :depends-on (:named-readtables :drakma :babel :kmrcl)
  :components ((:file "package")
               (:file "g000001.chaton")))


(defmethod perform ((o test-op) (c (eql (find-system :g000001.chaton))))
  (load-system :g000001.chaton)
  (or (flet (($ (pkg sym)
               (intern (symbol-name sym) (find-package pkg))))
        (let ((result (funcall ($ :fiveam :run) ($ :g000001.chaton.internal :g000001.chaton))))
          (funcall ($ :fiveam :explain!) result)
          (funcall ($ :fiveam :results-status) result)))
      (error "test-op failed") ))


;;; *EOF*
