;;;; info-lispm-at-mit-ai-utils.asd

(cl:in-package :asdf)

(defsystem :info-lispm-at-mit-ai-utils
  :serial t
  :components ((:file "package")
               (:file "info-lispm-at-mit-ai-utils")))

(defmethod perform ((o test-op) (c (eql (find-system :info-lispm-at-mit-ai-utils))))
  (load-system :info-lispm-at-mit-ai-utils)
  (or (flet ((_ (pkg sym)
               (intern (symbol-name sym) (find-package pkg))))
         (let ((result (funcall (_ :fiveam :run) (_ :info-lispm-at-mit-ai-utils-internal :info-lispm-at-mit-ai-utils))))
           (funcall (_ :fiveam :explain!) result)
           (funcall (_ :fiveam :results-status) result)))
      (error "test-op failed") ))

