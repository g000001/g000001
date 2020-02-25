;;;; g000001.usen.asd -*- Mode: Lisp;-*- 

(cl:in-package :asdf)


(defsystem :g000001.usen
  :serial t
  :depends-on (:root.package.it
               :cl-unicode
               :arc-compat
               :named-readtables
               :babel
               :drakma
               :cxml
               :toot
               :cxml-stp
               :bordeaux-threads
               :lambda.time)
  :components ((:file "package")
               (:file "g000001.usen")))


(defmethod perform ((o test-op) (c (eql (find-system :g000001.usen))))
  (load-system :g000001.usen)
  (or (flet (($ (pkg sym)
               (intern (symbol-name sym) (find-package pkg))))
        (let ((result (funcall ($ :fiveam :run) ($ :g000001.usen.internal :g000001.usen))))
          (funcall ($ :fiveam :explain!) result)
          (funcall ($ :fiveam :results-status) result)))
      (error "test-op failed") ))


;;; *EOF*
