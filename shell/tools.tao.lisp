;;;-*- Mode:LISP; Package:ROOT.USER.G000001.TAO; Base:10; Readtable:G1.TAO; Coding: utf-8 -*-
(in-package :g1.tao)
(in-readtable :g1.tao)


#|(DEFVAR *TWITTER-USERS* () )|#

#+ALLEGRO
(DEFUN QUIT (&OPTIONAL CODE &KEY NO-UNWIND QUIET)
  (CL-USER::EXIT CODE :NO-UNWIND NO-UNWIND :QUIET QUIET))

;; そのうち https対応したい
#|(DEFUN GITHUB-INSTALL (USER-NAME NAME)
  (ASDF-INSTALL:INSTALL
   (FORMAT NIL
           "http://github.com/~A/~A/tarball/master"
           USER-NAME
           NAME)))|#
#-asdf2
(defun GITHUB-INSTALL (user-name name)
  (let* ((temp-filename (gensym "/tmp/asdf-install-"))
         (stat (kl:run-shell-command "wget --no-check-certificate -O ~A https://github.com/~A/~A/tarball/master"
                                     temp-filename
                                     user-name
                                     name)))
    (or (zerop stat) (error "GITHUB-INSTALL: Something went wrong."))
    (asdf-install:install temp-filename)))

#+asdf2
(de github-install (user-name name 
                    &opt (github-files-directory "/share/sys/cl/src/github/"))
  (let* ((temp-filename (gensym "/tmp/github-install-"))
         (stat (kl:run-shell-command "wget --no-check-certificate -O ~A https://github.com/~A/~A/tarball/master"
                                     temp-filename
                                     user-name
                                     name)))
    (or (zerop stat) (error "GITHUB-INSTALL: Something went wrong."))
    (!stat (kl:run-shell-command "tar -zxvf ~A -C ~A"
                                 temp-filename
                                 github-files-directory))
    (or (zerop stat) (error "GITHUB-INSTALL: Untar failed."))
    (asdf:initialize-source-registry)))


