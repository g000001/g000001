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
    (cons (prog1 pkg (delete-package pkg))
          (mapc #'delete-package publ))))

;;; eof
