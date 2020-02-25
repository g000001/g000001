;;;; g000001.slime.patch.asd -*- Mode: Lisp;-*- 

(cl:in-package :asdf)

(defsystem :g000001.slime.patch
  :serial t
  :depends-on (:fiveam
               :swank
               :lambda.time)
  :components ((:file "package")
               (:file "g000001.slime.patch")
               (:file "patch")))

(defmethod perform ((o test-op) (c (eql (find-system :g000001.slime.patch))))
  (load-system :g000001.slime.patch)
  (or (flet ((_ (pkg sym)
               (intern (symbol-name sym) (find-package pkg))))
         (let ((result (funcall (_ :fiveam :run) (_ :g000001.slime.patch.internal :g000001.slime.patch))))
           (funcall (_ :fiveam :explain!) result)
           (funcall (_ :fiveam :results-status) result)))
      (error "test-op failed") ))