#|(DEFUN PRINT-ALL-TWEETS ()
  (LET ((ANS () ))
    (DOLIST (USER *TWITTER-USERS*)
      (LET ((TWIT:*TWITTER-USER* USER))
        (SETQ ANS
              (NCONC (twit:twitter-op :friends-timeline)
                     ANS))))
    (TWIT:PRINT-TWEETS
     (SORT (DELETE-DUPLICATES ANS :KEY #'TWIT::TWEET-ID)
           #'<
           :KEY #'TWIT::TWEET-ID))
    NIL))|#

#|(IN-PACKAGE :TWIT)
#+SBCL (PROGN
  ;; patch
  ;; バイナリで受けないとこけることがある
  (defun get-tinyurl (url)
    "Get a TinyURL for the given URL. Uses the TinyURL API service.
   (c) by Chaitanaya Gupta via cl-twit"
    (multiple-value-bind (body status-code)
        (funcall *http-request-function*
                 *tinyurl-url*
                 :parameters `(("url" . ,url))
                 :force-binary 'T)
      (if (= status-code +http-ok+)
          (SB-EXT:OCTETS-TO-STRING body)
          (error 'http-error
                 :status-code status-code
                 :url url
                 :body body)))))
 (IN-PACKAGE :G000001)
|#

#|(defun get-title (uri)
  (with-input-from-string (str (decode-jp
                                (drakma:http-request uri
                                                     :force-binary 'T)))
    (do ((line (read-line str nil :eof) (read-line str nil :eof)))
	((eq :eof line))
      (ppcre:register-groups-bind (title)
                                  ("<title>\(.*\)</title>" line)
	(when title
	  (return title))))))|#


(defun str (&rest args)
  (format nil "~{~A~^ ~}" args))

;;; LispWorksだと文字化け(なんでだろう)base-charの扱い?
#|(de title+url (url)
  (str (get-title url)
       "〖" url "〗"))|#

;;;; (de title+url (url)
;;;;   (format nil
;;;;           "~A 〖 ~A 〗"
;;;;           (get-title url)
;;;;           url))

#+(or)
(progn
  (defparameter *tweet-file*
    (merge-pathnames
     (make-pathname :name "TWEET" :type "TXT" :case :common)
    (user-homedir-pathname)))
  
  
 (de open-tweet ()
   (kl:run-shell-command "/usr/bin/firefox file://~A" (namestring *tweet-file*)))
 
 
 (defun tw (&rest strings)
   (with-open-file (out *tweet-file*
                        :if-does-not-exist :create
                        :if-exists :append
                        :direction :output)
     (let ((title (with-output-to-string (out)
                    (time:print-current-date out)))
           (tweet (format nil "~{~A~^ ~}~2%" strings)))
          (princ title out)
       (terpri out)
       (princ tweet out)
       (ignore-errors (drakma:http-request "http://twitter.com"))
       (notify-send title tweet)
       (cl:length tweet)))))

;; "➊➋➌➍➎➏➐➑➒➓"


(defparameter *parens*
  (remove-duplicates 
   (append
    (list "«»" "‘’"
          "‚‛" "“”"
          "„‟" "‹›"
          "❛❜" "❮❯"
          "❝❞" "〝〝" "〞〞"
          "〟〟"
          "＂＂"
          ;; quotes
          )
    (list 
     "[]" "{}" "⁅⁆" "〈〉" "❬❭" "❰❱" "❲❳" "❴❵" "⟦⟧" "⟨⟩" "⟪⟫" "⟬⟭" "⦃⦄" "⦇⦈" "⦉⦊"
     "⦋⦌" "⦍⦎" "⦏⦐" "⦑⦒" "⦓⦔" "⦕⦖" "⦗⦘" "⧼⧽" "⸂⸃" "⸄⸅" "⸉⸊" "⸌⸍" "⸜⸝" "⸢⸣" "⸤⸥"
     "⸦⸧" "〈〉" "《》" "「」" "『』" "【】" "〔〕" "〖〗" "〘〙" "〚〛" "﹛﹜" "﹝﹞" "［］" "｛｝" "｢｣")
    (list "()" "⁽⁾" "₍₎" "❨❩" "❪❫" "⟮⟯" "⦅⦆" "⸨⸩" "﴾﴿" "﹙﹚" "（）" "｟｠")
    (list
     ;; 
     "◟◞"
     "◜◝"
     "◖◗"
     ;; math
     "⩻⩼"
     "⩹⩺"
     "⫹⫺"
     "⟦⟧"
     "⟨⟩"
     "⟪⟫"
     "⟬⟭"
     "⟮⟯"
     "⦃⦄"
     "⦅⦆"
     "⦇⦈"
     "⦉⦊"
     "⦋⦌"
     "⦍⦎"
     "⦏⦐"
     "⦑⦒"
     "⦗⦘"
     "⫷⫸" 
     ;; apl
     "⍃⍄"
     ;; moon
     "☾☽"
     ;; dingbats
     "❨❩" 	
     "❪❫"
     "❬❭"
     "❮❯"
     "❰❱"
     "❲❳"
     "❴❵"
     ;; 
     "（）"
     "()"
     "（）"
     "｟｠"
     "⸨⸩"
     "「」"
     "｢｣"
     "『』"
     "[]"
     "［］"
     "〚〛"
     "⟦⟧"
     "{}"
     "｛｝"
     "〔〕"
     "❲❳"
     "〘〙"
     "⟬⟭"
     "<>"
     "〈〉"
     "〈〉"
     "⟨⟩"
     "《》"
     "⟪⟫"
     "＜＞"
     "≪≫"
     "«»"
     "‹›"
     "【】"
     "〖〗"
     "⌈⌉"
     "⌊⌋"
     ))
   :test #'string=))




(de random-paren ()
  (with-< (in "/dev/urandom" :element-type '(unsigned-byte 8))
    (dotimes (i (random 50)) (read-byte in))
    (dotimes (i (+ (read-byte in)
                   (mod (get-universal-time) 1000)))
      (make-random-state))
    (read-byte in))
  (let ((len (length *parens*)))
    (elt *parens* (random len ))))


(de title+url (url)
  (format nil
          "~A 【 ~A 】"
          (g000001.html:get-title url)
          url))


(de ?::tu (url)
  (let ((paren (random-paren)))
    (format nil
            "~A ~A ~A ~A"
            (g000001.html:get-title url)
            (elt paren 0)
            url
            (elt paren 1))))


(defun yonderu-tw (&rest urls &aux (no. 0))
  (?:tw (format nil
              "読んでる→~:{~A:~A 〖 ~A 〗~^ ~}"
              (mapcar (lambda (u)
                        `(,(incf no.) ,(g000001.html:get-title u) ,u))
                      urls))))


