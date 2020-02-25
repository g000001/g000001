(in-package :g1)


(defmacro declaim-ftype (name args returns)
  `(declaim (ftype (function ,args ,(if (consp returns)
                                        returns
                                        `(values ,returns &optional)))
                   ,name)))


(defun pkg-functions (pkg)
  (let ((ans '() )
        (cl-pkg (find-package :cl))
        (cl-user-pkg (find-package :sb-ext))
        (pkg (find-package pkg)))
    (do-symbols (s pkg)
      (multiple-value-bind (sym stat)
                           (find-symbol (string s) :g1.tao)
        (declare (ignore sym))
        (when (and (eq pkg (symbol-package s))
                   (not (eq :inherited stat))
                   (not (eq cl-pkg (symbol-package s)))
                   (not (eq cl-user-pkg (symbol-package s))))
          (when (and (fboundp s)
                     (not (special-operator-p s))
                     (not (macro-function s)))
            (push s ans)))))
    ans))

#-lispworks
(defun extract-function-decls (pkg)
  (mapcar (lambda (f)
            (let ((ftype #+sbcl (sb-introspect:function-type f)
                         #+ccl (ccl::find-ftype-decl f)))
              (if (consp ftype)
                  `(declaim-ftype ,f ,@(cdr ftype))
                  (string f))))
          (pkg-functions pkg)))

(defun make-decl-form (pkg)
  `(progn ,@(extract-function-decls pkg)))

;;; eof











