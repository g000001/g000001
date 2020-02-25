;;;; g000001.unicode.asd -*- Mode: Lisp;-*- 

(cl:in-package :asdf)


(defsystem :g000001.unicode
  :serial t
  :depends-on (:arc-compat
               :named-readtables
               :gauche-compat.text.tr)
  :components ((:file "package")
               (:file "g000001.unicode")))


(defmethod perform ((o test-op) (c (eql (find-system :g000001.unicode))))
  (load-system :g000001.unicode)
  (or (flet (($ (pkg sym)
               (intern (symbol-name sym) (find-package pkg))))
        (let ((result (funcall ($ :fiveam :run) ($ :g000001.unicode.internal :g000001.unicode))))
          (funcall ($ :fiveam :explain!) result)
          (funcall ($ :fiveam :results-status) result)))
      (error "test-op failed") ))


;;; *EOF*