(defun yonda (url &optional (comment ""))
  (?:tw (format nil
              "読んだ: ~A ~A" (title+url url) comment)))


(de qapropos (name)
  (ql-dist:system-apropos (string-downcase name)))


(de ?::delete-package* (pkg)
  (let* ((pkg (find-package pkg))
         (publ (package-used-by-list pkg)))
    (append (mapc #'delete-package publ)
            (list (delete-package pkg)))))


#-lispworks
(defmacro diary (&key
                   ((:pre pre))
                   ((:w wakatta))
                   ((:done yatta))
                   ((:y yaritai))
                   ((:o omotta)))
  `(<:body
    ,@pre
    (<:h3 "分かったこと")
    (<:ul
     ,@(mapcar (lambda (e) `(<:li ,@e))
               wakatta))
    (<:h3 "やってみたこと")
    (<:ul
        ,@(mapcar (lambda (e) `(<:li ,@e))
               yatta))
    (<:h3 "やりたいこと")
    (<:ul
        ,@(mapcar (lambda (e) `(<:li ,@e))
               yaritai))
    (<:h3 "思ったこと")
    (<:ul
        ,@(mapcar (lambda (e) `(<:li ,@e))
               omotta))
    (<:br)
    "■"))


(defun wc (file &key (external-format :utf-8))
  (let ((s (with-open-file (r file :external-format external-format)
             (kl:read-stream-to-string r))))
    (values (count #\Newline s)
            (1+ (count-if #'kl:is-char-whitespace (kl:collapse-whitespace s)))
            (count-if-not #'kl:is-char-whitespace s))))

(de wc-stream (stream)
    (let ((s (kl:read-stream-to-string stream)))
      (values (count #\Newline s)
              (1+ (count-if #'kl:is-char-whitespace (kl:collapse-whitespace s)))
              (count-if-not #'kl:is-char-whitespace s))))



(de tform (form)
  (let ((*print-gensym* nil)
        (*gensym-counter* 0))
    (read-from-string
     (prin1-to-string
      (#+sbcl sb-cltl2:macroexpand-all
       #+lispworks walker:walk-form
       (source-transform form))))))


#+sbcl
(de fun-segment-to-string (fun)
  (with-output-to-string (w)
    (sb-disassem:map-segment-instructions
     (lambda (chunk inst)
       (declare (cl:ignore inst))
       (format w "~X" chunk) )
     (first (sb-disassem:get-fun-segments fun))
     (sb-disassem:make-dstate))))


#+sbcl
(de ?::inst= (x y)
  (string= (fun-segment-to-string x)
           (fun-segment-to-string y)))


(defmacro w/index (spec body-fn)
  (let ((args (gensym "ARGS-")))
    `(let ((,(car spec) (1- ,(cadr spec))))
       (lambda (&rest ,args)
         (let ((,(car spec) (!!1+ !,(car spec))))
           (apply ,body-fn ,args)) ))))


#+swank
(eval-when (:compile-toplevel :load-toplevel :execute)
  (de ?::beep ()
    ;; emacs: slime-enable-evaluate-in-emacs => t
    (swank:eval-in-emacs
     '(let ((visible-bell t)) (beep)))
    nil)
  
  (setf (fdefinition 'beep) #'?::beep))


(defmacro with-standard-readtable (&body body)
  `(let ((*readtable* (copy-readtable nil)))
     ,@body))


(defun ql (name &rest args)
  (asdf:initialize-source-registry)
  (with-standard-readtable
    (cl:apply #'ql:quickload name args)))


(de make-current-attribute-list-string ()
  (format nil
          ";;;-*- Mode:LISP; Package:~A; Base:~D; Readtable:~A; Coding: utf-8 -*-"
          (package-name *package*)
          *read-base*
          (readtable-name *readtable*)))


(declaim (inline maknum munkam))
(de maknum (obj)
  #+sbcl
  (sb-kernel:get-lisp-obj-address obj)
  #-sbcl 0)


(de munkam (num)
  #+sbcl
  (sb-kernel:make-lisp-obj num)
  #-sbcl nil)


(defun fintern (fmt &rest args)
  (intern (cl:apply #'format nil fmt args)))


(defun fintern-in-package (pkg fmt &rest args)
  (intern (cl:apply #'format nil fmt args) pkg))


;;; http://enlivend.livejournal.com/36650.html
(defmacro using ((&rest packages) &body body)
  (let ((packages (mapcar 'find-package packages)))
    (labels ((symbol-try (symbol package)
               (multiple-value-bind (symbol status)
                                    (find-symbol (symbol-name symbol) package)
                 (when (eq status :external)
                   ;; being lazy here about foo:nil
                   symbol )))
             (symbol (symbol)
               (let ((possibles (remove nil (mapcar (lambda (package) (symbol-try symbol package)) packages))))
                 (cond ((cdr possibles)
                        (error "Symbol ~a exported from more than one package: ~{~a~^, ~}"
                               symbol (mapcar 'package-name possibles)))
                       (possibles
                        (car possibles) ))))
             (form (form)
               (cl:loop for thing in form collect
                                       (cond ((symbolp thing)
                                              (or (symbol thing)
                                                  thing ))
                                             ((consp thing)
                                              (form thing) )
                                             (t thing) ))))
      (let ((expansion (form body)))
        (if (cdr expansion)
            `(progn ,@expansion)
            (car expansion) )))))


