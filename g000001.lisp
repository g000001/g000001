(in-package :g1)
(in-readtable :tao)

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

;(format nil fmt-hr 80 "=")
;=> "================================================================================
;   "


;; CR
(!(symbol-function 'cr) #'identity)

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
  (LOOP :WITH OPEN
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
  (defun mexp (form)
    (let ((symtab (count-symbol-names
                   (remove-duplicates
                    (uninterned-symbols
                     (sb-cltl2:macroexpand-all form))))))
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
       (sb-cltl2:macroexpand-all form))))

  (defun mexp-string (form)
    (write-to-string (mexp (read-from-string form)))) )


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

#|(defmacro with-default-test (test &body body)
  `(progn
     ,@(add-test-fn body test)))|#

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


;; eof
