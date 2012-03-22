(in-package :g000001)

(defun |#/-READER| (stream char arg)
  (declare (ignore char arg))
  (let ((g (gensym))
        (re (ppcre:regex-replace-all
             "\\\\/"
             (collect 'string
                      (choose
                       (let ((prev nil))
                         (until-if (lambda (c)
                                     (cond ((and (eql #\/ c)
                                                 (not (eql #\\ prev)))
                                            'T)
                                           (:else (setq prev c)
                                                  nil)))
                                   (scan-stream stream #'read-char)))))
             "/")))
    `(lambda (,g)
       (ppcre:scan ,re ,g))))

;(set-dispatch-macro-character #\# #\/ #'|#/-READER|)

(defreadtable :g1
  (:merge :tao)
  (:macro-char #\{ (lambda (srm char)
                     (declare (ignore char))
                     #+sbcl (sb-impl::read-string srm #\})
                     #+lispworks (system::read-string srm #\})
                     ))
  (:dispatch-macro-char  #\# #\Z
                             #'series::series-reader)
  (:dispatch-macro-char #\# #\M
                             #'series::abbreviated-map-fn-reader)
  ;; (:macro-char #\^ #'tao-read-toga)
  ;; (:macro-char #\. #'read-|.| 'T)
  (:case :upcase))

;;; eof
