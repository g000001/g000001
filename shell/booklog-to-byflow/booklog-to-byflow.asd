;;;; booklog-to-byflow.asd

(cl:in-package :asdf)

(defsystem :booklog-to-byflow
  :serial t
  :depends-on (:cl-ppcre)
  :components ((:file "package")
               (:file "booklog-to-byflow")))

(defmethod perform ((o test-op) (c (eql (find-system :booklog-to-byflow))))
  (load-system :booklog-to-byflow)
  (or (flet ((_ (pkg sym)
               (intern (symbol-name sym) (find-package pkg))))
         (let ((result (funcall (_ :fiveam :run) (_ :booklog-to-byflow-internal :booklog-to-byflow))))
           (funcall (_ :fiveam :explain!) result)
           (funcall (_ :fiveam :results-status) result)))
      (error "test-op failed") ))

