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