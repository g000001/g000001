(IN-PACKAGE :G000001)

#+ALLEGRO
(DEFUN QUIT (&OPTIONAL CODE &KEY NO-UNWIND QUIET)
  (CL-USER::EXIT CODE :NO-UNWIND NO-UNWIND :QUIET QUIET))

(DEFUN GITHUB-INSTALL (USER-NAME NAME)
  (ASDF-INSTALL:INSTALL
   (FORMAT NIL
           "http://github.com/~A/~A/tarball/master"
           USER-NAME
           NAME)))

(DEFPARAMETER *PACKAGE-PATH* 
  (LIST :SHIBUYA.LISP 
        :FARE-UTILS 
        :ALEXANDRIA
        :MYCL-UTIL
        :KMRCL
        :METATILITIES
        ))

(DEFUN AUTO-IMPORT (NAME &AUX ANS)
  (DOLIST (PKG (REVERSE *PACKAGE-PATH*))
    (WHEN (AND (FIND-PACKAGE PKG)
               (FIND-SYMBOL (STRING NAME) PKG))
      (LET ((SYM (INTERN (STRING NAME) PKG)))
        (SHADOWING-IMPORT SYM)
        (PUSH PKG ANS))))
  ANS)

(DEFVAR *japanese-kana-table*
  '((#\あ #\ア #\ｱ) (#\い #\イ #\ｲ) (#\う #\ウ #\ｳ) (#\え #\エ #\ｴ) (#\お #\オ #\ｵ)
    (#\か #\カ #\ｶ) (#\き #\キ #\ｷ) (#\く #\ク #\ｸ) (#\け #\ケ #\ｹ) (#\こ #\コ #\ｺ)
    (#\さ #\サ #\ｻ) (#\し #\シ #\ｼ) (#\す #\ス #\ｽ) (#\せ #\セ #\ｾ) (#\そ #\ソ #\ｿ)
    (#\た #\タ #\ﾀ) (#\ち #\チ #\ﾁ) (#\つ #\ツ #\ﾂ) (#\て #\テ #\ﾃ) (#\と #\ト #\ﾄ)
    (#\な #\ナ #\ﾅ) (#\に #\ニ #\ﾆ) (#\ぬ #\ヌ #\ﾇ) (#\ね #\ネ #\ﾈ) (#\の #\ノ #\ﾉ)
    (#\は #\ハ #\ﾊ) (#\ひ #\ヒ #\ﾋ) (#\ふ #\フ #\ﾌ) (#\へ #\ヘ #\ﾍ) (#\ほ #\ホ #\ﾎ)
    (#\ま #\マ #\ﾏ) (#\み #\ミ #\ﾐ) (#\む #\ム #\ﾑ) (#\め #\メ #\ﾒ) (#\も #\モ #\ﾓ)
    (#\や #\ヤ #\ﾔ) (#\ゆ #\ユ #\ﾕ) (#\よ #\ヨ #\ﾖ)
    (#\ら #\ラ #\ﾗ) (#\り #\リ #\ﾘ) (#\る #\ル #\ﾙ) (#\れ #\レ #\ﾚ) (#\ろ #\ロ #\ﾛ)
    (#\わ #\ワ #\ﾜ) (#\ゐ #\ヰ "ｲ") (#\ゑ #\ヱ "ｴ") (#\を #\ヲ #\ｦ)
    (#\ん #\ン #\ﾝ)
    (#\が #\ガ "ｶﾞ") (#\ぎ #\ギ "ｷﾞ") (#\ぐ #\グ "ｸﾞ") (#\げ #\ゲ "ｹﾞ") 
    (#\ご #\ゴ "ｺﾞ") (#\ざ #\ザ "ｻﾞ") (#\じ #\ジ "ｼﾞ") (#\ず #\ズ "ｽﾞ")
    (#\ぜ #\ゼ "ｾﾞ") (#\ぞ #\ゾ "ｿﾞ") (#\だ #\ダ "ﾀﾞ") (#\ぢ #\ヂ "ﾁﾞ")
    (#\づ #\ヅ "ﾂﾞ") (#\で #\デ "ﾃﾞ") (#\ど #\ド "ﾄﾞ") (#\ば #\バ "ﾊﾞ")
    (#\び #\ビ "ﾋﾞ") (#\ぶ #\ブ "ﾌﾞ") (#\べ #\ベ "ﾍﾞ") (#\ぼ #\ボ "ﾎﾞ")
    (#\ぱ #\パ "ﾊﾟ") (#\ぴ #\ピ "ﾋﾟ") (#\ぷ #\プ "ﾌﾟ") (#\ぺ #\ペ "ﾍﾟ")
    (#\ぽ #\ポ "ﾎﾟ")
    (#\ぁ #\ァ #\ｧ) (#\ぃ #\ィ #\ｨ) (#\ぅ #\ゥ #\ｩ) (#\ぇ #\ェ #\ｪ) (#\ぉ #\ォ #\ｫ)
    (#\っ #\ッ #\ｯ)
    (#\ゃ #\ャ #\ｬ) (#\ゅ #\ュ #\ｭ) (#\ょ #\ョ #\ｮ)
    (#\ゎ #\ヮ "ﾜ")
    ("う゛" #\ヴ "ｳﾞ") (nil #\ヵ "ｶ") (nil #\ヶ "ｹ")
    (#\　 #\ ) (#\， #\, #\､) (#\． #\. #\｡) (#\、 #\, #\､) (#\。 #\. #\｡)
    (#\・ nil #\･) (#\： #\:) (#\； #\;) (#\？ #\?) (#\！ #\!) (#\゛ nil #\ﾞ) 
    (#\゜ nil #\ﾟ) (#\´ #\') (#\｀ #\`) (#\＾ #\^) (#\＿ #\_) (#\ー #\- #\ｰ) 
    (#\— #\-) (#\‐ #\-)
    (#\／ #\/) (#\＼ #\\) (#\〜 #\~)  (#\｜ #\|) (#\‘ #\`) (#\’ #\') (#\“ #\") 
    (#\” #\")
    (#\（ #\() (#\） #\)) (#\［ #\[) (#\］ #\]) (#\｛ #\{) (#\｝ #\})
    (#\〈 #\<) (#\〉 #\>) (#\「 nil #\｢) (#\」 nil #\｣)
    (#\＋ #\+) (#\− #\-) (#\＝ #\=) (#\＜ #\<) (#\＞ #\>) 
    (#\′ #\') (#\″ #\") (#\￥ #\\) (#\＄ #\$) (#\％ #\%)
    (#\＃ #\#) (#\＆ #\&) (#\＊ #\*) (#\＠ #\@)))

(DEFUN JAPANESE-HANKAKU-CHAR (CHAR)
  (OR (DOLIST (X *JAPANESE-KANA-TABLE*)
        (WHEN (MEMBER CHAR X)
          (RETURN (CAR (LAST X)))))
      CHAR))

(DEFUN JAPANESE-HANKAKU-STRING (STRING)
   (REDUCE (LAMBDA (ANS X)
              (CONCATENATE 'STRING ANS (STRING (JAPANESE-HANKAKU-CHAR X))))
           STRING
           :INITIAL-VALUE ""))

(DEFUN KEBUNRIDGE-WORD (WORD)
  (LET ((LEN (LENGTH WORD)))
    (REDUCE (LAMBDA (ANS X)
              (CONCATENATE 'STRING ANS (STRING X)))
            (CONCATENATE 'STRING
                         (STRING (CHAR WORD 0))
                         (ALEXANDRIA:SHUFFLE (SUBSEQ WORD 1 (1- LEN)))
                         (STRING (CHAR WORD (1- LEN))))
            :INITIAL-VALUE "")))

(DEFUN GOOD-MORNING ()
  (TWIT:UPDATE 
   (JAPANESE-HANKAKU-STRING 
    (CONCATENATE 'STRING
                 "お"
                 (KEBUNRIDGE-WORD "はようございま")
                 "す!"))))