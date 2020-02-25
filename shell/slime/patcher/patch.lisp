(cl:in-package :swank)

;;; describe :: integer
(g000001.slime.patch:defun-patch parse-symbol-or-lose
                                 (string &optional (package *package*))
  (let ((maybe-int (ignore-errors (parse-integer string))))
    (or maybe-int
        (multiple-value-bind (symbol status) (parse-symbol string package)
          (if status
              (values symbol status)
              (error "Unknown symbol: ~A [in ~A]" string package) )))))


(defmethod describe-object ((n integer) stream)
  (call-next-method)
  (when (typep n '(integer 0 *))
    (format stream "  [universal time] ")
    (time:print-universal-time n stream)))


;;; eof
