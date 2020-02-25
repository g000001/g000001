;;;; stumpwm-setagaya-library-utilities.asd

(cl:in-package :asdf)

(defsystem :stumpwm-setagaya-library-utilities
  :serial t
  :depends-on (:drakma
               :babel
               :cxml-stp
               :closure-html
               :xpath
               :cl-ppcre)
  :components ((:file "package")
               (:file "stumpwm-setagaya-library-utilities")))

(defmethod perform ((o test-op) (c (eql (find-system :stumpwm-setagaya-library-utilities))))
  (load-system :stumpwm-setagaya-library-utilities)
  (or (flet ((_ (pkg sym)
               (intern (symbol-name sym) (find-package pkg))))
         (let ((result (funcall (_ :fiveam :run) (_ :stumpwm-setagaya-library-utilities-internal :stumpwm-setagaya-library-utilities))))
           (funcall (_ :fiveam :explain!) result)
           (funcall (_ :fiveam :results-status) result)))
      (error "test-op failed") ))

