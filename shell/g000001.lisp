(in-package :g1.cl)

(eval-when (:execute :load-toplevel :compile-toplevel)
 (setf (fdefinition (intern "SPECIAL-FORM-P" :series))
       #'special-operator-p))

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

(kl:defconstant* max-speed
  '(OPTIMIZE (SAFETY 0) (SPEED 3) (DEBUG 0)))


;(format nil fmt-hr 80 "=")
;=> "================================================================================
;   "


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
  (CL:LOOP :WITH OPEN
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
    ((or cl:string cl:pathname)
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
  (letS* ((p (Elist (cl:sort
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
  (sl:atap ()
    ;; clパッケージから:testを受け付けるオペレーターを探す
    (do-symbols (sym :cl)
      (when (and (fboundp sym)
                 (member 'test (member '&key (sl:multiple-value-do
                                                 (swank::arglist sym)))
                         :key #'princ-to-string :test #'string-equal))
        (push sym it::it)))))|#

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

#|(defmacro with-default-test (test &body body)
  `(progn
     ,@(add-test-fn body test)))|#


(defmacro maplet ((&rest bindings) &body body)
  `(mapcar (lambda (,@(mapcar #'car bindings))
             ,@body)
           ,@(mapcar #'cadr bindings)))


(defmacro with-output-to-browser ((stream &key (browser "firefox")) &body body)
  (let ((filename (format nil "/mc/tmp/~A.html" (gensym "__tempfile-"))))
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


#|(macrolet ((def ()
               `(progn
                  ,@(with-series-implicit-map
                      (collect
                        (let ((a (code-char
                                  (subseries (scan-range :from 65) 0 26))))
                          `(defmacro ,(intern (format nil "^~A" a)) (&body body)
                             `(lambda (,',(intern (string a)))
                                ,@body) )))))))
  (def) )|#


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


;;; eof