#+sbcl
(defun ?::notify-send (title mesg &key (timeout 10)
                                 (icon "/home/mc/lisp/lisplogo_alien_256.png")
                                 (urgency :normal))
  (sb-ext:run-program "/usr/bin/X11/notify-send"
                      (list "-u" (string-downcase urgency)
                            "-t" (princ-to-string timeout)
                            "-i" icon
                            "--"
                            title
                            mesg)))


;;; find-unbalanced-parentheses
(declaim (ftype (function (t &optional t) (or t integer))
                g1:find-unbalanced-parentheses)
         (ftype (function (stream t) boolean)
                comment-p))


(defun g1:find-unbalanced-parentheses (file &optional (coding-system :utf-8-unix))
  (let ((external-format (coding-system-to-external-format coding-system)))
    (with-open-file (in file :external-format external-format)
      (let ((*read-eval* nil)
            (*readtable* (copy-readtable)) ;inherit
            (last-pos 0) )
        ;; no readtime eval
        (set-dispatch-macro-character #\# #\. (constantly nil))
        ;; no package maker
        (set-macro-character #\: (constantly nil))
        (handler-case (do ((e (cl:read in)
                              (cl:read in) ))
                          (nil)
                        (!last-pos (file-position in)) )
          (end-of-file ()
            (file-position in last-pos)
            (cond ((peek-char t in nil)
                   (or (comment-p in last-pos)
                       (- (compute-cursor-position in
                                                   (file-position in) ))))
                  (T T) ))
          (reader-error ()
            (compute-cursor-position in
                                     (file-position in) )))))))

;;; FIXME
(de comment-p (stream orig-pos)
  (do ((comment-found (list nil))
       (c (read-char stream nil stream)
          (read-char stream nil stream))
       (ans '() (cons c ans)))
      ((eq c stream)
       (let* ((leftover (coerce (nreverse ans) 'cl:string)))
         (if (eq comment-found
                 (ignore-errors
                   (read-from-string leftover nil comment-found)))
             T
             (progn (file-position stream orig-pos)
                    (read-char stream nil)
                    nil))))))


(de coding-system-to-external-format (&opt (coding-system :utf-8-unix))
  (car (rassoc coding-system
               #+sbcl swank/sbcl::*external-format-to-coding-system*
               #+ccl swank/ccl::*external-format-to-coding-system*
               :test (lambda (x y)
                       (member x y :test #'string-equal)))))


#|(defun compute-cursor-position (file raw-pos external-format)
  (with-open-file (in file :element-type '(unsigned-byte 8))
    (let ((seq (make-array raw-pos :element-type '(unsigned-byte 8))))
      (read-sequence seq in)
      (cl:length (babel:octets-to-string seq :encoding external-format)))))|#


(de compute-cursor-position (stream raw-pos)
  (file-position stream 0)
  (do ((cnt 0 (1+ cnt)))
      ((<= raw-pos (file-position stream)) cnt)
    (read-char stream nil)))


;;; ================================================================
;;(defftype frob-lisp-conditional-string (cl:string) cl:string)
;;(defftype frob-lisp-conditional (t) t)
;;(defftype type-predicate-p (cl:symbol) cl:symbol)
;;(defftype cond->typecase (cl:cons) cl:cons)


(de frob-lisp-conditional-string (string)
  (let ((string-downcase-or-never 
         (if (string= (string-downcase string) string)
             #'string-downcase
             #'identity)))
    (funcall string-downcase-or-never
             (write-to-string
              (frob-lisp-conditional (read-from-string string))
              :right-margin 20))))


(de frob-lisp-conditional (expr)
  (match expr
    ;; if -> foo
    ((cl:if pred-a a (cl:if pred-b b c))
     `(cl:cond (,pred-a ,a)
               (,pred-b ,b)
               (cl:T ,c)))
    (('cl:if pred ('cl:progn . thens) nil)
     `(cl:when ,pred  . ,thens))
    (('cl:if pred ('cl:progn . thens))
     `(cl:when ,pred . ,thens))
    (('cl:if pred then nil)
     `(cl:and ,pred ,then))
    (('cl:if pred then)
     `(cl:and ,pred ,then))
    (('cl:if pred pred else)
     `(cl:or ,pred ,else))
    (('cl:if pred ('cl:progn . then) ('cl:progn . else))
     `(cl:cond (,pred ,@then)
               (cl:T ,@else)))
    (('cl:if pred nil ('cl:progn . else))
     `(cl:and (cl:not ,pred) (cl:progn ,@else)))
    (('cl:if pred then ('cl:progn . else))
     `(cl:cond (,pred ,then)
               (cl:T ,@else)))
    (('cl:if pred ('cl:progn . then) else)
     `(cl:cond (,pred ,@then)
               (cl:T ,else)))
    (('cl:if pred nil pred)
     `(cl:progn ,pred nil))
    (('cl:if pred nil else)
     `(cl:and (not ,pred) ,else))
    ;; cond -> foo
    (('cl:cond (pred then) (cl:t else))
     `(cl:if ,pred ,then ,else))
    (('cl:cond . clauses)
     (cond->typecase (cons 'cl:cond clauses)))
    (expr expr)))


(de type-predicate-p (name)
  (cdr (assoc name
              '((realp . real)
                (floatp . float)
                (integerp . integer)
                (streamp . stream)
                (readtablep . readtable)
                (vectorp . vector)
                (characterp . character)
                (packagep . package)
                (simple-string-p . simple-string)
                (complexp . complex)
                (stringp . string)
                (simple-vector-p . simple-vector)
                (consp . cons)
                (rationalp . rational)
                (listp . list)
                (simple-bit-vector-p . simple-bit-vector)
                (numberp . number)
                (functionp . function)
                (pathnamep . pathname)
                (symbolp . symbol)
                (sequencep . sequence)
                (arrayp . array)
                (hash-table-p . hash-table)
                (bit-vector-p . bit-vector)
                (random-state-p . random-state)
                (atom . atom)
                (null . null)
                (keywordp . keyword)))))


(de cond->typecase (expr)
  (flet ((same-obj-p (clauses)
             (let ((objs '()))
               (dolist (c clauses)
                 (when (consp (car c))
                   (!!cons (cadar c) !objs) ))
               (and (remove-duplicates objs :test #'equal)
                    t )))
           (every-type-predicate-p (clauses)
             (every (lambda (c)
                      (if (consp (car c))
                          (type-predicate-p (caar c))
                          (eq t (car c)) ))
                    clauses )))
      (destructuring-bind (cond . clauses)
                          expr
        (unless (and (eq 'cond cond)
                     (same-obj-p clauses)
                     (every-type-predicate-p clauses) )
          (return-from cond->typecase expr) )
        `(typecase ,(cadaar clauses)
           ,@(mapcar (lambda (c)
                       (cons (or (and (consp (car c))
                                      (type-predicate-p (caar c)) )
                                 (and (eq 't (car c)) 'otherwise) )
                             (cdr c)
                             ) )
                     clauses)))))


(de function-type (function-name)
  #+sbcl (sb-introspect:function-type function-name)
  #-sbcl :not-implemented)


(defmacro disarm (fname)
  (destructuring-bind (_function (type) &rest _rest)
                      (function-type fname)
    (declare (cl:ignore _function _rest))
    (let ((arg (gensym "arg-")))
      `(lambda (,arg)
         (and (typep ,arg ',type) (,fname (the ,type ,arg)))))))


#|(defftype disarm (function) t)|#
#|(defun disarm (fn)
  (destructuring-bind (_function (type) &rest _rest)
                      (sb-introspect:function-type fn)
    (declare (cl:ignore _function _rest))
    (lambda (arg)
      (and (typep arg type) (funcall fn arg)))))|#


(de result-type (expr)
  (match expr
    (('values type '&optional) type)
    (expr expr)))


(de ?::cloogle (1st)
  #+sbcl
  (let ((ans (make-array 0 :fill-pointer 0 :adjustable T)))
    (dolist (p (list-all-packages))
      (do-external-symbols (s p)
        (when (fboundp s)
          (match (sb-introspect:function-type s)
            (('function ((:? (lambda (x) (eq x 1st)) 1st)) res)
             (vector-push-extend (list s 1st '-> (result-type res))
                                 ans) )
            (('function ((:? (lambda (x) (eq x 1st)) 1st) . rest) res)
             rest
             (vector-push-extend (list s 1st ':... '-> (result-type res))
                                 ans) )
            (expr expr) ))))
    (map nil
         (lambda (e) (format t
                             "~(~A~) (~(~A~)) :: ~{~A~^ ~}~%"
                             (car e)
                             (package-name (symbol-package (car e)))
                             (cdr e)))
         (cl:sort (delete-duplicates ans :test #'equal)
                  #'string< :key #'car)))
  #-sbcl :not-implemented)

;; CR
(eval-when (:compile-toplevel :load-toplevel :execute)
  (!(symbol-function 'cr) #'identity))


#|(de pr (&rest args)
  (princ
   (with-output-to-string (out)
     (mapc (lambda (x) (princ x out)) args))))|#

(defmacro with-output-to-browser ((stream &key (browser "firefox")) &body body)
  (let ((filename (format nil "/a/~A.html" (gensym "__tempfile-"))))
    `(macrolet ((#0=#:command-output-status (form) `(nth-value 2 ,form)))
       (with-open-file (,stream ,filename :direction :output :if-exists :supersede)
         ,@body)
       (zerop (#0# (kl:command-output "~A ~A" ,browser ,filename))))))

#|(de prn (&rest args)
  (apply #'pr args)
  (terpri))|#


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


(progn
  ;;; emacs: slime-enable-evaluate-in-emacs => t
  (de g1::emacs-yes-or-no-p (&optn (format-string " ") arguments)
    (swank:eval-in-emacs `(yes-or-no-p ,(format nil format-string arguments))))
  
  
  (de g1::emacs-y-or-n-p (&optn (format-string " ") arguments)
    (swank:eval-in-emacs `(y-or-n-p ,(format nil format-string arguments)))))

;;; eof
