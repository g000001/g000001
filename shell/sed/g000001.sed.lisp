;;;; g000001.sed.lisp

(cl:in-package :g000001.sed.internal)
;; (in-readtable :g000001.sed)

(def-suite g000001.sed)

(in-suite g000001.sed)

;;; "g000001.sed" goes here. Hacks and glory await!

(defun y1 (pat rep &optional (in *standard-input*) (out *standard-output*))
  (declare (character pat rep))
  (etypecase in
    (stream (format out (substitute rep pat (read-line in))))
    (string (format out (substitute rep pat in)))))

(defun y (pat rep &optional (in *standard-input*) (out *standard-output*))
  (cond ((and (characterp pat)
              (characterp rep))
         (y1 pat rep in out))
        ((and (stringp pat)
              (stringp rep))
         (let* ((line (typecase in
                        (stream (read-line in))
                        (string in)))
                (out (make-array (length line) :element-type 'character
                                 :fill-pointer 0 :adjustable T)))
           (loop :for a :across pat
                 :for b :across rep
                 :do (setf (fill-pointer out) 0)
                     (y1 a b line out))
           line))
        (T (error "bad types ~A or ~A" pat rep))))


(with-input-from-string (*standard-input* "foo bar aaaaaaa")
  (y "a" "z"))

;; (sed (s "foo" "bar" g) stream)



