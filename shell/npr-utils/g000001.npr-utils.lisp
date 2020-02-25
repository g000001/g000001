;;;; g000001.npr-utils.lisp

(cl:in-package :g000001.npr-utils.internal)
(in-readtable :arc)

(5am:def-suite g000001_npr-utils)

(5am:in-suite g000001_npr-utils)

;;; "g000001.npr-utils" goes here. Hacks and glory await!


(def xml->stp (xml)
  (cxml:parse xml (stp:make-builder)))


(def http-case (url)
  (*let (body stat)
        (drakma:http-request url)
    (case stat
      200 body
      nil)))


(cl:define-condition npr-message () ())


(cl:define-condition npr-warning (cl:simple-warning) ())


(def npr-media-query (id)
  (let media-id (string id)
    (http-case
     (+ "http://api.npr.org/query?"
        "id=" media-id
        "&mediaId=" media-id
        "&fields="
        "show," "audio," "multimedia," "parent," "titles," "teasers," "dates,"
        "song," "album," "product," "text"
        "&apiKey=" (cl:load-time-value (readfile1 "~/.npr-api-key"))))))


(def npr-check-query (stp)
  (let mesg (xpath:first-node (xpath:with-namespaces ()
                                (xpath:evaluate "//message" stp)))
    (when (is "warning" (errsafe (stp:attribute-value mesg "level")))
      (warn 'npr-warning 
            :format-arguments (list (stp:string-value mesg))
            :format-control "~&======== NRP Query: ~A~%"))
    stp))


(def npr-media-url (id)
  (cl:check-type id (cl:integer 0 *))
  (withs (stp (npr-check-query:xml->stp:npr-media-query id)
          url (xpath:string-value
               (xpath:first-node
                (xpath:with-namespaces ()
                  (xpath:evaluate "//mp3[@type='mp3']" stp)))))
   (ppcre:regex-replace "\\?.*" url "")))


(def npr-media-download-url (id)
  (+ npr-media-url.id "?dl=1"))

;;; *EOF*
