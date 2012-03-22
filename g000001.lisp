(in-package :g1)
(in-readtable :g1)

(setq *PACKAGE-PATH* (LIST :SHIBUYA.LISP
                           :FARE-UTILS
                           :ALEXANDRIA
                           :MYCL-UTIL
                           :KMRCL
                           :METATILITIES
                           :SCLF
                           ))

(kl:defconstant* fmt-hr "~V@{~A~:*~}~*~%"
  "fmt-hr (length string)")

(kl:defconstant* speed-speed-speed
  '(OPTIMIZE (SAFETY 0) (SPEED 3) (DEBUG 0)))


;(format nil fmt-hr 80 "=")
;=> "================================================================================
;   "


;; CR
(eval-when (:compile-toplevel :load-toplevel :execute)
  (!(symbol-function 'cr) #'identity))

(de pr (&rest args)
  (princ
   (with-output-to-string (out)
     (mapc (lambda (x) (princ x out)) args))))

(de prn (&rest args)
  (apply #'pr args)
  (terpri))

#+SBCL
#|(PROGN
  (EXECUTOR:DEFINE-EXECUTABLE SCP)

  (DEFMACRO WITH-OUTPUT-TO-REMOTE-FILE ((STREAM PATH) &BODY BODY)
    (LET ((TEMP-FILE-NAME (STRING (GENSYM "/tmp/WITH-OUTPUT-TO-REMOTE-FILE-"))))
      `(UNWIND-PROTECT (PROGN
                         (WITH-OPEN-FILE (,STREAM ,TEMP-FILE-NAME :DIRECTION :OUTPUT)
                           ,@BODY)
                         (SCP ,TEMP-FILE-NAME ,PATH)
                         NIL)
         (WHEN (CL-FAD:FILE-EXISTS-P ,TEMP-FILE-NAME)
           (DELETE-FILE ,TEMP-FILE-NAME)))))

  (DEFMACRO WITH-INPUT-FROM-REMOTE-FILE ((STREAM PATH) &BODY BODY)
    (LET ((TEMP-FILE-NAME (STRING (GENSYM "/tmp/WITH-INPUT-FROM-REMOTE-FILE-"))))
      `(UNWIND-PROTECT (PROGN
                         (SCP ,PATH ,TEMP-FILE-NAME)
                         (WITH-OPEN-FILE (,STREAM ,TEMP-FILE-NAME)
                           ,@BODY)
                         NIL)
         (WHEN (CL-FAD:FILE-EXISTS-P ,TEMP-FILE-NAME)
           (DELETE-FILE ,TEMP-FILE-NAME)))))
  )|#

(DEFUN SED (START-PAT END-PAT NEW
            &KEY (IN *STANDARD-INPUT*) (OUT *STANDARD-OUTPUT*))
  (cl:LOOP :WITH OPEN
        :FOR LINE := (READ-LINE IN NIL NIL) :WHILE LINE
        :DO (PROGN
              (WHEN (SEARCH START-PAT LINE)
                (SETQ OPEN 'T))
              (COND ((AND OPEN (SEARCH END-PAT LINE))
                     (SETQ OPEN NIL)
                     (WRITE-LINE NEW OUT))
                    ((NOT OPEN)
                     (WRITE-LINE LINE OUT))))))

(progn
  ;; ------------------------------------------------------------------------
  ;; macro expand
  ;; ------------------------------------------------------------------------
  (defun uninterned-symbols (tree)
    (remove-if-not
     (lambda (x)
       (and (symbolp x)
            (not (symbol-package x))))
     (sl::flatten-safe tree)))

  (defun count-symbol-names (syms)
    (let ((tab (make-hash-table :test 'equal)))
      (dolist (s syms)
        (incf (gethash (gensym-symbol-name s)
                       tab 0)))
      tab))

  (defun gensym-symbol-name (sym)
    (ppcre:regex-replace-all "-{0,1}\\d+$"
                             (symbol-name sym)
                             ""))
  #|(defun mexp (form)
    (let ((symtab (count-symbol-names
                   (remove-duplicates
                    (uninterned-symbols
                     (#+sbcl sb-cltl2:macroexpand-all
                      #+lispworks walker:walk-form form
                      form))))))
      (fare-utils:cons-tree-map
       (lambda (x)
         (cond
           ;; シンボルでない場合はスルー
           ((not (symbolp x)) x)
           ;; キーワードの場合はスルー
           ((keywordp x) x)
           ;; パッケージ名がある
           ((symbol-package x)
            (cond
              ;; 現在のパッケージ名と同じ
              ((string= (package-name (symbol-package x))
                        (package-name *package*))
               x)
              ;; 関数が束縛されていたらスルー
              ((fboundp x) x)
              ;; それ以外は、パッケージ名を省略(現在のパッケージにする)
              ('T (intern (symbol-name x)))))
           ;; 接頭辞が一度しか使われてない場合は数字を取り除く
           ((= 1 (gethash (gensym-symbol-name x)
                          symtab
                          0))
            (intern (gensym-symbol-name x)))
           ;; > 1
           ((< 1 (gethash (gensym-symbol-name x)
                          symtab
                          0))
            (intern (string-downcase (symbol-name x))))
           ;; それ以外は、スルー
           ('T x)))
       (#+sbcl sb-cltl2:macroexpand-all
        #+lispworks walker:walk-form
        form))))|#
  :-------------------------)

(defun mexp-string (form)
  (let ((swank::*macroexpand-printer-bindings*
         (cons '(*print-gensym*)
               swank::*macroexpand-printer-bindings* ) ))
    (swank:swank-macroexpand-all form) ))


#+sbcl
(defun source-transform (form &optional (env (sb-kernel:make-null-lexenv)))
  (if (and (consp form)
           (symbolp (car form))
           (not (special-operator-p (car form))) )
      (let ((sb-c::*lexenv* env))
        (or (and (fboundp (car form))
                 (funcall (sb-int:info :function :source-transform (car form))
                          form ))
            (values form t) ))
      (values form T) ))

(defun source-transform-string (form-string)
  (let ((swank::*macroexpand-printer-bindings*
         (cons '(*print-gensym*)
               swank::*macroexpand-printer-bindings* ) ))
    (swank::apply-macro-expander #'source-transform form-string) ))

(defmacro w/outfile (out filename &body body)
  `(with-open-file (,out
                    ,filename
                    :direction :output
                    :if-exists :supersede)
     ,@body))


(defmacro w/outfile-sjis (out filename &body body)
  `(with-open-file (,out
                    ,filename
                    :direction :output
                    :if-exists :supersede
                    :external-format :sjis)
     ,@body))

(defmacro with-< (spec &body body)
  (etypecase spec
    (cons (destructuring-bind (in filename &rest args)
                              spec
            `(with-open-file (,in ,filename ,@args) ,@body)))
    ((or string pathname)
     `(with-open-file (< ,spec) ,@body))))

(defmacro with-> (spec &body body)
  (etypecase spec
    (cons (destructuring-bind (out filename &rest args)
                              spec
            (let ((args (copy-list args)))
              (remf args :direction)
              (remf args :if-exists)
              `(with-open-file (,out
                                ,filename
                                :direction :output
                                :if-exists :supersede
                                ,@args)
                 ,@body))))
    ((or string pathname)
     `(with-open-file (>
                       ,spec
                       :direction :output
                       :if-exists :supersede)
        ,@body))))

(defmacro with->> (spec &body body)
  (etypecase spec
    (cons (destructuring-bind (out filename &rest args)
                              spec
            (let ((args (copy-list args)))
              (remf args :direction)
              (remf args :if-exists)
              `(with-open-file (,out
                                ,filename
                                :direction :output
                                :if-exists :append
                                ,@args)
                 ,@body))))
    ((or string pathname)
     `(with-open-file (>
                       ,spec
                       :direction :output
                       :if-exists :append)
        ,@body))))

#+sbcl
(defun show-packages (&aux (out *standard-output*))
  (letS* ((p (Elist (sort
                       (list-all-packages) #'string< :key #'package-name)))
            (i (scan-range :from 1)) )
      (Rignore (format out
                       "~4,'0D: ~A ~:[~;~:*~A~]~%"
                       i
                       (package-name p)
                       (package-nicknames p) ))))

;;; --------------------------------------------------------------------------
;;; (nth-value 1 ...) => (\1 ...)
;;; --------------------------------------------------------------------------
(dotimes (i 10)
  (eval `(defmacro ,(intern (format nil "~D" i)) (form)
           `(nth-value ,,i ,form))))

;;; --------------------------------------------------------------------------
;;; ADD-TEST-FN
;;; --------------------------------------------------------------------------
#|(defvar *foo-operators*
  (atap ()
    ;; clパッケージから:testを受け付けるオペレーターを探す
    (do-symbols (sym :cl)
      (when (and (fboundp sym)
                 (member 'test (member '&key (sl:multiple-value-do   (swank::arglist sym)))
                         :key #'princ-to-string :test #'string-equal))
        (push sym it)))))|#

#|(defun get-test-fn (expr)
  (second (member :test expr)))|#

#|(defun add-test-fn (expr test-fn)
  (labels ((*self (expr)
             (destructuring-bind (&optional car &rest cdr) expr
               (cond ((null expr) () )
                     ;;
                     ((consp car)
                      (cons (*self car) (*self cdr)))
                     ;;
                     ((eq 'quote car) expr)
                     ;;
                     ((member car *foo-operators*)
                      (if (get-test-fn expr)
                          expr
                          `(,car ,@(*self cdr) :test ,test-fn)))
                     ;;
                     ('T (cons car (*self cdr)))))))
    (*self expr)))|#

(defmacro with-default-test (test &body body)
  `(progn
     ,@(add-test-fn body test)))

(defmacro maplet ((&rest bindings) &body body)
  `(mapcar (lambda (,@(mapcar #'car bindings))
             ,@body)
           ,@(mapcar #'cadr bindings)))

(defmacro with-output-to-browser ((stream &key (browser "firefox")) &body body)
  (let ((filename (format nil "/tmp/~A.html" (gensym "TEMPFILE-"))))
    `(macrolet ((#0=#:command-output-status (form) `(nth-value 2 ,form)))
       (with-open-file (,stream ,filename :direction :output :if-exists :supersede)
         ,@body)
       (zerop (#0# (kl:command-output "~A ~A" ,browser ,filename))))))

(defmacro with-html-output-to-browser ((out) &body body)
  `(with-output-to-browser (,out)
     (who:with-html-output (,out ,out :prologue T :indent T)
       ,@body)))


(defun fold-tree-right (proc seed tree)
  (labels ((rec (tree seed)
             (cond ((null tree) seed)
                   ((consp tree) (rec (car tree) (rec (cdr tree) seed)))
                   (t (funcall proc tree seed)))))
    (rec tree seed)))


(defmacro coll (&body body)
  (let ((tem (gensym "TEM-"))
        (ans (gensym "ANS-")))
    `(macrolet ((yield (&body body)
                  `(setq ,',tem (cdr (rplacd ,',tem (list (progn ,@body)))))))
       (let* ((,ans (list nil))
              (,tem ,ans))
         ,@body
         (cdr ,ans)))))


#-ecl
(defun gauche-xref->exports (str)
  (mapcar #'kl:ensure-keyword
          (srfi-13:string-tokenize str
                                   (srfi-14:char-set-difference
                                    char-set:graphic
                                    (srfi-14:string->char-set  ",") ))))

#|(defun qq-expand-list (x depth)
  (if (consp x)
      (case (car x)
        ((quasiquote)
         `(list (cons ',(car x) ,(qq-expand (cdr x) (+ depth 1)))))
        ((unquote unquote-splicing)
         (cond ((> depth 0)
                `(list (cons ',(car x) ,(qq-expand (cdr x) (- depth 1)))))
               ((eq 'unquote (car x))
                `(list . ,(cdr x)))
               (:else
                `(append . ,(cdr x)))))
        (otherwise
         `(list (append ,(qq-expand-list (car x) depth)
                        ,(qq-expand (cdr x) depth)))))
      `'(,x)))|#

(defun qq-expand-list (x depth)
  (if (consp x)
      (case (car x)
        ((quasiquote)
         (list (quote list)
               (list 'cons (list (quote quote) (car x))
                     (qq-expand (cdr x) (+ depth 1)))))
        ((unquote unquote-splicing)
         (cond ((> depth 0)
                (list (quote list)
                      (list (quote cons)
                            (list (quote quote)
                                  (car x))
                            (qq-expand (cdr x) (- depth 1)))))
               ((eq (quote unquote) (car x))
                (list* (quote list)
                       (cdr x)))
               (:else
                (list* (quote append)
                       (cdr x)))))
        (otherwise
         (list (quote list)
               (list (quote append)
                     (qq-expand-list (car x) depth)
                     (qq-expand (cdr x) depth)))))
      (list (quote quote)
            (list x))))

#|(defun qq-expand (x depth)
  (if (consp x)
      (case (car x)
        ((quasiquote)
         `(cons ',(car x) ,(qq-expand (cdr x) (+ depth 1))))
        ((unquote unquote-splicing)
         (cond ((> depth 0)
                `(cons ',(car x) ,(qq-expand (cdr x) (- depth 1))))
               ((and (eq 'unquote (car x))
                     (not (null (cdr x)))
                     (null (cddr x)))
                (cadr x))
               (:else
                (error "Illegal"))))
        (otherwise
         `(append ,(qq-expand-list (car x) depth)
                  ,(qq-expand (cdr x) depth))))
      `',x))|#

(defun qq-expand (x depth)
  (if (consp x)
      (case (car x)
        ((quasiquote)
         (list (quote cons)
               (list (quote quote)
                     (car x))
               (qq-expand (cdr x) (+ depth 1))))
        ((unquote unquote-splicing)
         (cond ((> depth 0)
                (list (quote cons)
                      (list (quote quote)
                            (car x))
                      (qq-expand (cdr x) (- depth 1))))
               ((and (eq (quote unquote) (car x))
                     (not (null (cdr x)))
                     (null (cddr x)))
                (cadr x))
               (:else
                (error "Illegal"))))
        (otherwise
         (list (quote append)
               (qq-expand-list (car x) depth)
               (qq-expand (cdr x) depth))))
      (list (quote quote) x)))


(defmacro quasiquote (&whole form expr)
  (if (eq (quote quasiquote) (car form))
      (qq-expand expr 0)
      form))

(defun enable-quasiquote ()
  (set-macro-character #\,
                       (lambda (stream char)
                         (declare (ignore char))
                         (let ((next (peek-char t stream t nil t)))
                           (if (char= #\@ next)
                               (progn
                                 (read-char stream t nil t)
                                 (list (quote unquote-splicing)
                                       (read stream t nil t) ))
                               (list (quote unquote)
                                     (read stream t nil t) )))))
  (set-macro-character #\`
                       (lambda (stream char)
                         (declare (ignore char))
                         (list (quote quasiquote)
                               (read stream t nil t) ))))

(macrolet ((def ()
               `(progn
                  ,@(with-series-implicit-map
                      (collect
                        (let ((a (code-char
                                  (subseries (scan-range :from 65) 0 26))))
                          `(defmacro ,(intern (format nil "^~A" a)) (&body body)
                             `(lambda (,',(intern (string a))) ,@body) )))))))
  (def) )

(defmacro ^_ (&body body)
  `(lambda (_)
     (declare (ignore _))
     ,@body))

(defmacro ^ ((&rest args) &body body)
  `(lambda (,@args)
     ,@body))

(defmacro ^. (&rest clauses)
  `(snow-match:match-lambda ,@clauses ))

(defmacro ^* (&rest clauses)
  `(snow-match:match-lambda* ,@clauses ))

(defmacro with-stack-list ((variable &rest elements) &body body)
  `(let ((,variable (list ,@elements)))
     (declare (dynamic-extent ,variable))
     ,@body))

(defmacro with-stack-list* ((variable &rest elements) &body body)
  `(let ((,variable (list* ,@elements)))
     (declare (dynamic-extent ,variable))
     ,@body))

(defuns findq (item series)
  (let ((ans nil))
    (iterate ((elt series))
      (when (eq item elt)
        (setq ans elt)
        (terminate-producing)))
    ans))

(defuns findzql (item series)
  (let ((ans nil))
    (iterate ((elt series))
      (when (eql item elt)
        (setq ans elt)
        (terminate-producing)))
    ans))


(defuns findz (item series &optional (test #'eql))
  (let ((ans nil))
    (iterate ((elt series))
      (when (funcall test item elt)
        (setq ans elt)
        (terminate-producing)))
    ans))

(de pkg-foo (p1 p2 pred)
  (let* ((ans (list nil))
         (tem ans))
    (do-external-symbols (e1 p1)
      (do-external-symbols (e2 p2)
        (when (funcall pred e1 e2)
          (rplacd tem (setq tem (list e1)))
          (return))))
    (cdr ans)))

(de pkg-difference (p1 p2)
  (pkg-foo p1 p2 #'string/=))

(de pkg-intersection (p1 p2)
  (pkg-foo p1 p2 #'string=))


;;; eof
