(IN-PACKAGE :G000001)


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
(defun GITHUB-INSTALL (user-name name &optional (github-files-directory "/share/sys/cl/src/github/"))
  (let* ((temp-filename (gensym "/tmp/github-install-"))
         (stat (kl:run-shell-command "wget --no-check-certificate -O ~A https://github.com/~A/~A/tarball/master"
                                     temp-filename
                                     user-name
                                     name)))
    (or (zerop stat) (error "GITHUB-INSTALL: Something went wrong."))
    (setq stat
          (kl:run-shell-command "tar -zxvf ~A -C ~A"
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

(defun get-title (uri)
  (with-input-from-string (str (decode-jp
                                (drakma:http-request uri
                                                     :force-binary 'T)))
    (do ((line (read-line str nil :eof) (read-line str nil :eof)))
	((eq :eof line))
      (ppcre:register-groups-bind (title)
                                  ("<title>\(.*\)</title>" line)
	(when title
	  (return title))))))

(defun choose-elt (item shtml)
  (collect
    (choose-if (lambda (elt)
                 (and (consp elt)
                      (equal item (car elt)) ))
               (scan-lists-of-lists shtml) )))


(defun title-filter (str)
  (ppcre:regex-replace-all "(&nbsp;|\\n|\\s+)"
                           str
                           ""))

(defun get-title (uri)
  (with-input-from-string (str (decode-jp
                                (drakma:http-request uri
                                                     :force-binary 'T)))
    (first
     (mapcar (kl:compose #'title-filter #'second)
             (choose-elt :title
                         (html-parse:parse-html str))))))

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

(de title+url (url)
  (format nil
          "~A 【 ~A 】"
          (get-title url)
          url))

(de yonderu-tw (&rest urls &aux (no. 0))
  (tw (format nil
              "読んでる→~:{~A:~A 〖 ~A 〗~^ ~}"
              (mapcar (lambda (u)
                        `(,(incf no.) ,(get-title u) ,u))
                      urls))))


(de yonda (url)
  (tw (format nil "読んだ: ~A" (title+url url))))

(defmacro pa (pkg)
  `(in-package ,pkg))

(de ql (name)
  (ql:quickload name))

(de qapropos (name)
  (ql-dist:system-apropos (string-downcase name)))


(de delete-package* (pkg)
  (let* ((pkg (find-package pkg))
         (publ (package-used-by-list pkg)))
    (append (mapc #'delete-package publ)
            (list (delete-package pkg)))))


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
     ,@(mapcar (^e `(<:li ,@e))
               wakatta))
    (<:h3 "やってみたこと")
    (<:ul
     ,@(mapcar (^e `(<:li ,@e))
               yatta))
    (<:h3 "やりたいこと")
    (<:ul
     ,@(mapcar (^e `(<:li ,@e))
               yaritai))
    (<:h3 "思ったこと")
    (<:ul
     ,@(mapcar (^e `(<:li ,@e))
               omotta))
    (<:br)
    "■"))


(de wc (file &key (external-format :utf-8))
  (let ((s (with-open-file (r file :external-format external-format)
             (kl:read-stream-to-string r))))
    (values (count #\Newline s)
            (1+ (count-if #'kl:is-char-whitespace (kl:collapse-whitespace s)))
            (count-if-not #'kl:is-char-whitespace s))))


(defun tform (form)
  (let ((*print-gensym* nil)
        (*gensym-counter* 0))
    (read-from-string
     (prin1-to-string
      (#+sbcl sb-cltl2:macroexpand-all
       #+lispworks walker:walk-form
       (source-transform form))))))
#+sbcl
(defun fun-segment-to-string (fun)
  (with-output-to-string (w)
    (sb-disassem:map-segment-instructions
     (lambda (chunk inst)
       (declare (ignore inst))
       (format w "~X" chunk) )
     (first (sb-disassem:get-fun-segments fun))
     (sb-disassem:make-dstate))))

#+sbcl
(defun inst= (x y)
  (string= (fun-segment-to-string x)
           (fun-segment-to-string y)))

(defmacro w/index (spec body-fn)
  (let ((args (gensym "ARGS-")))
    `(let ((,(car spec) (1- ,(cadr spec))))
       (lambda (&rest ,args)
         (let ((,(car spec) (incf ,(car spec))))
           (apply ,body-fn ,args)) ))))


#+swank
(defun beep ()
  ;;; emacs: slime-enable-evaluate-in-emacs => t
  (swank:eval-in-emacs
   '(let ((visible-bell t)) (beep)))
  nil)


(defun pp-aa (str)
  (with-output-to-browser (out)
    (yaclml:with-yaclml-stream out
      (<:pre :style "font-family:'giko','ＭＳ Ｐゴシック','ＭＳＰゴシック','MSPゴシック','MS Pゴシック';font-size:16px;line-height:17px;"
             (<:format str)))))

(defmacro with-new-readtable (&body body)
  `(let ((*readtable* (copy-readtable nil)))
     ,@body))


(defun make-current-attribute-list-string ()
  (format nil
          ";;;-*- Mode:LISP; Package:~A; Base:~D; readtable: ~S -*-"
          (package-name *package*)
          *read-base*
          (readtable-name *readtable*)))

(declaim (inline maknum munkam))
(defun maknum (obj)
  #+sbcl
  (sb-kernel:get-lisp-obj-address obj)
  #-sbcl 0)

(defun munkam (num)
  #+sbcl
  (sb-kernel:make-lisp-obj num)
  #-sbcl nil)

(defun fintern (fmt &rest args)
  (intern (apply #'format nil fmt args)))

(defun fintern-in-package (pkg fmt &rest args)
  (intern (apply #'format nil fmt args) pkg))

;;; eof
