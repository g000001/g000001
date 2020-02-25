(in-package :g1.cl) 


;;; https://groups.google.com/forum/?hl=ja&fromgroups=#!topic/comp.lang.lisp/kmyEWDT0QGY
;;; kmp
(defun g1::read-tolerant (&optional (stream *standard-input*) &rest more-args)
  (flet ((prescan (text)
           ;; Do whatever you want to find and fix package prefixes here.
           ;; This is just an example of a trivial hack that injects a
           ;; backslash in front of any colons it sees.
           (with-output-to-string (scanned-str)
             (let ((backslash nil) (string-quotes nil) (vertical-bars nil))
               (dotimes (i (length text))
                 (let ((ch (char text i)))
                   (cond (backslash (setq backslash nil))
                         ((eql ch #\\)
                          (setq backslash t))
                         ((eql ch #\")
                          (setq string-quotes (not string-quotes)))
                         ((eql ch #\|)
                          (setq vertical-bars (not vertical-bars)))
                         ((eql ch #\:)
                          (write-char #\\ scanned-str)))
                   (write-char ch scanned-str)))))))
       (let ((text-to-read
               (with-output-to-string (str)
                 (let ((copy-stream (make-echo-stream stream str))
                       (*read-suppress* t))
                   ;; This call to read is only to get the bounds of
                   ;; the expression to scan
                   (apply #'read copy-stream more-args)))))
         (apply #'read-from-string (prescan text-to-read) more-args)))) 


;;; 

(defmacro closure (bind fn)
  (let* ((vars (eval bind))
         (gvars (mapcar (lambda (v) (gensym (string v))) vars))
         (args (gensym "ARGS-")))
    `(let (,@(mapcar #'list gvars vars))
       (lambda (&rest ,args)
         (declare (dynamic-extent ,args))
         (let (,@(mapcar #'list vars gvars))
           (apply ,fn ,args)))))) 


#|(deff print-in-base-16
      (let ((*print-base* 16.))
        (closure '(*print-base*) 'print)))|#

(setf (fdefinition 'print-in-base-16)
      (let ((*print-base* 16.))
           (closure '(*print-base*) #'print))) 


(defun kill-definition-or-form (string do-kill)
  (let ((form (definition-undefining-form 
                  (make-definition-undefining-form (swank::from-string string))
                  :operator)))
    (cond (do-kill (eval form) form)
          (T form)))) 


(defun make-definition-undefining-form (expr)
  (match expr
    (((:or 'defun 'defgeneric 'defmacro 'arc:def 'arc:mac 'arc:defmemo)
      name arg body ***) 
     body arg 
     name)
    ;; 
    #|(('defgeneric name arg body ***) 
     body arg 
     name)|#
    ;; 
    (('defmethod name (:? keywordp qualifier) ((arg type) ***) body ***)
     body arg 
     (list 'method name qualifier type))
    ;; 
    (('defmethod name (:? keywordp qualifier) (arg ***) body ***)
     body 
     (let ((arg (mapcar (constantly t) arg)))
       `(method ,name ,qualifier ,arg)))
    ;; 
    (('defmethod name ((arg type) ***) body ***)
     body arg
     (list 'method name type ***))
    ;; 
    (('defmethod name (arg ***) body ***)
     body
     (let ((arg (mapcar (constantly t) arg)))
       `(method ,name ,arg))))) 


#|
 (make-definition-undefining-form '(defun foo (n) n n n) )
 (make-definition-undefining-form '(defgeneric foo (n) n n n) )
 (make-definition-undefining-form '(defmethod foo (x y z) n n n) )
 (make-definition-undefining-form '(defmethod foo ((x t) (y t) (z t)) n n n) )
 (make-definition-undefining-form '(defmethod foo :before
                                      ((x a) (y b) (z c)) n n n) )
 (make-definition-undefining-form '(defmethod foo :before
                                      (x y z) n n n) )
|#


(defun definition-undefining-form (form type)
  (case type
    (:operator `(fmakunbound ',form))
    (otherwise (error "unknown type.")))) 


(defun fmakunbound (expr)
  (etypecase expr
    (symbol (cl:fmakunbound expr))
    ((cl:cons (eql cl:method) *) 
     (destructuring-bind (method name &rest qualifier-and-args)
                         expr
       (declare (ignore method))
       (destructuring-bind (qualifier &rest args)
                           qualifier-and-args
         (etypecase qualifier
         (keyword `(remove-method #',name
         (find-method #',name '(,qualifier) 
         (mapcar #'find-class ',args)
         )))
         (cons `(remove-method #',name 
         (find-method #',name '() 
         (mapcar #'find-class ',qualifier)
         ))))
         (let ((name (coerce name 'function)))
           (etypecase qualifier
             (keyword (remove-method name
                                     (find-method name (list qualifier) 
                                                  (mapcar #'find-class 
                                                          (car args)))))
             (cons (remove-method name 
                                  (find-method name '() 
                                               (mapcar #'find-class qualifier)
                                               )))))))))) 


(defclass html ()
  ((url :initform nil :accessor url :initarg :url)
   (stp :initform nil :accessor stp)
   (text :initform nil :accessor text))) 


(defmethod text :before ((html html))
  (when (and (null (slot-value html 'text))
             (stringp (url html)))
    (setf (text html)
          (drakma:http-request (url html))))) 


(defmethod stp :before ((html html))
  (when (and (null (slot-value html 'stp))
             (text html))
    (setf (stp html)
          (chtml:parse (text html)
                       (stp:make-builder))))) 


(defun condition-to-plist (object &rest keys &key &allow-other-keys)
  (loop :with class := (class-of object)
        :with slots := (c2mop:compute-slots class)
        :for slot :in slots
        :for name := (c2mop:slot-definition-name slot)
        :for initarg := (first (c2mop:slot-definition-initargs slot))
        :when (and initarg (slot-boundp object name))
        :nconc `(,initarg ,(slot-value object name)) :into old-keys
        :finally (return `(,(type-of object) ,@keys ,@old-keys)))) 


(defun ?::chicken-apropos-to-uli (str)
  (let ((*readtable* (copy-readtable nil)))
    (setf (readtable-case *readtable*) :preserve)
    (let ((items
           (mapcar (lambda (x)
                     (prog ((pos 0) 
                            (eof (list :eof))
                            (ans '())
                            v)
                        => (multiple-value-setq (v pos)
                                                (read-from-string x 
                                                                  nil
                                                                  eof
                                                                  :start pos))
                           (cond ((eq eof v) 
                                  (return (nreverse ans))))
                           (push v ans)
                           (go =>)))
                   (*:split "\\n" str))))
      (mapcar (lambda (x) 
                (swank/match:match x
                  ((x y z) (format nil
                                   "~A ~A ~A"
                                   x 
                                   (*:mapcar-dotted-list
                                    (lambda (z) 
                                      (*:regex-replace "\\d+$" (string z) "" ))
                                    z)
                                   y))))
              items)))) 


(defmacro <::dl-fc (&body body)
  `(<:dl 
    ,@(do ((f/c body (cddr f/c))
           (ans '() `((<::dt ,(car f/c)) 
                      (<::dd ,(cadr f/c))
                      . ,ans)))
          ((endp f/c) 
           (reverse ans))))) 


#|(defmacro <::dl-fc (&body body)
  `(<:dl ,@(loop :for (dt dl . rest) :on body :by #'cddr
                 :collect `(<:dt ,dt)
                 :collect `(<:dl ,dl))))|# 

 
(defun ?::print-yaml (col &optional (out *standard-output*))
  (fresh-line out)
  (labels ((rec (col indent)
                (etypecase col
                  (STRING (write-string col out))
                  (HASH-TABLE (maphash (lambda (k v)
                                         (format out 
                                                 "~&~V@T~A: "
                                                 (* 2 indent)
                                                 k)
                                         (rec v (1+ indent))
                                         (terpri out))
                                       col))
                  (LIST (dolist (e col)
                          (format out 
                                  "~&~V@T- "
                                  (* 2 indent))
                          (rec e (1+ indent)))
                        (terpri out)))))
    (rec col 0))) 


(eval-when (:compile-toplevel :load-toplevel :execute)
  (defvar G000001.TOOLS.INTERNAL::*DEFUN/T-TAGS* (make-hash-table))
  
  (defun expr-to-md5sum-symbol (expr &optional (pkg *package*))
    (intern (format nil "~{~:@(~X~)~^-~}" 
                    (coerce (md5:md5sum-string (princ-to-string expr))
                            'list))
            pkg))
  
  (defun intersection* (&rest lists)
    (let ((len (length lists)))
      (case len
        (0 '())
        (1 (first lists))
        (otherwise (reduce (lambda (ans x)
                             (intersection ans x :test #'equal))
                           (cdr lists)
                           :initial-value (first lists))))))) 

 
(yaclml::def-html-tag <::u :core :event :i18n) 


#|(?::deftool (:koide :lod) koide-lod ()
  (dolist (u (sort (list
                    "http://blog.livedoor.jp/s-koide/archives/2158814.html"
                    "http://blog.livedoor.jp/s-koide/archives/2159111.html"
                    "http://blog.livedoor.jp/s-koide/archives/2159829.html"
                    "http://blog.livedoor.jp/s-koide/archives/2160172.html"
                    "http://blog.livedoor.jp/s-koide/archives/2160427.html"
                    "http://blog.livedoor.jp/s-koide/archives/2160801.html"
                    "http://blog.livedoor.jp/s-koide/archives/2161112.html"
                    "http://blog.livedoor.jp/s-koide/archives/2161622.html"
                    "http://blog.livedoor.jp/s-koide/archives/2163279.html"
                    "http://blog.livedoor.jp/s-koide/archives/2163885.html"
                    "http://blog.livedoor.jp/s-koide/archives/2164175.html"
                    "http://blog.livedoor.jp/s-koide/archives/2164359.html"
                    "http://blog.livedoor.jp/s-koide/archives/2164379.html"
                    "http://blog.livedoor.jp/s-koide/archives/2164832.html"
                    "http://blog.livedoor.jp/s-koide/archives/2166360.html"
                    )
                   #'string<))
    #|(?:red u)|#
    (princ "-- [")
    (princ u)
    (princ " ")
    (princ (g1::html (g000001.html:get-title u)))
    (princ "]")
    (terpri)))|#


(?::deftool (:koide :cw :chatwork) ?::kd (mesg)
  (cw:message mesg -1))


(?:deftool (:lisphub) ?::lh-event-update (mesg)
  (?:tw (format nil "lisphub.jp イベント更新: ~A http://lisphub.jp/event/" mesg)))



;;; *EOF*
