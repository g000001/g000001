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
    (#\　 #\ ) (#\， #\, #\､) (#\． #\｡) (#\、 #\, #\､) (#\。 #\｡)
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


(DEFUN OTSU ()
  (TWIT:UPDATE 
   (JAPANESE-HANKAKU-STRING 
    (CONCATENATE 'STRING
                 "お"
                 (KEBUNRIDGE-WORD "つかれさまで")
                 "す!"))))


;; CR
(setf (symbol-function 'cr) #'cl:identity)

(defun pr (&rest args)
  (princ 
   (with-output-to-string (out)
     (mapc (lambda (x) (princ x out)) args))))

(defun prn (&rest args)
  (apply #'pr args)
  (terpri))

;; lispm
(defparameter user-id ""
  "The value of user-id is either the name of the logged in user, 
as a string, or else an empty string if there is no user logged in.
 It appears in the who-line.")

;logout-list Variable
(defparameter logout-list ()
  "The value of logout-list is a list of forms 
which are evaluated when a user logs out.")

(defun login (name &optional (load-init))
  "If anyone is logged into the machine, login logs him out.
 (See logout .) Then user-id is set from name.
 Finally login attempts to find your INIT file. 
It first looks in \"user-id ; .LISPM (INIT)\", then in \"(INIT); 
user-id .LISPM\", and finally in the default init file
 \"(INIT); * .LISPM\". When it finds one of these that exists,
 it loads it in. login returns t ."
  (setq user-id (string name))
  (unless load-init
    (load (merge-pathnames "lispm.init" (user-homedir-pathname)))))

(defun logout (&optional name)
  "First, logout evaluates the forms on logout-list.
 Then it tries to find a file to run, looking first in 
\"user-id ; .LSPM_ (INIT)\", then in \"(INIT); user-id .LSPM_\", 
and finally in the default file \"(INIT); * .LSPM_\". 
If and when it finds one it these that exists, 
it loads it in. Then it sets user-id to an empty string and
 logout-list to nil , and returns t ."
  (declare (ignore name))
  (setq user-id "")
  (eval `(progn ,@logout-list))
  (setq logout-list () ))

;(logout)

(defmacro setq-return-undo (var val)
;  "setqを実行し、実行内容をアンドゥする式を返す。2値目は、setqの返り値"
  `(let ((undo (if (boundp ',var)
		   '(setq ,var ',(and (boundp var) (symbol-value var)))
		   '(makunbound ',var))))
     (push undo logout-list)
     (values undo (setq ,var ,val))))

(defmacro login-setq (&rest form)
  "login-setq is like setq except that it puts a setq form on
 logout-list to set the variables to their previous values."
  `(progn
     ,@(do ((l form (cddr l))
	    (res () (cons `(nth-value 1 (setq-return-undo ,(car l) ,(cadr l)))
			  res)))
	   ((endp l) (nreverse res)))))

;(login-setq foo 33 bar 44)

;login-eval x
(defmacro login-eval (&rest form)
  "login-eval is used for functions which are \"meant to be called\" 
from INIT files, such as eine:ed-redefine-keys, 
which conveniently return a form to undo what they did.
 login-eval adds the result of the form x to the logout-list."
  `(progn
     ,@(loop :for l :in form
	     :collect `(push ,l logout-list))))

;(login-eval (setq-return-undo foo 3))

;(login-setq foo 33)
;(setq-return-undo foo 33)
;logout-list
;(logout)

;(unintern 'foo)
