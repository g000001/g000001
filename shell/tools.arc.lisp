(in-package :g1.arc) 


(in-readtable :g1.arc) 


(=* reddit-user* "g000001") 


#|(def ?::red (url)
  (w/reddit-login reddit-user*
    (json:decode-json-from-string 
     (reddit-submit (g000001.html:get-title url)  url "lisp_ja"))))|# 


#|(def redtw (url)
  (red url)
  (lisper-blog tu.url))|# 


(def apropos-char-name (name)
  (let name string.name
    (accum acc
      (cl:dotimes (code (trunc (/ cl:char-code-limit 2))) 
        (let char (cl:code-char code)
          (when (cl:search name (cl:char-name char))
            acc.char)))))) 


(def gmemo (url)
  (reddit-login "masso")
  (reddit-submit (g000001.html:get-title url) url "g000001")) 


#|(def htmlout-entry (file)
  (eval 
   `(g1:with-output-to-browser (out)
      (yaclml:with-yaclml-stream out
        ,(g1:with-< (< file)
           (let cl:*package* (cl:find-package :<)
             (cl:read <)))))))|#


(def htmlout-entry (file)
  (*htmlout-entry file :supersede)
  (eval 
   `(g1:with-output-to-browser (out)
      (yaclml:with-yaclml-stream out
        (<:html
            (<:head (<:style #.colorize:*coloring-css*))
          (<:body
              (<:div 
                  (cl:princ 
                   (kl:read-file-to-string 
                    (string "/tmp/" blog-entry-id*))
                   out)
                ))))))) 


(cl:defvar blog-entry-id* 0) 


(def *htmlout-entry (file (o if-exists :error))
  (let xpr (cl:with-open-file (< file)
             (let cl:*package* (cl:find-package :<)
               (let cl:*readtable* (named-readtables:find-readtable :myblog)
                 (cl:read <))))
    
    (*let (text id) (cl:values 
                     (cl:with-output-to-string (out)
                       (yaclml:with-yaclml-stream out
                         (eval xpr)))
                     blog-entry-id*)
          (cl:with-open-file (out #|(string "/home/mc/blog/" id)|#
                                  (string "/tmp/" id)
                                  :direction :output
                                  :if-does-not-exist :create
                                  :if-exists if-exists) 
            (cl:princ text out))))) 


(=* *blog-ut* 0) 

#-lispworks
(def pub-entry (file)
  (let *blog-ut* (cl:get-universal-time)
       (eval 
        `(g1::with-> (out (cl:format nil "/home/mc/blog/~A" *blog-ut*))
           (yaclml:with-yaclml-stream out
             ,(g1:with-< (< file)
                (let cl:*package* (cl:find-package :<)
                     (cl:read <)))))))) 

(def name (obj)
  (case (type obj)
    sym (cl:symbol-name obj)
    char (cl:char-name obj)
    obj)) 


(def code (obj)
  (case (type obj)
    char (cl:char-code obj)
    obj)) 


(def succ (obj)
  (case (type obj)
    char (cl:code-char (+ 1 (cl:char-code obj)))
    string (map #'succ obj)
    num (+ 1 obj))) 


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
;;; npr


(def jazzset-mp3-url (front-page-url)
  (let /re/ (ppcre:create-scanner "http://www.npr.org/(\\d{4})/(\\d{2})/(\\d{2}).*")
    (ppcre:register-groups-bind (y m d)  
                                (/re/ front-page-url)
      (+ "http://pd.npr.org/anon.npr-mp3/npr/js/" y "/" m "/" y m d "_js_01.mp3?dl=1")))) 


(def <::lisp (string)
  (cl:format yaclml:*yaclml-stream*
             "<pre~%>~A</pre~%>"
             (colorize::html-colorization :lisp string))
  (cl:values)) 


(def <::elisp (string)
  (cl:format yaclml:*yaclml-stream*
             "<pre~%>~A</pre~%>"
             (colorize::html-colorization :elisp string))
  (cl:values)) 


(def <::cl (string)
  (cl:format yaclml:*yaclml-stream*
             "<pre~%>~A</pre~%>"
             (colorize::html-colorization :common-lisp string))
  (cl:values)) 


(def <::scheme (string)
  (cl:format yaclml:*yaclml-stream*
             "<pre~%>~A</pre~%>"
             (colorize::html-colorization :scheme string))
  (cl:values)) 


(mac <::pa str
  `(<:p (<:format "　") ,@str)) 


(mac <::cliki (string)
  `(<:a :href ,(string "http://cliki.net/" string) ,string)) 


(mac <::quickdocs (string)
  `(<:a :href ,(string "http://quickdocs.org/" string) ,string)) 


(defmemo gt (url)
  (g000001.html:get-title url)) 


(def <::aa (url)
  (<:a :href url (<:format gt.url))) 


(mac <::uli args
  `(<:ul ,@(map [list '<:li _] args))) 


(mac <::oli args
  `(<:ol ,@(map [list '<:li _] args))) 


(def <::href (url)
  (<:a :href url url)) 


(def tinyurl (url)
  (twit::convert-to-tinyurl url)) 


(def reddit-lisp-ja ()
  (*let (page stat) 
    (drakma:http-request "http://www.reddit.com/r/lisp_ja/")
    (case stat
      200 (let pagestp (chtml:parse page (stp:make-builder))
            (xpath:with-namespaces (("" "http://www.w3.org/1999/xhtml"))
              (each n (xpath:all-nodes (xpath:evaluate "//p[@class='title']" 
                                                       pagestp))
                (prn "- " (stp:string-value n))
                (prn "  " (stp:attribute-value (xpath:first-node (xpath:evaluate "a" n)) 
                                               "href"))
                (prn))))
      stat))) 


;;; ================================================================

(mac w/ns (stp cl:&body body)
  `(xpath:with-namespaces 
       (,(if (acons stp)
             stp
             `("" (stp:namespace-uri (stp:document-element ,stp)))))
     ,@body)) 


;;; ================================================================


(def string-fullwidth-to-ascii (s)
  (text.tr:string-tr s
                     "０１２３４５６７８９ＡＢＣＤＥＦＧＨＩＪＫＬＭＮＯＰＱＲＳＴＵＶＷＸＹＺａｂｃｄｅｆｇｈｉｊｋｌｍｎｏｐｑｒｓｔｕｖｗｘｙｚ　！＠＃＄％＾＆＊（）－−＿＝＋［］｛｝｜；：’′／，．＜＞？″“”＼"
                     "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz !@#$%^&\\*()\\-\\-_=+\\[\\]{}|;:''/,.<>?\"\"\"\\"
                     )) 


;;; ================================================================

(def xspf-to-stp (file)
  (cxml:parse (kl:read-file-to-string file)
              (stp:make-builder))) 


(def extract-tracks (stp)
  (w/ns stp
    (xpath:all-nodes (xpath:evaluate "//track" stp)))) 


(def merge-tracks (files)
  (mappend #'extract-tracks:xspf-to-stp files)) 


(def merge-xspfs (files (o outfile "/tmp/foo.xspf"))
  (cl:flet ((mk@ (value name) (stp:make-attribute value name))
            (mkelt (name ns) (stp:make-element name ns))
            (+@ (elt @) (stp:add-attribute elt @))
            (+c (p c) (stp:append-child p c)))
    (with-> (out outfile)
      (withs (ns "http://xspf.org/ns/0/"
              exns "http://www.videolan.org/vlc/playlist/ns/0/")
       (cl:flet ((mkextension ()
                   (let e (mkelt "extension" ns)
                     (+@ e (mk@ exns "application"))
                     e))
                 (del-extension (parent)
                   (w/ns parent 
                     (each c (xpath:all-nodes
                              (xpath:evaluate "//extension" parent))
                       (stp:delete-child c parent)))))
         (with (extension (mkextension)
                tracklist (mkelt "trackList" ns))
          (on track (merge-tracks files)
            (with (id# (tostring (pr index)) 
                   track (stp:copy track))
             (del-extension track)
             (with (id (mkelt "id" exns)
                    ext (mkextension))
              (+c id (stp:make-text id#))
              (= (stp:namespace-prefix id) "vlc")
              (+c ext id)
              (+c track ext))
             (+c trackList track)
             (let item (mkelt "item" exns)
               (= (stp:namespace-prefix item) "vlc")
               (+@ item (mk@ id# "tid"))
               (+c extension item))))
          (let title (mkelt "title" ns)
            (+c title (stp:make-text (string "playlist-"
                                             (cl:get-universal-time))))
            (let e (mkelt "playlist" ns)
              (stp:add-extra-namespace e "vlc" exns)
              (+@ e (mk@ "1" "version"))
              (+c e title)
              (+c e trackList)
              (+c e extension)
              (stp:serialize (stp:make-document e) 
                             (cxml:make-character-stream-sink out)))))))))) 

 
#|(def redprog (url)
  (unless (reddit-session-user-hash reddit-session*)
    (reddit-login "masso"))
  (reddit-submit (g000001.html:get-title url) url "programming_ja"))|# 


#|(def redtech (url)
  (unless (reddit-session-user-hash reddit-session*)
    (reddit-login "masso"))
  (reddit-submit (g000001.html:get-title url) url "tech_ja"))|# 

 
(def video1*compute-rental-start-day (time-string)
  "一ヶ月経過後の最初の水曜日解禁"
  (withs (ut (time:parse-universal-time:string "30 days from " time-string)
          dow (cl:nth-value 6 (cl:decode-universal-time ut))
          wednesday 2)
   (time:print-universal-time 
    (+ ut (* 24 60 60 (- 7 (mod (- dow wednesday) 7))))))) 


;;; xspfs
(def local-filename-enc (file)
  (cl:format nil
             "file://~{~A~^/~}"
             (map [hunchentoot:url-encode _ :utf-8]
                  (ppcre:split "/" file)))) 


#|(def files-to-xspfs (files (o xspfs (string "/tmp/" (uniq) ".xspfs")))
  (urls-to-xspfs
   (map #'local-filename-enc 
        (map #'cl:namestring files))
   xspfs))|# 


#|(def submit-reddits (sub . us)
  (unless (reddit-session-user-hash reddit-session*)
    (reddit-login "masso"))
  (each u us
    (reddit-submit (g000001.html:get-title u) u sub)))|# 


(let .delicious-user. nil
  (def login-delicious ()
    (let (user . pass) (readfile1 "~/.delicious.sx")
      (= .delicious-user.
         (cl:make-instance 'cl-delicious::delicious-user
                           :username (downcase user)
                           :password (downcase pass)))))
  (def mydelicious ()
    (or .delicious-user. (login-delicious))
    .delicious-user.)) 


(def rename-post-tag (user post newtag oldtag)
  (let drakma:*drakma-default-external-format* :utf-8
    (with (url (cl-delicious::post-href post)
           description (cl-delicious::post-description post)
           dt (cl-delicious::post-time post)
           tags (apply #'+ 
                       (intersperse " " 
                                    (tokens (subst newtag oldtag
                                                   (cl-delicious::post-tag post))))))
      (cl-delicious:add-post user url description :dt dt :tags tags)))) 


#|(def delicious->reddit (tag (o keep? nil))
  (unless (reddit-session-user-hash reddit-session*)
    (reddit-login "g000001"))
  (withs (duser (mydelicious)
          dposts (cl-delicious::all-posts duser :tag tag))
   (on p rev.dposts
     (errsafe  
      (with (tag (cl-delicious::post-tag p)
            url (cl-delicious::post-href p))
        (pr "reddit -> del.icio.us " index ":")
        (prn:reddit-submit (g000001.html:get-title url) url tag)
        (unless keep?
          (rename-post-tag duser
                           p
                           (string "__" tag)
                           tag)))))))|# 


#|(def read-it-later->r/g000001 ((o keep? nil))
  (unless (reddit-session-user-hash reddit-session*)
    (reddit-login "masso"))
  (withs (duser (mydelicious)
          dposts (cl-delicious::all-posts duser :tag "read-it-later"))
   (on p dposts
     (with (tag (cl-delicious::post-tag p)
            url (cl-delicious::post-href p))
      (pr "del.icio.us -> reddit" index ":")
      (prn (errsafe (reddit-submit (g000001.html:get-title url) url "g000001")))
      (unless keep?
        (rename-post-tag duser
                         p
                         (string "__" tag)
                         tag))))))|# 


(def delicious-tag-ensure-private (tag)
  (let duser (mydelicious)
    (each e (cl-delicious::all-posts duser :tag tag)
      (with (url (cl-delicious::post-href e)
                 description (cl-delicious::post-description e)
                 tags (cl-delicious::post-tag e))
        (cl-delicious::add-post duser
                                url
                                description
                                :tags tags
                                :shared "no")
        (prn description "... done"))))) 


(def flush-delicious ()
  (each tag '("programming_ja"
              "tech_ja"
              "lisp_ja")
    (prn tag)
    (delicious->reddit tag))) 


;;; lisphub.jp-events

(def lisphubjp-events ()
  (readfile1 "/l/lisphub.jp/event/events.lisp")) 


(cl:defstruct (event (:type cl:list))
  title date place url description) 


(def lisphubjp-books ()
  (readfile1 "/l/lisphub.jp/book/books.lisp")) 


(cl:defstruct (book (:type cl:list))
  dialect title author date isbn url ja-p description) 


(cl:DEFUN EQUIVALENCE-CLASSES (SET cl:&KEY (TEST (cl:FUNCTION cl:EQL))
                                   (KEY (cl:FUNCTION cl:IDENTITY)))
  "
RETURN: The equivalence classes of SET, via KEY, modulo TEST.
"
  (cl:LOOP
     :WITH CLASSES = '()
     :FOR ITEM :IN SET
     :FOR ITEM-KEY = (cl:FUNCALL KEY ITEM)
     :FOR CLASS = (CAR (cl:MEMBER ITEM-KEY CLASSES
                               :TEST TEST :KEY (cl:FUNCTION cl:SECOND)))
     :DO (IF CLASS
             (cl:PUSH ITEM (cl:CDDR CLASS))
             (cl:PUSH (LIST :CLASS ITEM-KEY ITEM ) CLASSES))
     :FINALLY (cl:RETURN (cl:MAPCAR (cl:FUNCTION CDDR) CLASSES)))) 


(def lisphubjp-events-sxp->html ((o out (stdout)))
  (yaclml:with-yaclml-stream out
    (each y (map [cons (subseq (event-date:car _) 0 4) _]
                 (equivalence-classes (cl:sort (lisphubjp-events) #'< :key #'event-date)
                                      :test (fn (x y)
                                              (is (subseq x 0 4) (subseq y 0 4)))
                                      :key #'event-date)) 
      (<:h2 :id car.y (<:format "~A" car.y))
      (<:dl
          (each e cdr.y
            (<:dt (<:format event-date.e))
            (<:dd (<:a :href event-url.e 
                       (<:format event-title.e)
                       (<:format " (~A)" event-place.e)))))))) 


(def amazon-link (isbn)
  (if t
      (string "http://www.amazon.co.jp/exec/obidos/ASIN/"
              (rem #\- isbn)
              "/lisphub-22/ref=nosim")
      (string "http://www.amazon.co.jp/dp/"
              (rem #\- isbn)))) 


(def lisphubjp-books-sxp->html ((o out (stdout)))
  (let books (cl:sort (lisphubjp-books) #'< :key #'book-date)
    (yaclml:with-yaclml-stream out
      (each y (map [cons (subseq (book-date:car _) 0 4) _]
                   (equivalence-classes books
                                        :test (fn (x y)
                                                (is (subseq x 0 4) (subseq y 0 4)))
                                        :key #'book-date)) 
        (<:h2 :id car.y (<:format "~A" car.y))
        (<:dl
         (each e cdr.y
           (when book-ja-p.e
             (let translatedp (isa book-ja-p.e 'string)
               (<:dt :class "pubdate"(<:format book-date.e))
               (<:dd 
                (<:format "(~A) " book-dialect.e)
                (<:a :href (if (is "#" book-url.e)
                               (amazon-link book-isbn.e)
                               book-url.e)
                     (<:format book-title.e))
                (<:format " | ~A " book-author.e)
                (when (no:empty book-isbn.e)
                  (<:format "(isbn~A)" book-isbn.e))
                (when translatedp
                  (let orig (books-find-by-isbn book-ja-p.e books)
                    (<:ul
                     (<:li (<:format " (原書:")
                           (<:a :href (if (is "#" book-url.orig)
                                          (amazon-link book-isbn.orig)
                                          book-url.orig)
                                (<:format book-title.orig)
                                #|(<:format " (~A)" book-isbn.orig)|#
                                )
                           (<:format ")")))))
                (awhen book-description.e
                  (case (type it)
                    cons (eval `(<:ul (<:li ,it)))
                    string (<:ul (<:li (<:format "~A" it)))))))))))))) 


(def instant-store-isbn ()
  (let books (cl:sort (lisphubjp-books) #'< :key #'book-date)
    (each b rev.books
      (when (and book-ja-p.b (no (empty book-isbn.b)))
        (when (isnt "-" book-isbn.b)
          (prn (subst "" "-" book-isbn.b))))))
  (prn "日本のLisp関連本全部")
  (prn "日本で出版されてAmazonで入手できる本を網羅")) 


;; (instant-store-isbn)

;; 400007685XC3355
;; 4766510364C3055
;; 9784873115870
;; 9784274069130
; clojure script9784873116129


;; 日本のLisp関連本全部
;; 日本で出版されてAmazonで入手できる本を網羅


;; (subst "" "-" "foo-bar")

(def books-find-by-isbn (isbn books)
  (let isbn (rem #\- isbn)
    (find [is isbn (rem #\- book-isbn._)] books))) 


(def lisphubjp-top-new-books ((o out (stdout)))
  (yaclml:with-yaclml-stream out
    (<:hr)
    (<:h3 "最新Lisp書籍")
    (<:dl 
     (each e (firstn 5 (cl:sort (lisphubjp-books) #'> :key #'book-date)) 
       (when book-ja-p.e 
         (<:dt (<:format book-date.e))
         (<:dd (<:a :href book-url.e (<:format "~A | ~A" 
                                               book-title.e
                                               book-author.e)))))))) 


(def lisphubjp-top-new-events ((o out (stdout)))
  (let today (cl:format nil "~{~2,'0,D~^-~}" (date))
    (yaclml:with-yaclml-stream out
      (<:hr)
      (<:h3 "Lisp勉強会/イベント情報")
      (each e (cl:sort (lisphubjp-events) #'< :key #'event-date) 
        (when (<= today event-date.e)
          (<:dt (<:format event-date.e))
          (<:dd (<:a :href event-url.e 
                     (<:format event-title.e)
                     (<:format " (~A)" event-place.e)))))))) 


(def lisphubjp/event ()
  (g1:with-> "/l/lisphub.jp/event/index.html"
    (w/stdout cl:>
      (prn (kl:read-file-to-string "/l/lisphub.jp/event/1.txt"))
      (lisphubjp-events-sxp->html)
      (prn (kl:read-file-to-string "/l/lisphub.jp/event/2.txt"))))) 


(def lisphubjp/book ()
  (g1:with-> "/l/lisphub.jp/book/index.html"
    (w/stdout cl:>
      (prn (kl:read-file-to-string "/l/lisphub.jp/book/1.txt"))
      (lisphubjp-books-sxp->html)
      (prn (kl:read-file-to-string "/l/lisphub.jp/book/2.txt"))))) 


(def lisphubjp-impls ()
  (readfile1 "/l/lisphub.jp/implementation/implementations.lisp")) 


(cl:defstruct (impl (:type cl:list))
  dialect name author date ver url description) 


(def lisphubjp/implementation ()
  (g1:with-> "/l/lisphub.jp/implementation/index.html"
    (w/stdout cl:>
      (prn (kl:read-file-to-string "/l/lisphub.jp/implementation/1.txt"))
      (lisphubjp-impl-sxp->html)
      (prn (kl:read-file-to-string "/l/lisphub.jp/implementation/2.txt"))))) 


(def lisphubjp-impl-sxp->html ((o out (stdout)))
  (let impls (cl:sort (lisphubjp-impls) #'< :key #'impl-date)
    (yaclml:with-yaclml-stream out
      (each y (map [cons (subseq (impl-date:car _) 0 4) _]
                   (equivalence-classes impls
                                        :test (fn (x y)
                                                (is (subseq x 0 4) (subseq y 0 4)))
                                        :key #'impl-date)) 
        (<:h2 :id car.y (<:format "~A" car.y))
        (<:dl
         (w/table indent
           (each e cdr.y
             #|(<:dt :class "release-date"(<:format impl-date.e))|#
             (if (indent impl-name.e)
                 (++ (indent impl-name.e))
                 (= (indent impl-name.e) 0))
             (<:dt (<:a :href impl-url.e
                        (if (is 0 (indent impl-name.e))
                            (cl:princ
                             (string
                              "<u>"
                              (n-of (indent impl-name.e) "&nbsp;")
                              impl-name.e
                              "</u>")
                             yaclml:*yaclml-stream* )
                            (cl:princ
                             (string
                              (n-of (indent impl-name.e) "&nbsp;") impl-name.e)
                             yaclml:*yaclml-stream* )))
                   (<:format " ~A" impl-ver.e))
             (<:dd :class "impl-name"
                   (cl:princ (string
                              (n-of (indent impl-name.e) "&nbsp;")
                              "(" impl-dialect.e ")") 
                             yaclml:*yaclml-stream* )
                   (<:format " (~A)" impl-author.e))
             (and impl-description.e
                  (<:dd (<:ul (<:li (<:format "~A" impl-description.e)))))))))))) 


(def lisphubjp/index ()
  (g1:with-> "/l/lisphub.jp/index.html"
    (w/stdout cl:>
      (prn (kl:read-file-to-string "/l/lisphub.jp/1.txt"))
      (lisphubjp-top-new-books)
      (lisphubjp-top-new-events)
      (prn (kl:read-file-to-string "/l/lisphub.jp/2.txt"))))) 


(cl:defstruct (proj (:type cl:list)) 
  name url description) 


(def lisphubjp-wanted-sxp->html ((o out (stdout)))
  (let ps (readfile1 "/l/lisphub.jp/wanted/wanted.lisp")
    (yaclml:with-yaclml-stream out
      (each p ps
        (<:hr)
        (<:h3 (<:a :href proj-url.p (<:format proj-name.p)))
        (whenlet ds proj-description.p
          (<:ul
           (each d ds
             (if (acons d)
                 (<:li (eval d))
                 (<:li (<:format d)))))))))) 


(def lisphubjp/wanted ()
  (g1:with-> "/l/lisphub.jp/wanted/index.html"
    (w/stdout cl:>
      (prn (kl:read-file-to-string "/l/lisphub.jp/wanted/1.txt"))
      (lisphubjp-wanted-sxp->html)
      (prn (kl:read-file-to-string "/l/lisphub.jp/wanted/2.txt"))))) 


(def build-lisphubjp ()
  (lisphubjp/index)
  (lisphubjp/event)
  (lisphubjp/book)
  (lisphubjp/wanted)
  (lisphubjp/implementation)
  nil) 


(def uplisphubjp ()
  (build-lisphubjp)
  (system "/l/lisphub.jp/sync")) 


(def blank-poss (s)
  (let blankc (cl-unicode:character-named "BRAILLE_PATTERN_BLANK")
    (accum acc
      (on c s
        (when (is blankc c)
          acc.index))))) 


(def skip-cp (str idxs)
  (string 
   (accum acc
     (on c str
       (unless (mem index idxs) acc.c))))) 


(def compbb (string)
  (withs (lines (tokens string #\Newline)
          common-blanks (reduce #'cl:intersection (map #'blank-poss lines))
          blank? (cl-unicode:character-named "BRAILLE_PATTERN_BLANK"))
    (tostring 
     (prall (map [skip-cp (trim _ 'end blank?) common-blanks] lines)
            ""
            #\Newline)))) 


(def html-tables->lists (html)
  (accum acc
    (g1.xpath:doxpath (table (g1.xpath:html->stp html) "//table/tbody")
      (acc 
       (stp:map-children 'cons
                         (fn (tr)
                           (stp:map-children 'cons
                                             #'string 
                                             tr))
                         table))))) 


(def html-lists->lists (html)
  (accum acc
    (g1.xpath:doxpath (table (g1.xpath:html->stp html) "//ul")
      (acc 
       (stp:map-children 'cons
                         (fn (tr)
                           (stp:map-children 'cons
                                             #'string 
                                             tr))
                         table))))) 


;;; *EOF* 


