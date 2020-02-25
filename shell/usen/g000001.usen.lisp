;;;; g000001.usen.lisp -*- Mode: Lisp;-*- 

(cl:in-package :g000001.usen.internal)
(in-readtable :arc)


;;;

(cl:in-package :cl-user)

(defmacro g000001.usen.internal::with-> (spec &body body)
  (etypecase spec
    (cons (destructuring-bind (out filename &rest args)
                              spec
            (let ((args (copy-list args)))
              (remf args :direction)
              (remf args :if-exists)
              `(with-open-file (,out
                                ,filename
                                :direction :output
                                :if-exists :supersede
                                ,@args)
                 ,@body))))
    ((or string pathname)
     `(with-open-file (>
                       ,spec
                       :direction :output
                       :if-exists :supersede)
        ,@body))))

(cl:in-package :g000001.usen.internal)

(mac w/ns (stp cl:&body body)
  `(xpath:with-namespaces 
       (,(if (acons stp)
             stp
             `("" (stp:namespace-uri (stp:document-element ,stp)))))
     ,@body))

;;; 


(def httpreq (url)
  (babel:octets-to-string (drakma:http-request url
                                               :force-binary T
                                               :user-agent "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; SV1; .NET4.0C; .NET4.0E; .NET CLR 2.0.50727)")
                          :encoding :utf-8))


(def ytq (str)
  (+ "https://www.youtube.com/results?search_query="
     (drakma:url-encode str :utf-8)))


(def usen-jazz-now-playing-list ()
  (drakma:http-request 
   "http://music.usen.com/usencms/search_nowplay1.php?npband=B&npch=31&nppage=yes"
   :user-agent "Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.6; ja-JP-mac; rv:1.9.2.6) Gecko/20100625 Firefox/3.6.6"))


(def usen-jazz-now-playing-list-songs ()
  (let html (usen-jazz-now-playing-list)
    (accum acc
      (ppcre:do-register-groups (item) ("<li.*?>(.*?)</li>" html)
        (acc item)))))


(def usen-jazz-now-plaing-song ()
  (let str (usen-jazz-now-playing-list)
    (ppcre:register-groups-bind (song) 
                                (".*?<ul class='clearfix np-now'><li.*?>(.*?)</li></ul>.*?" str)
      song)))


(def fx (url)
  (system (+ "firefox " url)))


(def vq-url (q)
  #|(+ "http://gdata.youtube.com/feeds/api/videos?vq="
     (drakma:url-encode (cl:map 'cl:string #'fullwidth->ascii q)
                        :utf-8))|#
  (+ "http://gdata.youtube.com/feeds/api/videos?q="
     (drakma:url-encode (cl:map 'cl:string #'fullwidth->ascii q)
                        :utf-8)))

(def ytvq (q)
  (httpreq:vq-url q))


(def afullwidthchar (char)
  (withs (name (cl-unicode:unicode-name char)
               pos (cl:search "FULLWIDTH" name))
    (and pos 
         (cl-unicode:character-named
          (subseq name (+ #.(len "FULLWIDTH ") pos))))))


(def fullwidth->ascii (char)
  (case char
    #.(cl-unicode:character-named "IDEOGRAPHIC SPACE") #\Space
    (or (afullwidthchar char)
        char)))




(def fullwidth-string->ascii-string (str)
  (cl:map 'cl:string #'fullwidth->ascii str))


(def im-feeling-luckey ()
  (withs (song (usen-jazz-now-plaing-song)
          dat (ytvq song)
          stp (cxml:parse dat (stp:make-builder)))
    (w/ns stp
      (iflet nodes (xpath:all-nodes (xpath:evaluate "//entry/link" stp))
             (totem:stp:attribute-value car.nodes "href")
             (fx:ytq song)))))


(def yt-query (title)
  (withs (dat (ytvq title)
          stp (cxml:parse dat (stp:make-builder)))
    (w/ns stp
      (whenlet nodes (xpath:all-nodes (xpath:evaluate "//link" stp))
        (toot:url-decode 
         (stp:attribute-value (or (errsafe (ref nodes 4))
                                  (errsafe (ref nodes 3))
                                  (errsafe (ref nodes 2))
                                  (errsafe (ref nodes 1)))
                              "href"))))))


(def totem (url)
  (case (type url)
    cons (cl:format t "totem ~{--enqueue '~A'~}" url)
    (asdf:run-shell-command "totem '~A'" url)))


(def vlc (url)
  (case (type url)
    cons (asdf:run-shell-command "vlc ~{'~A' ~}" url)
    (asdf:run-shell-command "vlc '~A'" url)))

;(uery:usen-jazz-now-plaing-song)

(def urls-to-xspfs (urls (o outfile 
                            (+ "~/tmp/" (string (cl:get-universal-time)) ".xspf")))
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
                     e)))
         (with (extension (mkextension)
                tracklist (mkelt "trackList" ns)n)
           (on u urls
             (with (id# (tostring (pr index)) 
                    track (mkelt "track" ns)
                    location (mkelt "location" ns))
               (+c location (stp:make-text u))
               (+c track location)
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


#|(def jb ()
  (bt:make-thread (fn () 
                    (vlc
                     (ero:rem nil
                              (map #'yt-query
                                   (ero:usen-jazz-now-playing-list-songs)))))
                  :name (tostring 
                         (pr "JB: ")
                         (time:print-current-time))))|#

(def jb-filter (list)
  (rem [or (no _) 
           (cl:search "UyiGRY8zMOg" _)]
       list))


(def jb ()
  (let xspf-file (+ "/tmp/" (string (cl:get-universal-time)) ".xspf")
    (urls-to-xspfs (ero:jb-filter (map #'yt-query
                                       (usen-jazz-now-playing-list-songs)))
                   xspf-file)
    (bt:make-thread (fn () (vlc ero.xspf-file))
                    :name (tostring 
                           (pr "JB: ")
                           (time:print-current-time)))))


;;; *EOF*
