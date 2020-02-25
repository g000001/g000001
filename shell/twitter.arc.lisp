(in-package :g1.arc)
(in-readtable :g1.arc)

(cl:eval-when (:compile-toplevel :load-toplevel :execute)
  (= drakma:*drakma-default-external-format* :utf-8)
  (pushnew '("application" . "json") drakma:*text-content-types* 
           :test #'cl:equalp))

(def tw-id (tw)
  (case (cl:type-of tw)
    twit:search-ref (twit:search-ref-id tw)
    twit:tweet (twit:tweet-id tw)
    0))


(kl:defun-memo id->image (id)
  (twit::twitter-user-profile-image-url
   (twit:show-user-by-id id)))


(def tweets ()
  (cl:remove-duplicates
   (cl:sort 
    (+ (twit:twitter-op :statuses/home-timeline)
       (twit:twitter-op :statuses/mentions))
    #'>
    :key #'tw-id)
   :key #'tw-id))


(def tw-user-image (tw)
  (case (cl:type-of tw)
    twit:search-ref (id->image 
                     (twit:search-ref-from-user-id tw))
    twit:tweet (id->image (twit:twitter-user-id (twit:tweet-user tw)))
    "???"))


(def linkafy (text)
  (*let (s e) (ppcre:scan "http://\\S+\\b" text)
    (if s
        (do (<:format (subseq text 0 s))
            (let link (subseq text s e)
              (<:a :href link (<:format link)))
            (<:format (subseq text e)))
        (<:format text))))


(def twshow (tw)
  (<:hr)
  (<:li
   (<:img :src (tw-user-image tw))
   (<:small 
    (<:format
     (case (cl:type-of tw)
       twit:search-ref (twit:search-ref-from-user tw)
       twit:tweet (twit:twitter-user-screen-name (twit:tweet-user tw))
       "???"))))
  (<:ul
   (<:li
    (let text (case (cl:type-of tw)
                  twit:search-ref (twit:search-ref-text tw)
                  twit:tweet (twit:tweet-text tw)
                  "???")
      (each line (ppcre:split "\\n" text)
        (errsafe (linkafy line))
        (<:br))))))


;(=* foo* (tweets))

#|(def showtl ()
  (g1:with-output-to-browser (out)
    (yaclml:with-yaclml-stream out
      (<:html
       (<:head)
       (<:body
        (<:ul
         (each tw (tweets) ;; foo*
           (twshow tw))))))))|#


(def access-token ()
  (let keys (listtab (let cl:*package* (cl:find-package :g1.arc)
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


(cl:defun twclient (cl:&key (get "statuses/home_timeline" getsupp) 
                            (? nil)
                            (post nil postsupp))
  (when postsupp 
    (rev:json:decode-json-from-string 
     (oauth:access-protected-resource 
      (+ "https://api.twitter.com/1.1/" post ".json")
      (access-token) 
      :user-parameters ?
      :request-method :post)))
  (when getsupp 
    (rev:json:decode-json-from-string 
     (oauth:access-protected-resource 
      (+ "https://api.twitter.com/1.1/" get ".json")
      (access-token) 
      :user-parameters ?))))


(def *print-tweet (user-name id user-screen--name in--reply--to--status--id
                             text created--at)
  (let babel-encodings:*suppress-character-coding-errors* T
    (cl:write-string 
     (babel:octets-to-string 
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
         (cl:terpri)))))))


(def created-at/jst (time-string)
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
      (cl:write-string 
       (babel:octets-to-string 
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
                              (g1::japanese-tenji-to-hiragana text))
                   (cl:format nil "~&~A" text))))
           (cl:terpri)
           (ostring created-at/jst.created--at 80 :right-justify T :pad-char #\.)
           (cl:terpri)
           (cl:terpri))))))))


(cl:defun ?::showtl (cl:&key (count 50))
  (each tw (twclient :get "statuses/home_timeline"
                     :? `(("count" . ,string.count)))
    (print-tweet tw)))


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
    #!C(json:json-bind (text
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
  (let (message re) (iflet p 
                      (pos :re message&re)
                      (split message&re p)
                      (list message&re nil))
    (cl:etypecase message
      (cl:string (*tw message re))
      (cl:cons (*tw (string message) re)))))


(def twf message&re
  (let (message re) (split message&re (or (pos :re message&re) 0))
    (tw message)
    (when re (fav re))))


(cl:defmacro ttw (message cl:&key re)
  (cl:etypecase message
    (cl:string `(*tw (g1::japanese-tenji-string ',message) ,re))
    (cl:cons `(*tw ,(string (map (fn (s)
                                   (g1::japanese-tenji-string (string s))) 
                              message))
                   ,re))))


(cl:defun ?::mentions (cl:&key (count 10))
  (each tw (twclient :get "statuses/mentions_timeline" 
                     :? `(("count" . ,(string count))))
    (print-tweet tw)))


(def tenji-tweet-p (str)
  (some (fn (c) (<= #x2800 (cl:char-code c) #x28ff))
        str))

#|(defun tws (&rest args)
  (let ((ok? (mapcar #'strans args)))
    (when (y-or-n-p "~{~A~} " ok?)
      (apply #'?::twe (mapcar #'strans args))) ))|#

;;; *EOF*


