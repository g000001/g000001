;;;; g000001.comic-natalie-utils.lisp

(cl:in-package :g000001.comic-natalie-utils.internal)
(in-readtable :arc)

(def-suite comic-natalie-utils)

(in-suite comic-natalie-utils)

;;; "g000001.comic-natalie-utils" goes here. Hacks and glory await!

(def httpreq (url)
  (babel:octets-to-string 
   (drakma:http-request url
                        :force-binary T
                        :user-agent "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; SV1; .NET4.0C; .NET4.0E; .NET CLR 2.0.50727)")
   :encoding :utf-8))


(def html->stp (string)
  (chtml:parse string (stp:make-builder)))


(mac doxpath ((node stp xpath) cl:&body body)
  `(xpath:with-namespaces (("" (stp:namespace-uri (stp:document-element ,stp))))
     (each ,node (xpath:all-nodes (xpath:evaluate ,xpath ,stp))
       ,@body)))

;;; 


(define-type comic-natalie
  (:var @range (:init '(1)) :initable)
  (:var @index-pages (:init '() ))
  (:var @index-stps)
  (:var @page-urls :gettable)
  (:var @comic-lists :gettable))


(define-type comic 
  (:var @title)
  (:var @author)
  (:var @amazon-link)
  :all-gettable
  :all-settable
  :all-initable)


(define-type comic-list
  (:var @date :initable)
  (:var @url :initable)
  (:var @list)
  :all-gettable)


(define-method (comic :pr) (cl:&optional (out (stdout)))
  (w/stdout out
    (prn @title ": " @author " " @amazon-link)
    (prn)))


(def cleanup-list (str)
  (with (acc '()
         str (trim str 'both))
    (ppcre:do-matches-as-strings (mat "「.*?」\\s*[^「]*" str)
      (ppcre:register-groups-bind (title author)
                                  ("(「.*?」)\\s*([^「]*)" mat)
        (push (list title author) acc)))
    rev.acc))


(define-method (comic-list :setup-list) ()
  (let stp (html->stp:httpreq @url)
    ;; title & author
    (= @list
       (accum acc
         (doxpath (node stp "//div[@id='news-text']/p")
           (whenlet list (cleanup-list (stp:string-value node))
             (each (title author) list
               (acc (make-instance 'comic 
                                   :@title title
                                   :@author author)))))))
    ;; amazon-link
    (doxpath (node stp "//div[@id='news-text']/p/a")
      (each c @list
        (when (is (=> c :@title) (stp:string-value node))
          (=> c :set-@amazon-link (replace-affiliate-id
                                   (stp:attribute-value node "href"))))))
    self))


(define-method (comic-natalie init-index-pages) ()
  (= @index-pages
     (map [httpreq:string "http://natalie.mu/comic/news/list/page/"
                          _
                          "/order_by/date"]
          @range))
  self)


(define-method (comic-natalie init-index-stps) ()
  (= @index-stps (map #'html->stp @index-pages))
  self)


(define-method (comic-natalie init-page-urls) ()
  (= @page-urls
     (accum acc
       (each stp @index-stps
         (doxpath (node stp "//p[@class='news-title']/a") 
           (let text (stp:string-value node)
                (when (findsubseq "本日発売の単行本リスト" text)
                  (acc:list text (+ "http://natalie.mu" 
                                    (stp:attribute-value node "href")))))))))
  self)


(define-method (comic-natalie init-comic-lists) ()
  (= @comic-lists
     (map (fn ((date url)) 
            (=> (make-instance 'comic-list :@date date :@url url)
                :setup-list))
          @page-urls))
  self)


(mac ==> (obj . body)
  `(do ,(reduce (fn (res mesg)
                  `(=> ,res ,mesg))
                (cons obj body))))


(define-method (comic-natalie :init) (cl:&rest ignore)
  ignore
  (==> self 
       'init-index-pages
       'init-index-stps
       'init-page-urls
       'init-comic-lists))


(def comic-natalie-page (n)
  (httpreq:string "http://natalie.mu/comic/news/list/page/" n "/order_by/date"))


(def new-comics (n)
  (accum acc
    (doxpath (node (html->stp:comic-natalie-page n) "//p[@class='news-title']/a") 
      (let text (stp:string-value node)
        (when (findsubseq "本日発売の単行本リスト" text)
          (acc:list text (+ "http://natalie.mu" 
                            (stp:attribute-value node "href"))))))))


(define-method (comic-natalie :print-new-comics) ()
  (each cl @comic-lists
    (prn "================" (=> cl :@date) "================")
    (each c (=> cl :@list)
      (=> c :pr))))


(def replace-affiliate-id (link)
  (ppcre:regex-replace-all "[^/]+?-22/" link "g000001-22/"))


(def print-new-comics (comic-list)
  (cl:format t "~{~{~A: ~A ~A~}~2%~}" comic-list))


(def check-comics ()
  #|(print-new-comics (new-comics-range (range 1 2)))|#
  (let cs (make-instance 'comic-natalie :@range (range 1 3))
    ;(=> cs :get-index-pages)
    ;(=> cs :setup-stp)
    ;(=> cs :setup-page-urls)
    ;(=> cs :extract-title-author)
    (=> cs :print-new-comics)))


;;; *EOF* 
