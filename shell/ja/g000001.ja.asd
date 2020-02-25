;;;; g000001.ja.asd -*- Mode: Lisp;-*- 

(cl:in-package :asdf)


(defsystem :g000001.ja
  :serial t
  :depends-on (:cl-ppcre
               :kmrcl
               :gauche-compat.text.tr
               :arc-compat)
  :components ((:file "package")
               (:file "g000001.ja")
               #-scl (:file "g000001.ja.arc")
               ))


(defmethod perform ((o test-op) (c (eql (find-system :g000001.ja))))
  (load-system :g000001.ja)
  (or (flet (($ (pkg sym)
               (intern (symbol-name sym) (find-package pkg))))
        (let ((result (funcall ($ :fiveam :run) ($ :g000001.ja.internal :g000001.ja))))
          (funcall ($ :fiveam :explain!) result)
          (funcall ($ :fiveam :results-status) result)))
      (error "test-op failed") ))


;;; *EOF*
