;;;; g000001.utils.aozora-library.asd -*- Mode: Lisp;-*- 

(cl:in-package :asdf)


(defsystem :g000001.utils.aozora-library
  :serial t
  :depends-on (;; :fiveam
               :arc-compat
               :cool)
  :components ((:file "package")
               #|(:file "readtable")|#
               (:file "g000001.utils.aozora-library")
               #|(:file "test")|#))


(defmethod perform ((o test-op) (c (eql (find-system :g000001.utils.aozora-library))))
  (load-system :g000001.utils.aozora-library)
  (or (flet (($ (pkg sym)
               (intern (symbol-name sym) (find-package pkg))))
        (let ((result (funcall ($ :fiveam :run) ($ :g000001.utils.aozora-library.internal :g000001.utils.aozora-library))))
          (funcall ($ :fiveam :explain!) result)
          (funcall ($ :fiveam :results-status) result)))
      (error "test-op failed") ))


;;; *EOF*
