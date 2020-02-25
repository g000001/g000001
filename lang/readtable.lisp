(in-package :g000001)


(defreadtable :g1.tao
  (:merge :tao)
  (:macro-char #\{ (lambda (srm char)
                     (declare (cl:ignore char))
                     #+sbcl (sb-impl::read-string srm #\})
                     #+lispworks (system::read-string srm #\})
                     ))
  (:dispatch-macro-char #\# #\Z #'series::series-reader)
  (:dispatch-macro-char #\# #\M #'series::abbreviated-map-fn-reader)
  ;; (:macro-char #\^ #'tao-read-toga)
  ;; (:macro-char #\. #'read-|.| 'T)
  (:case :upcase))


(defreadtable :g1.arc
  (:merge :arc)
  (:dispatch-macro-char #\# #\Z #'series::series-reader)
  (:dispatch-macro-char #\# #\M #'series::abbreviated-map-fn-reader)
  (:case :upcase))


(in-package :g1.scm)

(named-readtables:defreadtable :g1.scm
  (:fuze :rnrs :reader.r6rs)
  (:dispatch-macro-char #\# #\Z #'series::series-reader)
  (:dispatch-macro-char #\# #\M #'series::abbreviated-map-fn-reader)
  (:case :upcase))


(in-package :g000001)


(defun char-n-repeat-p (stream char n-repeat)
  (let ((releases '() ))
    (dotimes (i n-repeat T)
      (if (char= char (peek-char nil stream))
          (and (push (read-char stream) releases) T)
          (return-from char-n-repeat-p 
            (progn
              (dolist (c releases)
                (unread-char c stream))
              nil))))))


(defun |{{{-READER| (STREAM CHAR &aux (DELIM #\}))
  (if (char-n-repeat-p STREAM #\{ 2)
      (let ((ANS (make-array 0
                             :element-type 'character
                             :fill-pointer 0
                             :adjustable t)) )
        (loop :for C := (read-char STREAM t nil)
              :do (vector-push-extend C ANS)
              :until (and C (char-n-repeat-p STREAM DELIM 3))
              )
        (coerce ANS 'simple-string))
      (unread-char CHAR STREAM)))


#|(let ((*readtable* (copy-readtable nil)))
  (set-macro-character #\{ #'|{{{-READER| T *readtable*)
  (read-from-string "{{{(genhash:register-test-designator 'char-equal #'char-equal-hash #'char-equal)


\(let ((tab (genhash:make-generic-hash-table :test 'char-equal)))
  (setf (genhash:hashref #\a tab) t
        (genhash:hashref #\λ tab) t)
  (list (genhash:hashref #\a tab)
        (genhash:hashref #\A tab)
        (genhash:hashref #\b tab)
        (genhash:hashref #\B tab)
        (genhash:hashref #\λ tab)
        (genhash:hashref #\Λ tab)))
;=>  (T T NIL NIL T T)


\(let ((tab (genhash:make-generic-hash-table :test 'char-equal)))
  (setf (genhash:hashref 'a tab) t))
;!> The value A is not of type CHARACTER.
}}}"))|#


(defreadtable :myblog
  (:merge :standard)
  (:macro-char #\{ #|(cl:lambda (srm char)
                     (cl:declare (cl:ignore char))
                     #+sbcl (sb-impl::read-string srm #\})
                     #+lispworks (system::read-string srm #\})
                     )|#
               #'|{{{-READER|))

;;; eof
