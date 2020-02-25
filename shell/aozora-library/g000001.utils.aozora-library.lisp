;;;; g000001.utils.aozora-library.lisp -*- Mode: Lisp;-*- 

(cl:in-package :g000001.utils.aozora-library.internal)


(in-readtable :g1.arc)


;;; kokoro


(define-type aozora
  (:var @url :initable)
  (:var @binary-data)
  (:var @text)
  (:var @rubi-list))


(defmemo kokoro-bin ()
  (drakma:http-request
   "http://www.aozora.gr.jp/cards/000148/files/773_14560.html"
    :force-binary T))


(define-method (aozora setup-binary-data) ()
  (or (assignedp @binary-data)
      (and (= @binary-data
              (drakma:http-request @url :force-binary T))
           T)))


(define-method (aozora setup-text) ()
  (and (no (assignedp @text))
       (= @text
          (apply #'tao:sconc
                 (ppcre:split "\\r\\n"
                              (babel:octets-to-string @binary-data
                                                      :encoding :cp932))))
       T))


(def kokoro ()
  ;;---TODO: sconc
  (apply #'tao:sconc
         (ppcre:split "\\r\\n"
                      (babel:octets-to-string (kokoro-bin)
                                              :encoding :cp932))))


(def rubys ()
  (accum acc
    (ppcre:do-matches-as-strings (ruby "<ruby>.*?</ruby>.{4}"
                                  (kokoro))
      (acc (list (ref (cl:nth-value 1 (ppcre:scan-to-strings "<rb>(.*?)</rb>" ruby)) 0)
                 (ref (cl:nth-value 1 (ppcre:scan-to-strings "<rt>(.*?)</rt>" ruby)) 0)
                 (ppcre:scan-to-strings ".{4}$" ruby))))))


(def kokoro-rubys ()
  (cl:load-time-value (dedup:rubys)))


(define-method (aozora setup-rubi-list) ()
  (cl:flet ((extract-tag (regex item)
              (ref (cl:nth-value 1 (ppcre:scan-to-strings regex item)) 0)))
    (and (no (assignedp @rubi-list))
         (= @rubi-list 
            (accum acc
              (ppcre:do-matches-as-strings (ruby "<ruby>.*?</ruby>.{4}"
                                            @text)
                (acc (list (extract-tag "<rb>(.*?)</rb>" ruby)
                           (extract-tag "<rt>(.*?)</rt>" ruby)
                           (ppcre:scan-to-strings ".{4}$" ruby))))))
         T)))


(def goo-dictionary-url (word)
  (+ "http://dictionary.goo.ne.jp/srch/all/"
     (drakma:url-encode word :utf-8)
     "/m0u/"))


(define-method (aozora :setup) ()
  (=> self 'setup-binary-data)
  (=> self 'setup-text)
  (=> self 'setup-rubi-list)
  (= @binary-data nil)
  self)


(define-method (aozora :stw) ()
  (withs (len (len:kokoro-rubys)
          (w k okuri) (ref @rubi-list (rand len)))
    `(do ,w ,k ,okuri ,goo-dictionary-url.w
         (tw ,(tao:sconc w "(" k ")")))))


(=* meian* 
    (=> (make-instance 
         'aozora
         :@url "http://www.aozora.gr.jp/cards/000148/files/782_14969.html")
        :setup))


(=* kokoro* 
    (=> (make-instance 
         'aozora
         :@url "http://www.aozora.gr.jp/cards/000148/files/773_14560.html")
        :setup))


(def remtag (text)
  (ppcre:regex-replace-all "<.*?>" text ""))


(define-method (aozora :rubi-list) ()
  @rubi-list)


(define-method (aozora :grep-text) (word)
  (let ts (ppcre:split "。" @text)
    (map #'remtag (keep [ppcre:scan word _] ts))))


(def stw ()
  (withs (rubis (=> kokoro* :rubi-list)
          len len.rubis
          (w k okuri) (ref rubis (rand len)))
    `(do ,w ,k ,(car (=> kokoro* :grep-text (+ w ".*?" k )))
         ,goo-dictionary-url.w
         (tw ,(tao:sconc w "(" k ")")))))


;;; jis2004-3

;;(undefine-type 'jis2004)
(define-type jis2004
  (:var @level :initable)
  (:var @source-file :initable)
  (:var @file)
  (:var @raw-data)
  (:var @data)
  (:var @menkuten-unicode-pair :gettable))


(define-method (jis2004 :read-file) ()
  (= @file (kl:read-file-to-string @source-file)))


(define-method (jis2004 :setup-raw-data) ()
  (= @raw-data (ppcre:split "\\s" @file)))


(define-method (jis2004 :setup-data) ()
  (= @data
     (keep [ppcre:scan "^(\\d-\\d{2}-\\d{2}|U\\+.{4,5})$" _]
           @raw-data)))


(define-method (jis2004 :setup-menkuten-unicode-pair) ()
  (= @menkuten-unicode-pair (pair @data)))


(define-method (jis2004 :setup) ()
  (=> self :read-file)
  (=> self :setup-raw-data)
  (=> self :setup-data)
  (=> self :setup-menkuten-unicode-pair)
  self)


(define-method (jis2004 :menkuten-to-unicode) (menkuten)
  (let item (find [is menkuten car._] @menkuten-unicode-pair)
    (and item
         (string:cl:code-char
          (cl:parse-integer (subseq cadr.item 2) :radix 16.)))))


(with (jis2004-3 (=> (make-instance 'jis2004 
                                    :@level 3
                                    :@source-file
                                    (cl:merge-pathnames (cl:make-pathname :name "JIS2004-3"
                                                                          :type "txt")
                                                        (asdf:system-source-directory
                                                         :g000001.utils.aozora-library)))
                     :setup)
       jis2004-4 (=> (make-instance 'jis2004 
                                    :@level 4
                                    :@source-file
                                    (cl:merge-pathnames (cl:make-pathname :name "JIS2004-4"
                                                                          :type "txt")
                                                        (asdf:system-source-directory
                                                         :g000001.utils.aozora-library)))
                     :setup))
 (def menkuten-to-unicode (menkuten)
   (or (=> jis2004-3 :menkuten-to-unicode menkuten)
       (=> jis2004-4 :menkuten-to-unicode menkuten))))


;;; *EOF*

