;;;; g000001.twitter.lisp -*- Mode: Lisp;-*- 

;;(cl:in-package :g000001.twitter.internal)

(cl:in-package :cl-user)


(cl:eval-when (:compile-toplevel :load-toplevel :execute)
  (cl:setq drakma:*drakma-default-external-format* :utf-8)
  (pushnew '("application" . "json") drakma:*text-content-types* 
           :test #'cl:equalp))

(cl:defconstant g000001.twitter.internal::@masso 4412081)

(macrolet
    ((safe-json-bind ((&rest vars) json &body body)
       `(handler-bind ((json:no-char-for-code
                        (lambda (err)
                          (declare (ignore err))
                          (invoke-restart 'json:substitute-char #\〓))))
          (json:json-bind (,@vars) ,json ,@body)))
     (whenlet (var val &body body)
       `(let ((,var ,val))
          (when ,var
            ,@body)))
     (iflet (var val con alt)
       `(let ((,var ,val))
          (if ,var
              ,con
              ,alt)))
     (ttw (message &key re)
       (etypecase message
         (string `(*tw (g000001.ja:encode-tenji ',message) ,re))
         (cons `(*tw ,(string* (mapcar (lambda (s)
                                         (g000001.ja:encode-tenji (string s))) 
                                       message))
                     ,re)))))
  (labels 
      ((flatten (tree)
         (typecase tree
           (NULL '())
           (ATOM (list tree))
           (LIST (append (flatten (car tree))
                         (flatten (cdr tree))))))
       (string* (&rest obj)
         (typecase obj
           (LIST
            (with-output-to-string (out)
              (dolist (x (flatten obj))
                (princ x out))))
           (T obj)))
       (readfile1 (file)
         (with-open-file (in file)
           (read in)))
       (listtab (list)
         (let ((tab (make-hash-table)))
           (loop :for (k v) :in list :do (setf (gethash k tab) v))
           tab))

       (access-token ()
         (let ((keys (listtab (let ((*package* (find-package :g000001.twitter.internal)))
                                (readfile1 "~/.twitter-oauth.lisp")))))
           (oauth:make-access-token 
            :consumer (oauth:make-consumer-token :key (gethash 'consumer-key keys)
                                                 :secret (gethash 'consumer-secret keys))
            :key (gethash 'access-key keys)
            :secret (gethash 'access-secret keys))))

       (string-safe (s)
         (typecase s
           (STRING (or (babel:octets-to-string (babel:string-to-octets s)
                                               :errorp 'nil)
                       ""))
           (T "")))

       (safe-decode-json-from-string (json)
         (handler-bind ((json:no-char-for-code
                         (lambda (err)
                           (declare (ignore err))
                           (invoke-restart 'json:substitute-char #\〓))))
           (json:decode-json-from-string json)))

       (twclient (&key (get "statuses/home_timeline" getsupp) 
                       (? nil)
                       (post nil postsupp))
         (when postsupp 
           (reverse
            (safe-decode-json-from-string 
             (oauth:access-protected-resource 
              (concatenate 'string "https://api.twitter.com/1.1/" post ".json")
              (access-token) 
              :user-parameters ?
              :request-method :post))))
         (when getsupp 
           (reverse
            (safe-decode-json-from-string 
             (oauth:access-protected-resource 
              (concatenate 'string "https://api.twitter.com/1.1/" get ".json")
              (access-token) 
              :user-parameters ?)))))

       (*print-tweet (user-name id user-screen--name in--reply--to--status--id
                                text created--at)
         (let ((babel-encodings:*suppress-character-coding-errors* T))
           (write-string 
            (babel:octets-to-string 
             (babel:string-to-octets 
              (lambda.output:output nil
                (fresh-line)
                "■" (lambda.output:ostring user-name)
                " (?:tw \"@" (lambda.output:ostring user-screen--name) " \" :Re " (lambda.output:ostring id) ") "
                (whenlet re in--reply--to--status--id
                         (lambda.output:ostring "| Re: ") 
                         (lambda.output:ostring re))
                (terpri)
                (lambda.output:ostring (string-safe text))
                (terpri)
                (lambda.output:ostring created--at 80 :right-justify T :pad-char #\.)
                (terpri)
                (terpri)))))))

       (created-at/jst (time-string)
         #+(:or :allegro :ecl) time-string
         #-(:or :allegro :ecl)
         (srfi-19:date->string
          (srfi-19:time-utc->date
           (srfi-19:date->time-utc
            (srfi-19:string->date time-string
                                  "~a ~b ~d ~H:~M:~S ~z ~Y")))
          "~a ~b ~d ~H:~M:~S ~z ~Y"))
       
       (print-tweet (tw)
         (or tw (return-from print-tweet nil))
         #|(prn tw)|#
         (let* ((user-name  (cdr (assoc :name (cdr (assoc :user tw)))))
                (id  (cdr (assoc :id tw)))
                (user-screen--name  (cdr (assoc :screen--name (cdr (assoc :user tw)))))
                (in--reply--to--status--id  (cdr (assoc :in--reply--to--status--id tw)))
                (text  (cdr (assoc :text tw)))
                (created--at  (cdr (assoc :created--at tw))))
           (let ((babel-encodings:*suppress-character-coding-errors* T))
             (write-string 
              (babel:octets-to-string 
               (babel:string-to-octets 
                (lambda.output:output nil
                  (fresh-line)
                  "■" (lambda.output:ostring user-name)
                  " (?:tw \"@" (lambda.output:ostring user-screen--name) " \" :Re " (lambda.output:ostring id) ") "
                  (whenlet re in--reply--to--status--id
                           (lambda.output:ostring "| Re: ") 
                           (lambda.output:ostring re))
                  (terpri)
                  (let ((text (string-safe text)))
                    (lambda.output:ostring 
                     (if (tenji-tweet-p text)
                         (format nil "~&<點> ~A </點>"
                                 #-lispworks7 (g000001.ja:decode-tenji text)
                                 #+lispworks7 text)
                         (format nil "~&~A" text))))
                  (terpri)
                  (lambda.output:ostring (created-at/jst created--at) 80 :right-justify T :pad-char #\.)
                  (terpri)
                  (terpri))))))))

       (showtl (&key (count 50))
         (dolist (tw (twclient :get "statuses/home_timeline"
                               :? `(("count" . ,(string* count)))))
           (print-tweet tw)))

       (last-@masso-tweet ()
         (twclient :get "statuses/user_timeline"
                   :? `(("user_id" . ,(string* g000001.twitter.internal::@masso))
                        ("count" . "1")
                        ("trim_user" . "true")
                        ("include_rts" . "false"))))

       (tweet-id (tw)
         (cdr (assoc :id (car tw))))

       (showl (&key (user "masso") (list "z") (count 50) (filter #'identity))
         (dolist (tw (twclient :get "lists/statuses" 
                               :? `(("slug" . ,list)
                                    ("owner_screen_name" . ,user)
                                    ("count" . ,(string* count)))))
           (when (funcall filter tw)
             (print-tweet tw))))

       (favl (&key (count 20) (filter #'identity))
         (dolist (tw (twclient :get "favorites/list" 
                               :? `(("count" . ,(string* count)))))
           (when (funcall filter tw)
             (print-tweet tw))))

       (users/lookup-id-by-name (screen-name)
         (cdr (assoc :id
                     (car (twclient :get "users/lookup" 
                                    :? `(("screen_name" . ,screen-name)))))))

       (*tw (message re)
         (typecase message
           (string message)
           (symbol (setq message (string* message))))
         (let* ((url 
                 "https://api.twitter.com/1.1/statuses/update.json")
                (status `("status" . ,message))
                (in_reply_to_status_id (and re `(("in_reply_to_status_id" . ,(string* re))))))
           (safe-json-bind (text
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

       (fav (re)
         (twclient :post "favorites/create" 
                   :? `(("id" . ,(string* re))))
         (favl))

       (split (list pos)
         (list (subseq list 0 pos)
               (subseq list pos)))

       (tw (&rest message&re)
         (destructuring-bind (message re) (iflet p (position :re message&re)
                                                 (split message&re p)
                                                 (list message&re nil))
           (*tw (string* message) (cdr re))))

       (twf (&rest message&re)
         (destructuring-bind (message re) (split message&re (or (position :re message&re) 0))
           (tw message)
           (when re (fav re))))

       (mentions (&key (count 10))
         (dolist (tw (twclient :get "statuses/mentions_timeline" 
                               :? `(("count" . ,(string* count)))))
           (print-tweet tw)))

       (tenji-tweet-p (str)
         (some (lambda (c) (<= #x2800 (char-code c) #x28ff))
               str))

       (tws (&rest args)
         (let ((ok? (mapcar #'g000001.ja:strans args)))
           (when (y-or-n-p "~{~A~} " ok?)
             (apply #'twe (mapcar #'g000001.ja:strans args))) ))

       (range (s e)
         (loop :for i :from s :to e :collect i))

       (current-clock-face-char (&optional (ut (get-universal-time)))
         (multiple-value-bind (s m h)
                              (decode-universal-time ut)
           (declare (ignore s))
           (elt g000001.twitter.internal::*clock-faces* (+ (* 2 (mod h 12)) (floor m 30)))))

       (current-clock-face-string (&optional (ut (get-universal-time)))
         (string (current-clock-face-char ut)))

       (twe (&rest message&re)
         (tw
          (string* (apply #'string* message&re)
                   " "
                   (current-clock-face-string)
                   " "
                   " #+:"
                   (string-downcase 
                    (Or (And (Find :clisp *features*)
                             (string* "clisp-" (format nil
                                                       "~D"
                                                       (read-from-string (lisp-implementation-version)))
                                      #+:gnu "/HURD"))
                        (Find :lispworks7.0 *features*)
                        (Find :lispworks6.0 *features*)
                        (Find :lispworks6.1 *features*)
                        (find :lispworks5.1 *features*)
                        (find :lispworks4.4 *features*)
                        (Find :CCL-1.10 *features*)
                        (Find :ccl *features*)
                        (And (Find :sbcl *features*) (string* "sbcl-" (lisp-implementation-version)))
                        (Find :ecl *features*)
                        (Find :armedbear *features*)
                        (Find :ALLEGRO-V8.2 *features*)
                        (Find :ALLEGRO-V8.1 *features*)
                        (Find :ALLEGRO *features*))))))
       
       (con (&rest message&re)
         (*tw
          (string* (apply #'string* message&re)
                   " "
                   (current-clock-face-string)
                   " "
                   " #+:"
                   (string-downcase 
                    (Or (And (Find :clisp *features*)
                             (string* "clisp-" (format nil
                                                       "~D"
                                                       (read-from-string (lisp-implementation-version)))
                                      #+:gnu "/HURD"))
                        (Find :lispworks7.0 *features*)
                        (Find :lispworks6.0 *features*)
                        (Find :lispworks6.1 *features*)
                        (find :lispworks5.1 *features*)
                        (find :lispworks4.4 *features*)
                        (Find :CCL-1.10 *features*)
                        (Find :ccl *features*)
                        (And (Find :sbcl *features*) (string* "sbcl-" (lisp-implementation-version)))
                        (Find :ecl *features*)
                        (Find :armedbear *features*)
                        (Find :ALLEGRO-V8.2 *features*)
                        (Find :ALLEGRO-V8.1 *features*)
                        (Find :ALLEGRO *features*))))
          (tweet-id (last-@masso-tweet))))
)
    #-(or abcl)
    (defvar g000001.twitter.internal::*clock-faces* 
      (let ((clock-faces (mapcan #'list 
                                 (range #x1F550 (+ 11 #x1F550))
                                 (range #x1F55C (+ 11 #x1F55C)))))
        (apply #'vector
               (mapcar #'code-char
                       (append (last clock-faces 2)
                               (butlast clock-faces 2))))))
    #+abcl
    (defvar g000001.twitter.internal::*clock-faces* 
      (let ((clock-faces (mapcan #'list 
                                 (range #x1F550 (+ 11 #x1F550))
                                 (range #x1F55C (+ 11 #x1F55C)))))
        (apply #'vector
               (mapcar (lambda (code)
                         "")
                       (append (last clock-faces 2)
                               (butlast clock-faces 2))))))
    (setf (fdefinition '?::showtl) #'showtl)
    (setf (fdefinition '?::fav) #'fav)
    (setf (fdefinition '?::tw) #'tw)
    (setf (fdefinition '?::mentions) #'mentions)
    (setf (fdefinition '?::current-clock-face-char) #'current-clock-face-char)
    (setf (fdefinition '?::current-clock-face-string) #'current-clock-face-string)
    (setf (fdefinition '?::twe) #'twe)
    (setf (fdefinition '?::con) #'con)
    ))

;;; *EOF*


