(in-readtable :arc)

(def ie (url)
  (drakma:http-request url
                       :user-agent "Mozilla/5.0 (compatible, MSIE 11, Windows NT 6.3; Trident/7.0; rv:11.0) like Gecko"))
