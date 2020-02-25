(cl:in-package :g000001.ja.internal.arc)
(in-readtable :arc)


(def 跳 (url)
  (*let (shoten stat)
        (drakma:http-request "http://xn--vt3a.jp/api"
                             :parameters (cl:acons "url" url '() ))
    (if (is 200 stat)
        shoten
        url)))

(with (katakana
       "ァアィイゥウェエォオカガキギクグケゲコゴサザシジスズセゼソゾタダチヂッツヅテデトドナニヌネノハバパヒビピフブプヘベペホボポマミムメモャヤュユョヨラリルレロヮワヰヱ
ヲンヴーヽヾ"
       hiragana
       "ぁあぃいぅうぇえぉおかがきぎくぐけげこごさざしじすずせぜそぞただちぢっつづてでとどなにぬねのはばぱひびぴふぶぷへべぺほぼぽまみむめもゃやゅゆょよらりるれろゎわゐゑ
をんゔーゝゞ"
       marukatakana
       "㋐㋑㋒㋓㋔㋕㋖㋗㋘㋙㋚㋛㋜㋝㋞㋟㋠㋡㋢㋣㋤㋥㋦㋧㋨㋩㋪㋫㋬㋭㋮㋯㋰㋱㋲㋳㋴㋵㋶㋷㋸㋹㋺㋻㋼㋽㋾"
       marukatakana-yomi
       "アイウエオカキクケコサシスセソタチツテトナニヌネノハヒフヘホマミムメモヤユヨラリルレロワヰヱヲ")


  (def string-katakana (s)
    (cl:check-type s (cl:or cl:string cl:symbol))
    (text.tr:string-tr s hiragana katakana))


  (def string-hiragana (s)
    (cl:check-type s (cl:or cl:string cl:symbol))
    (text.tr:string-tr s katakana hiragana))


  (def string-maru-katakana (s)
    (cl:check-type s (cl:or cl:string cl:symbol))
    (text.tr:string-tr string-katakana.s marukatakana-yomi marukatakana)))


(def dedakutenize (str)
  (gauche-compat.text.tr:string-tr 
   str
   "ガギグゲゴザジズゼゾダヂヅデドバビブベボパピプペポヴがぎぐげござじずぜぞだぢづでどばびぶべぼぱぴぷぺぽ"
   "カキクケコサシスセソタチツテトハヒフヘホハヒフヘホウかきくけこさしすせそたちつてとはひふへほはひふへほ"))


(def deyouonize (str)
  (gauche-compat.text.tr:string-tr 
   str
   "ァィゥェォッャュョヮヵヶぁぃぅぇぉっゃゅょゎ"
   "アイウエオツヤユヨワカケあいゆえおつやゆよわ"))


(def endakutenize (str)
  (gauche-compat.text.tr:string-tr 
   str
   "カキクケコサシスセソタチツテトハヒフヘホハヒフヘホウかきくけこさしすせそたちつてとはひふへほはひふへほ"
   "ガギグゲゴザジズゼゾダヂヅデドバビブベボパピプペポヴがぎぐげござじずぜぞだぢづでどばびぶべぼぱぴぷぺぽ"))


(def senzen (str)
  (dedakutenize (deyouonize str)))


(def nfig (n w)
  ((afn (n fig acc)
     (*let (q r) (cl:floor n fig)
           (if (< q fig)
               (if (is 0 q)
                   (cons r acc)
                   (cl:list* q r acc))
               (self q fig (cons r acc)))))
   n w '() ))


(def 4fig (n)
  (nfig n (expt 10 4)))


(def sen-hyaku-ju (n)
  (rev:map (fn (x y)
             (leto nn "〇一二三四五六七八九"
               (if (and (is x 1) (no:empty y))
                   (list "" y)
                   (is 0 x) nil
                   :else
                   (list (string (nn x)) y))))
           (rev:nfig n 10)
           (rev '("千" "百" "十" ""))))


(def sen-hyaku-ju-daiji (n)
  (rev:map (fn (x y)
             (leto nn "零壱弐参肆伍陸漆捌玖"
               (if (and (is x 1) (no:empty y))
                   (list "" y)
                   (is 0 x) nil
                   :else
                   (list (string (nn x)) y))))
           (rev:nfig n 10)
           (rev '("仟" "佰" "拾" ""))))

;; #-(:or :allegro)
(def knum (n)
  (string:flat:rev:mappend
   (fn (x y)
     (unless (empty (car x))
       (list y x)))
   (map #'sen-hyaku-ju
        (rev:4fig n))
   (list "" "万" "億" "兆" "京" "垓" (string (cl:code-char #x25771)) "穣" "溝" "澗" "正" "載" "極"
         "恒河沙" "阿僧祇" "那由他" "不可思議" "無量大数" "？")))


(def knum-daiji (n)
  (string:flat:rev:mappend
   (fn (x y)
     (unless (empty (car x))
       (list y x)))
   (map #'sen-hyaku-ju-daiji
        (rev:4fig n))
   (list "" "萬" "億" "兆" "京" "垓" (string (cl:code-char #x25771)) "穣" "溝" "澗" "正" "載" "極"
         "恒河沙" "阿僧祇" "那由他" "不可思議" "無量大数" "？")))


;;#-allegro
(def cl-user::数 (stream arg clon at)
  clon at
  (w/stdout stream
    (pr (knum arg))))

(def cl-user::大 (stream arg clon at)
  clon at
  (w/stdout stream
    (pr (knum-daiji arg))))


;;; *EOF*
