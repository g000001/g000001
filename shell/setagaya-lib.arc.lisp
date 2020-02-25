(in-package :g1.arc)
(ql:quickload :objectlisp)
(cl:use-package :obj )

(def urlencode-sjis (str)
  (tostring 
   (each c (or (errsafe (babel:string-to-octets str :encoding :cp932))
               #+sbcl (errsafe (sb-ext:string-to-octets str :external-format :sjis))
               )
     (pr "%" (coerce c 'string 16)))))


;;(urlencode-sjis "コンパイラ")
;;"%83%52%83%93%83%70%83%43%83%89"

(=* libweb-setagaya-base-url* "http://libweb.city.setagaya.tokyo.jp")
(=* clis-url* (string libweb-setagaya-base-url* "/clis/search"))


(cl:deftype clis-arg-kind ()
  '(cl:member :title :author :publisher))


(cl:defun clis-search-args (cl:&key (kind1 :title)
                                    (key1 "")
                                    (comp1 3)
                                    (key2 "")
                                    (kind2 :author)
                                    (comp2 3)
                                    (key3 "")
                                    (kind3 :publisher)
                                    (comp3 1)
                                    (cond 1)
                                    (sort 5)
                                    (yearfrom "")
                                    (yearto "")
                                    (maxview 20)
                                    (datafmt 2)
                                    (detailfmt 3)
                                    (rtnpage "/search.shtml"))
  (cl:flet ((conv-kind (kind)
              (case kind
                :title "AB"
                :author "CD"
                :publisher "EF")))
    (tostring
     (pr "?" "ITEM1" "=" (conv-kind kind1) 
         "&" "KEY1" "=" (urlencode-sjis key1)
         "&" "COMP1" "=" comp1
         "&" "KEY2" "=" (urlencode-sjis key2)
         "&" "ITEM2" "=" (conv-kind kind2)
         "&" "COMP2" "=" comp2
         "&" "KEY3" "=" (urlencode-sjis key3)
         "&" "ITEM3" "=" (conv-kind kind3)
         "&" "COMP3" "=" comp3
         "&" "COND" "=" cond
         "&" "SORT" "=" sort
         "&" "YEARFROM" "=" yearfrom
         "&" "YEARTO" "=" yearto
         "&" "MAXVIEW" "=" maxview
         "&" "DATAFMT" "=" datafmt
         "&" "DETAILFMT" "=" detailfmt
         "&" "RTNPAGE" "=" rtnpage))))


(def clis-search (text (o text2) (o text3))
  text2 text3
  (whenlet win (drakma:http-request (string clis-url*
                                            (clis-search-args :key1 text))
                                    :force-binary T)
    (babel:octets-to-string win :encoding :cp932)))


  #|(sb-ext:octets-to-string 
   (or (drakma:http-request (string clis-url*
                                    (clis-search-args :key1 text))
                            :force-binary T)
       (cl:make-array 0 :element-type '(cl:unsigned-byte 8)))
   :external-format :sjis)|#


(def result-list (html)
  (accum a
    (doxpath (node (html->stp html) "//table")
      (a (accum aa
           (doxpath (node node "thead/tr/th")
             (aa (stp:string-value node)))))
      (a
       (accum b
         (doxpath (node node "tbody/tr")
           (b
            (accum c
              (doxpath (node node "td")
                (whenlet win (stp:find-child 
                              "a" node 
                              :key (fn (x) (and (no (isa x 'stp:text))
                                                (stp:local-name x)))
                              :test #'is)
                  (c (stp:attribute-value win "href")))
                (c (stp:string-value node)))))))))))

(cl:eval-when (:compile-toplevel :load-toplevel :execute)
  
  (=* item* (make-obj))


  (=* book* (kindof item*)))


(defobfun (exist book*) (obj:&key* url title author publisher year)
  (have 'url url)
  (have 'title title)
  (have 'author author)
  (have 'publisher publisher)
  (have 'year year))


(defobfun (print book*) ()
  (prn title " " author " " publisher " " year " " url))


(defobfun (info book*) ()
  (string title " " author " " publisher " " year))


(def result-list-to-books (result-list)
  (map (fn ((n k url ttl a p y . rest))
         rest
         (oneof book* 'title ttl 'author a 'publisher p 'year y 'url url))
       result-list))


(def print-result (books)
  (on o books
    (pr index ": ")
    (ask o
      (prn "================================================================")
      (prn title " " author " " publisher " " year)
      (prn libweb-setagaya-base-url* url))))


(def clis-query (text)
  (print-result
   (result-list-to-books 
    (cadr:result-list
     (clis-search text)))))



(def clis-query-url (text)
  (string clis-url* (clis-search-args :key1 text)))


#|(string clis-url* (clis-search-args :key1 "量子"
                                    :key2 "コンピュータ"
                                    :item2 "AB"))|#

#|(string clis-url* (clis-search-args :key1 "パーソナルメディア"
                                    :kind1 :publisher))|#


#|(string clis-url* (clis-search-args :key1 "フッサール"
                                    :kind1 :author))|#

#|(string clis-url* (clis-search-args :key1 "ヴィトゲンシュタ"
                                    :kind1 :author))|#


#|(string clis-url* (clis-search-args :key1 "量子"
                                    :key2 "コンピュータ"
                                    :kind1 :title
                                    :kind2 :title))|#

#|(string clis-url* (clis-search-args :key1 "並列計算"))|#


#|(string clis-url* (clis-search-args :key1 "吉村仁"))|#

#|(cl:print (clis-query "吉村仁"))|#

#|(string clis-url*
        (clis-search-args :key1 "吉村仁" :kind1 :author))|#



#|(cl:print (clis-query "prolog"))|#


#|(cl:print (clis-search "コンパイラ"))|#


#|(string clis-url* (clis-search-args :key1 "rdf"
                                    :key2 "owl"
                                    :kind1 :title
                                    :kind2 :title
                                    ))|#





