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

(set-macro-character #\{
                     (lambda (srm char)
                       (declare (ignore char))
                       (sb-impl::read-string srm #\})))
