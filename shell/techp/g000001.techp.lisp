;;;; g000001.techp.lisp -*- Mode: Lisp;-*- 

(cl:in-package :g000001.techp.internal)
(in-readtable :arc)


(cl:defclass techp-session (drakma:cookie-jar) () )


(=* techp-session* (cl:make-instance 'techp-session))


(=* techp-user-login-info-file*
    (cl:merge-pathnames (cl:make-pathname :name ".TECHP-LOGIN" 
                                          :case :common)
                      (cl:user-homedir-pathname) ))


(def techp-post (url params)
  (let drakma:*drakma-default-external-format* :utf-8
    (drakma:http-request url 
                         :method :post
                         :cookie-jar techp-session*
                         :user-agent "Firefox" 
                         :parameters params)))


(def techp-login (username)
  (*let (body stat)
        (techp-post (+ "https://" username)
                    (cl:acons "api_type" "json"
                              (w/infile in techp-user-login-info-file*
                                (cl:read in) )))
    (and (is 200 stat)
         #!c(json:json-bind (json.data.modhash)
                            (babel:octets-to-string body)
              (= (techp-session-user-hash techp-session*)
                 json.data.modhash )))))


(def techp-submit (title url sr (o uh (techp-session-user-hash techp-session*)) (o kind "link"))
  (babel:octets-to-string
   (techp-post "http://"
                (cl:pairlis '("title" "url" "sr" "uh" "kind")
                            (list title url sr uh kind) ))))


;;; *EOF*
