;;;; g000001.twitter.lisp -*- Mode: Lisp;-*- 

(cl:in-package :g000001.twitter.internal)


(in-readtable :arc)


(cl:eval-when (:compile-toplevel :load-toplevel :execute)
  (= drakma:*drakma-default-external-format* :utf-8)
  (pushnew '("application" . "json") drakma:*text-content-types* 
           :test #'cl:equalp))


(def access-token ()
  (let keys (listtab (let cl:*package* (cl:find-package :g000001.twitter.internal)
                       (readfile1 "~/.twitter-oauth.lisp")))
    (oauth:make-access-token 
     :consumer (oauth:make-consumer-token :key keys!consumer-key
                                          :secret keys!consumer-secret)
     :key keys!access-key
     :secret keys!access-secret)))


(def string-safe (s)
  (case (type s)
    string (or (babel:octets-to-string (babel:string-to-octets s)
                                       :errorp 'nil)
               "")
    ""))


(def safe-decode-json-from-string (json)
  (cl:handler-bind ((json:no-char-for-code
                      (fn (err)
                        (cl:declare (cl:ignore err))
                        (cl:invoke-restart 'json:substitute-char #\〓))))
    (json:decode-json-from-string json)))


(cl:defmacro safe-json-bind ((cl:&rest vars) json cl:&body body)
  `(cl:handler-bind ((json:no-char-for-code
                       (fn (err)
                         (cl:declare (cl:ignore err))
                         (cl:invoke-restart 'json:substitute-char #\〓))))
     (json:json-bind (,@vars) ,json ,@body)))



(cl:defun twclient (cl:&key (get "statuses/home_timeline" getsupp) 
                    (? nil)
                    (post nil postsupp))
  (when postsupp 
    (rev:safe-decode-json-from-string 
     (oauth:access-protected-resource 
      (+ "https://api.twitter.com/1.1/" post ".json")
      (access-token) 
      :user-parameters ?
      :request-method :post)))
  (when getsupp 
    (rev:safe-decode-json-from-string 
     (oauth:access-protected-resource 
      (+ "https://api.twitter.com/1.1/" get ".json")
      (access-token) 
      :user-parameters ?))))


(def *print-tweet (user-name id user-screen--name in--reply--to--status--id
                             text created--at)
  (let babel-encodings:*suppress-character-coding-errors* T
    (let mesg (babel:octets-to-string 
               (babel:string-to-octets 
                (output nil
                        (cl:fresh-line)
                        "■" (ostring user-name)
                        " (?:tw \"@" (ostring user-screen--name) " \" :Re " (ostring id) ") "
                        (whenlet re in--reply--to--status--id
                                 (ostring "| Re: ") 
                                 (ostring re))
                        (cl:terpri)
                        (ostring string-safe.text)
                        (cl:terpri)
                        (ostring created--at 80 :right-justify T :pad-char #\.)
                        (cl:terpri)
                        (cl:terpri))))
      ;;#+lispworks7
      '(when (all #'capi:screen-active-p (capi:screens))
        (capi:display-message mesg))
      ;;#-lispworks7
      (cl:write-string mesg))))


(def created-at/jst (time-string)
  #+(:or :allegro :ecl) time-string
  #-(:or :allegro :ecl)
  (srfi-19:date->string
   (srfi-19:time-utc->date
    (srfi-19:date->time-utc
     (srfi-19:string->date time-string
                           "~a ~b ~d ~H:~M:~S ~z ~Y")))
   "~a ~b ~d ~H:~M:~S ~z ~Y"))


(def print-tweet (tw)
  (or tw (cl:return-from print-tweet nil))
  #|(prn tw)|#
  (with (user-name  (cdr (assoc :name (cdr (assoc :user tw))))
         id  (cdr (assoc :id tw))
         user-screen--name  (cdr (assoc :screen--name (cdr (assoc :user tw))))
         in--reply--to--status--id  (cdr (assoc :in--reply--to--status--id tw))
         text  (cdr (assoc :text tw))
         created--at  (cdr (assoc :created--at tw)))
    (let babel-encodings:*suppress-character-coding-errors* T
      (let mesg (babel:octets-to-string 
                 (babel:string-to-octets 
                  (output nil
                          (cl:fresh-line)
                          "■" (ostring user-name)
                          " (?:tw \"@" (ostring user-screen--name) " \" :Re " (ostring id) ") "
                          (whenlet re in--reply--to--status--id
                                   (ostring "| Re: ") 
                                   (ostring re))
                          (cl:terpri)
                          (let text string-safe.text
                            (ostring 
                             (if (tenji-tweet-p text)
                                 (cl:format nil "~&<點> ~A </點>"
                                            (g000001.ja:decode-tenji text))
                                 (cl:format nil "~&~A" text))))
                          (cl:terpri)
                          (ostring created-at/jst.created--at 80 :right-justify T :pad-char #\.)
                          (cl:terpri)
                          (cl:terpri))))
        ;#+lispworks7
        '(when (all #'capi:screen-active-p (capi:screens))
          (capi:display-message mesg))
        ;#-lispworks7
        (cl:write-string mesg)))))


(cl:defun ?::showtl (cl:&key (count 50))
  (each tw (twclient :get "statuses/home_timeline"
                     :? `(("count" . ,string.count)))
    (print-tweet tw)))


(cl:defconstant @masso 4412081)


(def last-@masso-tweet ()
  (twclient :get "statuses/user_timeline"
                   :? `(("user_id" . ,string.@masso)
                        ("count" . "1")
                        ("trim_user" . "true")
                        ("include_rts" . "false"))))

(def tweet-id (tw)
  (cdr:assoc :id car.tw))


(cl:defun showl (cl:&key (user "masso") (list "z") (count 50) (filter #'idfn))
  (each tw (twclient :get "lists/statuses" 
                     :? `(("slug" . ,list)
                          ("owner_screen_name" . ,user)
                          ("count" . ,(string count))))
    (when (_filter tw)
      (print-tweet tw))))


(cl:defun favl (cl:&key (count 20) (filter #'idfn))
  (each tw (twclient :get "favorites/list" 
                     :? `(("count" . ,(string count))))
    (when (_filter tw)
      (print-tweet tw))))


(def users/lookup-id-by-name (screen-name)
  (cdr:assoc :id
             (car:twclient :get "users/lookup" 
                           :? `(("screen_name" . ,screen-name)))))


(def *tw (message re)
  (case (type message)
    string message
    sym (zap #'string message))
  (with (url 
         "https://api.twitter.com/1.1/statuses/update.json"
         status `("status" . ,message)
         in_reply_to_status_id (and re `(("in_reply_to_status_id" . ,string.re))))
    #!C(safe-json-bind (text
                         id
                         in--reply--to--status--id created--at 
                         user.screen--name
                         user.name)
                       (oauth:access-protected-resource 
                         url
                         (access-token)
                         :request-method :post
                         :user-parameters `(,status ,@in_reply_to_status_id))
          (*print-tweet user.name
                        id
                        user.screen--name
                        in--reply--to--status--id 
                        text
                        created--at))))


(cl:defun ?::fav (re)
  (twclient :post "favorites/create" 
            :? `(("id" . ,(string re))))
  (favl))


(def ?::tw message&re
  (let (message re) (iflet p (pos :re message&re)
                      (split message&re p)
                      (list message&re nil))
    (*tw (string message) cdr.re)))


(def twf message&re
  (let (message re) (split message&re (or (pos :re message&re) 0))
    (?::tw message)
    (when re (?::fav re))))


(cl:defmacro ttw (message cl:&key re)
  (cl:etypecase message
    (cl:string `(*tw (g000001.ja:encode-tenji ',message) ,re))
    (cl:cons `(*tw ,(string (map (fn (s)
                                   (g000001.ja:encode-tenji (string s))) 
                              message))
                   ,re))))


(cl:defun ?::mentions (cl:&key (count 10))
  (each tw (twclient :get "statuses/mentions_timeline" 
                     :? `(("count" . ,(string count))))
    (print-tweet tw)))


(def tenji-tweet-p (str)
  (some (fn (c) (<= #x2800 (cl:char-code c) #x28ff))
        str))


(def tws args
  (cl:let ((ok? (map #'g000001.ja:strans args)))
    (when (cl:y-or-n-p "~{~A~} " ok?)
      (apply #'?::twe (map #'g000001.ja:strans args))) ))



#-abcl
(cl:defvar *clock-faces* 
  (cl:let ((clock-faces (cl:mapcan #'list 
                                   (range #x1F550 (+ 11 #x1F550))
                                   (range #x1F55C (+ 11 #x1F55C)))))
    (cl:apply #'cl:vector
              (cl:mapcar #'cl:code-char
                         (cl:append (cl:last clock-faces 2)
                                    (cl:butlast clock-faces 2))))))

#+abcl
(cl:defvar *clock-faces* 
  (cl:let ((clock-faces (cl:mapcan #'list 
                                   (range #x1F550 (+ 11 #x1F550))
                                   (range #x1F55C (+ 11 #x1F55C)))))
    (cl:apply #'cl:vector
              (cl:mapcar (fn (code)
                           "")
                         (cl:append (cl:last clock-faces 2)
                                    (cl:butlast clock-faces 2))))))


(cl:defun ?::current-clock-face-char (cl:&optional (ut (cl:get-universal-time)))
  (cl:multiple-value-bind (s m h)
                          (cl:decode-universal-time ut)
    (cl:declare (cl:ignore s))
    (cl:elt *clock-faces* (+ (* 2 (mod h 12)) (cl:floor m 30))))) 


(cl:defun ?::current-clock-face-string (cl:&optional (ut (cl:get-universal-time)))
  (string (?::current-clock-face-char ut)))


(def random-cat ()
  (ref "🐈🐱🦁🐯🐅🐆" (cl:random 6)))

(def ?::twe/catface mesg
  (?::twe (string (random-cat) (trim mesg 'both))))

(def ?::con/catface mesg
  (?::con (string (random-cat) mesg)))

(def ?::make-|#+| ()
  (string
   "#+:"
   (downcase
    (Or (cl:And (cl:Find :clisp cl:*features*)
                (string "clisp-" (cl:format nil
                                            "~D"
                                            (cl:read-from-string (cl:lisp-implementation-version)))
                        #+:gnu "/HURD"))
        (and (is "7.1.1" (cl:lisp-implementation-version)) :lispworks7.1.1)
        (and (is "7.1.2" (cl:lisp-implementation-version)) :lispworks7.1.2)
        (cl:Find :lispworks7.1 cl:*features*)
        #|(and (cl:Find :lispworks7.1 cl:*features*)
             :lispworks7.0)|#
        (cl:Find :lispworks7.0 cl:*features*)
        (cl:Find :lispworks6.0 cl:*features*)
        (cl:Find :lispwork6s.1 cl:*features*)
        (cl:find :lispworks5.1 cl:*features*)
        (cl:find :lispworks4.4 cl:*features*)
        (cl:Find :CCL-1.10 cl:*features*)
        (cl:Find :ccl cl:*features*)
        (cl:And (cl:Find :sbcl cl:*features*)
                (string "sbcl-" (cl:lisp-implementation-version)))
        (cl:Find :armedbear cl:*features*)
        (cl:Find :ALLEGRO-V8.2 cl:*features*)
        (cl:Find :ALLEGRO-V8.1 cl:*features*)
        (cl:Find :allegro-v10.1 cl:*features*)
        (cl:Find :ALLEGRO cl:*features*)
        (cl:And (cl:Find :ecl cl:*features*)
                (string "ecl-" (cl:lisp-implementation-version)))
        ))))

(def ?::twe/ message&re
  (?:tw
   (string message&re
           #\Newline
           (?::current-clock-face-string)
           " "
           (?::make-|#+|))))


(def tab-or-space (c)
  (in c #\Tab #\Space))

(def dwim-trim-speces (s)
  (map [trim _ 'both] (lines s)))

(def ?::twe message&re
  (?:tw
   (string (?::make-\#+)
           "'|"
           #\Newline
           (dwim-trim-speces car.message&re)
           #\Newline
           (?::current-clock-face-string)
           "|")))

(cl:export
 (def ?::con message&re
    (*tw
     (string message&re
             " "
             (?::current-clock-face-string)
             " "
             " #+:"
             (downcase
              (Or (cl:And (cl:Find :clisp cl:*features*)
                          (string "clisp-" (cl:format nil
                                                      "~D"
                                                      (cl:read-from-string (cl:lisp-implementation-version)))
                                  #+:gnu "/HURD"))
                (cl:Find :lispworks7.0 cl:*features*)
                (cl:Find :lispworks6.0 cl:*features*)
                (cl:Find :lispworks6.1 cl:*features*)
                (cl:find :lispworks5.1 cl:*features*)
                (cl:find :lispworks4.4 cl:*features*)
                (cl:Find :CCL-1.10 cl:*features*)
                (cl:Find :ccl cl:*features*)
                (cl:And (cl:Find :sbcl cl:*features*) (string "sbcl-" (cl:lisp-implementation-version)))
                (cl:Find :ecl cl:*features*)
                (cl:Find :armedbear cl:*features*)
                (cl:Find :ALLEGRO-V8.2 cl:*features*)
                (cl:Find :ALLEGRO-V8.1 cl:*features*)
                (cl:Find :ALLEGRO cl:*features*)
                ))
             )
     (tweet-id:last-@masso-tweet)))
 :?)






;;; *EOF*


