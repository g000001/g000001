;;;; g000001.chaton.lisp -*- Mode: Lisp;-*- 

(cl:in-package :g000001.chaton.internal)
(in-readtable :arc)


(def drakma (url . args)
  (let drakma:*drakma-default-external-format* :utf-8
    (babel:octets-to-string 
     (coerce (apply #'drakma:http-request url :force-binary T args)
             '(cl:vector (cl:unsigned-byte 8)))
     :encoding :utf-8)))


(let user nil
  (def chaton-login (room)
    (let ret (drakma 
              (string "http://chaton.practical-scheme.net/" room "/apilogin")
              :method :post
              :parameters '(("who" . "drakma")
                            ("s" . "1")))
      (let cl:*readtable* (cl:copy-readtable nil)
        (= (cl:readtable-case cl:*readtable*) :preserve)
        (= user (cl:read-from-string ret))
        user)))
  (def chaton-user ((o room))
    (or user (chaton-login room))))


(def post-chaton-cl (mesg)
  (withs (user  (chaton-user "common-lisp-jp")
          cid   (cdr:assoc '|cid| user))
    (drakma
     "http://chaton.practical-scheme.net/common-lisp-jp/chaton-poster-commonlispjp" 
     :method :post
     :parameters 
     `(("nick" . "g000001")
       ("cid" . ,(string cid))
       ("text" . ,mesg)))))


(def observe-chaton-cl ()
  (let ((\_ . post-uri)
        (\_ . comet-uri)
        (\_ . icon-uri)
        (\_ . room-name)
        (\_ . cid)
        (\_ . pos))
       (chaton-user "common-lisp-jp")
    (drakma comet-uri :parameters `(("s" . "1")
                                    ("c" . ,(string cid))
                                    ("p" . "0")))))


(def chaton-cl-mesgs ()
  (let cl:*package* (cl:find-package :g000001.chaton.internal)
    (each (name time mesg)
        (cdr:assoc 'content (cl:read-from-string (observe-chaton-cl)))
      (prn)
      (prn name ":")
      ;; (time:print-universal-time (kmrcl:posix-time-to-utime:int car.time))
      (prn:kmrcl:posix-time-to-utime:int car.time)
      (prn)
      (prn mesg))))


;;; *EOF*
