;;;; g000001.twitter.lisp -*- Mode: Lisp;-*- 

(cl:in-package :g000001.twitter.internal)


(in-readtable :arc)


(cl:eval-when (:compile-toplevel :load-toplevel :execute)
  (= drakma:*drakma-default-external-format* :utf-8)
  (pushnew '("application" . "json") drakma:*text-content-types* 
           :test #'cl:equalp))


(cl:defmacro defutil (name args cl:&body body)
  `(do (cl:export ',(cl:intern (string name) :?) :?)
       (def ,(cl:intern (string name) :?) ,args ,@body)))


(cl:defmacro defutilfun (name (cl:&rest args) cl:&body body)
  `(do (cl:export ',(cl:intern (string name) :?) :?)
       (cl:defun ,(cl:intern (string name) :?) ,args ,@body)))


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
  (read-json-from-string json))


(defutilfun twclient (cl:&key (get "statuses/home_timeline" getsupp) 
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


(def created-at/jst (time-string)
  #+(:or :allegro :ecl) time-string
  #-(:or :allegro :ecl)
  (date->string
   (time-utc->date
    (date->time-utc
     (string->date time-string
                   "~a ~b ~d ~H:~M:~S ~z ~Y")))
   "~a ~b ~d ~H:~M:~S ~z ~Y"))


(def print-tweet (tw)
  (or tw (cl:return-from print-tweet nil))
  (with (user-name  (getjso* "user.name" tw)
         id  (getjso* "id" tw)
         user-screen_name  (getjso* "user.screen_name" tw)
         in_reply_to_status_id  (getjso* "in_reply_to_status_id" tw)
         text  (getjso* "text" tw)
         created_at  (getjso* "created_at" tw))
    (let babel-encodings:*suppress-character-coding-errors* T
      (let mesg (babel:octets-to-string 
                 (babel:string-to-octets 
                  (output nil
                    (cl:fresh-line)
                    "■" (ostring user-name)
                    " (?:tw \"@" (ostring user-screen_name) " \" :Re " (ostring id) ") "
                    (whenlet re in_reply_to_status_id
                      (ostring "| Re: ") 
                      (ostring re))
                    (cl:terpri)
                    (let text string-safe.text
                      (ostring 
                       (if (tenji-tweet-p text)
                           (fstring "~&<點> ~A </點>"
                                    (g000001.ja:decode-tenji text))
                           (fstring "~&~A" text))))
                    (cl:terpri)
                    (ostring created-at/jst.created_at 80 :right-justify T :pad-char #\.)
                    (cl:terpri)
                    (cl:terpri))))
        ;#+lispworks7
        '(when (all #'capi:screen-active-p (capi:screens))
          (capi:display-message mesg))
        ;#-lispworks7
        (cl:write-string mesg)))))


(defutilfun showtl (cl:&key (count 50))
  (each tw (?::twclient :get "statuses/home_timeline"
                     :? `(("count" . ,string.count)))
    (print-tweet tw)))


(def @masso () "4412081")


(def last-@masso-tweet ()
  (?::twclient :get "statuses/user_timeline"
              :? `(("user_id" . ,(@masso))
                   ("count" . "1")
                   ("trim_user" . "true")
                   ("include_rts" . "false"))))


(def tweet-id (tw)
  (cdr:assoc :id car.tw))


(defutilfun showl (cl:&key (user "masso") (list "z") (count 50) (filter #'idfn))
  (each tw (?::twclient :get "lists/statuses" 
                     :? `(("slug" . ,list)
                          ("owner_screen_name" . ,user)
                          ("count" . ,(string count))))
    (when (_filter tw)
      (print-tweet tw))))


(defutilfun favl (cl:&key (count 20) (filter #'idfn))
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
  (with (url "https://api.twitter.com/1.1/statuses/update.json"
         status `("status" . ,message)
         in_reply_to_status_id (and re `(("in_reply_to_status_id" . ,string.re))))
    (cl:print
     `(oauth:access-protected-resource 
       ,url
       ,(access-token)
       :request-method :post
       :user-parameters (,status ,@in_reply_to_status_id)))
    (let tw (safe-decode-json-from-string
             (oauth:access-protected-resource 
              url
              (access-token)
              :request-method :post
              :user-parameters `(,status ,@in_reply_to_status_id)))
      (print-tweet tw))))


(defutilfun fav (re)
  (twclient :post "favorites/create" 
            :? `(("id" . ,(string re))))
  (favl))


(defutil tw message&re
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


(defutilfun mentions (cl:&key (count 10))
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


(defutilfun current-clock-face-char (cl:&optional (ut (cl:get-universal-time)))
  (cl:multiple-value-bind (s m h)
                          (cl:decode-universal-time ut)
    (cl:declare (cl:ignore s))
    (cl:elt *clock-faces* (+ (* 2 (mod h 12)) (cl:floor m 30)))))


(defutilfun current-clock-face-string (cl:&optional (ut (cl:get-universal-time)))
  (string (?::current-clock-face-char ut)))


(def random-cat ()
  (ref "🐈🐱🦁🐯🐅🐆" (cl:random 6)))


(defutil twe/catface mesg
  (?::twe (string (random-cat) (trim mesg 'both))))


(defutil con/catface mesg
  (?::con (string (random-cat) mesg)))


(defutil make-|#+| ()
  (string
   "#+:"
   (downcase
    (Or (cl:And (cl:Find :clisp cl:*features*)
                (string "clisp-" (fstring
                                  "~D"
                                  (cl:read-from-string (cl:lisp-implementation-version)))
                        #+:gnu "/HURD"))
        (and (is "8.0.0" (cl:lisp-implementation-version)) :lispworks8.0.0)
        (and (is "8.0.1" (cl:lisp-implementation-version)) :lispworks8.0.1)
        (and (is "7.1.1" (cl:lisp-implementation-version)) :lispworks7.1.1)
        (and (is "7.1.2" (cl:lisp-implementation-version)) :lispworks7.1.2)
        (cl:Find :lispworks7.1 cl:*features*)
        #|(and (cl:Find :lispworks7.1 cl:*features*)
             :lispworks7.0)|#
        (cl:Find :lispworks7.0 cl:*features*)
        (cl:Find :lispworks6.0 cl:*features*)
        (cl:Find :lispworks6.1 cl:*features*)
        (cl:find :lispworks5.1 cl:*features*)
        (cl:find :lispworks4.4 cl:*features*)
        (cl:Find :CCL-1.10 cl:*features*)
        (cl:Find :ccl cl:*features*)
        (cl:And (cl:Find :sbcl cl:*features*)
                (string "sbcl-" (cl:lisp-implementation-version)))
        (cl:Find :armedbear cl:*features*)
        (cl:Find :ALLEGRO-V8.2 cl:*features*)
        (cl:Find :ALLEGRO-V8.1 cl:*features*)
        (cl:Find :ALLEGRO-CL-EXPRESS cl:*features*)
        (cl:Find :allegro-v10.1 cl:*features*)
        (cl:Find :ALLEGRO cl:*features*)
        (cl:And (cl:Find :ecl cl:*features*)
                (string "ecl-" (cl:lisp-implementation-version)))
        ))))


(defutil twe-string message&re
  (string message&re
          #\Newline
          (?::current-clock-face-string)
          " "
          (?::make-|#+|)))


(defutil twe/ message&re
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


(defutil twe message&re
  (when #+lispworks (capi:confirm-yes-or-no "~A" message&re)
        #-lispworks (SWANK:Y-OR-N-P-IN-EMACS "~A" message&re)
    (?:tw
     (string (?::make-\#+)
             "'|"
             #\Newline
             message&re
             #\Newline
             (?::current-clock-face-string)
             "|"))))


(defutil con message&re
  (*tw
   (string message&re
           " "
           (?::current-clock-face-string)
           " "
           " #+:"
           (downcase
            (Or (cl:And (cl:Find :clisp cl:*features*)
                        (string "clisp-" 
                                (fstring "~D"
                                         (cl:read-from-string
                                          (cl:lisp-implementation-version)))
                                #+:gnu "/HURD"))
                (cl:Find :lispworks7.0 cl:*features*)
                (cl:Find :lispworks6.0 cl:*features*)
                (cl:Find :lispworks6.1 cl:*features*)
                (cl:find :lispworks5.1 cl:*features*)
                (cl:find :lispworks4.4 cl:*features*)
                (cl:Find :CCL-1.10 cl:*features*)
                (cl:Find :ccl cl:*features*)
                (cl:And (cl:Find :sbcl cl:*features*)
                        (string "sbcl-" (cl:lisp-implementation-version)))
                (cl:Find :ecl cl:*features*)
                (cl:Find :armedbear cl:*features*)
                (cl:Find :ALLEGRO-V8.2 cl:*features*)
                (cl:Find :ALLEGRO-V8.1 cl:*features*)
                (cl:Find :ALLEGRO cl:*features*)
                ))
           )
   (tweet-id:last-@masso-tweet)))


;;; *EOF*
