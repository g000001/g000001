(IN-PACKAGE :G000001)

(DEFVAR *TWITTER-USERS* () )

#+ALLEGRO
(DEFUN QUIT (&OPTIONAL CODE &KEY NO-UNWIND QUIET)
  (CL-USER::EXIT CODE :NO-UNWIND NO-UNWIND :QUIET QUIET))

;; そのうち https対応したい
#|(DEFUN GITHUB-INSTALL (USER-NAME NAME)
  (ASDF-INSTALL:INSTALL
   (FORMAT NIL
           "http://github.com/~A/~A/tarball/master"
           USER-NAME
           NAME)))|#

(defun GITHUB-INSTALL (user-name name)
  (let* ((temp-filename (gensym "/tmp/asdf-install-"))
         (stat (kl:run-shell-command "wget --no-check-certificate -O ~A https://github.com/~A/~A/tarball/master"
                                     temp-filename
                                     user-name
                                     name)))
    (or (zerop stat) (error "GITHUB-INSTALL: Something went wrong."))
    (asdf-install:install temp-filename)))

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
    (#\゜ nil #\ﾟ) (#\´ #\') (#\｀ #\`) (#\＾ #\^) (#\＿ #\_) (#\ー #\ｰ #\-)
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


(DEFUN PRINT-ALL-TWEETS ()
  (LET ((ANS () ))
    (DOLIST (USER *TWITTER-USERS*)
      (LET ((TWIT:*TWITTER-USER* USER))
        (SETQ ANS
              (NCONC (twit:twitter-op :friends-timeline)
                     ANS))))
    (TWIT:PRINT-TWEETS
     (SORT (DELETE-DUPLICATES ANS :KEY #'TWIT::TWEET-ID)
           #'<
           :KEY #'TWIT::TWEET-ID))
    NIL))

(IN-PACKAGE :TWIT)
#+SBCL (PROGN
  ;; patch
  ;; バイナリで受けないとこけることがある
  (defun get-tinyurl (url)
    "Get a TinyURL for the given URL. Uses the TinyURL API service.
   (c) by Chaitanaya Gupta via cl-twit"
    (multiple-value-bind (body status-code)
        (funcall *http-request-function*
                 *tinyurl-url*
                 :parameters `(("url" . ,url))
                 :force-binary 'T)
      (if (= status-code +http-ok+)
          (SB-EXT:OCTETS-TO-STRING body)
          (error 'http-error
                 :status-code status-code
                 :url url
                 :body body)))))
(IN-PACKAGE :G000001)

(DEFUN GET-CALENDAR-JSON (UT)
  (LET ((REQUEST-URL
         (KMRCL:MAKE-URL
          "full"
          :BASE-DIR "http://www.google.com/calendar/feeds/japanese@holiday.calendar.google.com/public/"
          :VARS `(("start-min" . ,(XYZZY:FORMAT-DATE-STRING "%Y-%m-%d" UT))
                  ("start-max" . ,(XYZZY:FORMAT-DATE-STRING
                                   "%Y-%m-%d"
                                   (+ UT (* 24 60 60))))
                  ("max-results" . "1")
                  ("alt" . "json-in-script")
                  ("callback" . "handleJson")))))
    (STRING-TRIM "handleJson();"
                 (#-SBCL TRIVIAL-UTF-8:UTF-8-BYTES-TO-STRING
                  #+SBCL SB-EXT:OCTETS-TO-STRING
                  (DRAKMA:HTTP-REQUEST REQUEST-URL :FORCE-BINARY 'T)))))

(DEFUN -> (LIST &REST KEYS)
  (IF (ENDP KEYS)
      LIST
      (KMRCL:AWHEN (FIND (CAR KEYS) LIST :KEY #'ZL:CAR-SAFE)
        (APPLY #'-> KMRCL:IT (CDR KEYS)))))

(DEFUN HOLIDAY-P (&OPTIONAL (UT (GET-UNIVERSAL-TIME)))
  (LET ((DAY (NTH-VALUE 6 (DECODE-UNIVERSAL-TIME UT))))
    (OR (<= 5 DAY)                      ; (sat 5) (sun 6)
        ;; google calencar
        (< 0
           (CDR
            (-> (JSON:DECODE-JSON-FROM-STRING (GET-CALENDAR-JSON UT))
                :FEED
                :OPEN-SEARCH$TOTAL-RESULTS
                :$T))))))

#+SBCL
(PROGN
  (EXECUTOR:DEFINE-EXECUTABLE SCP)

  (DEFMACRO WITH-OUTPUT-TO-REMOTE-FILE ((STREAM PATH) &BODY BODY)
    (LET ((TEMP-FILE-NAME (STRING (GENSYM "/tmp/WITH-OUTPUT-TO-REMOTE-FILE-"))))
      `(UNWIND-PROTECT (PROGN
                         (WITH-OPEN-FILE (,STREAM ,TEMP-FILE-NAME :DIRECTION :OUTPUT)
                           ,@BODY)
                         (SCP ,TEMP-FILE-NAME ,PATH)
                         NIL)
         (WHEN (CL-FAD:FILE-EXISTS-P ,TEMP-FILE-NAME)
           (DELETE-FILE ,TEMP-FILE-NAME)))))

  (DEFMACRO WITH-INPUT-FROM-REMOTE-FILE ((STREAM PATH) &BODY BODY)
    (LET ((TEMP-FILE-NAME (STRING (GENSYM "/tmp/WITH-INPUT-FROM-REMOTE-FILE-"))))
      `(UNWIND-PROTECT (PROGN
                         (SCP ,PATH ,TEMP-FILE-NAME)
                         (WITH-OPEN-FILE (,STREAM ,TEMP-FILE-NAME)
                           ,@BODY)
                         NIL)
         (WHEN (CL-FAD:FILE-EXISTS-P ,TEMP-FILE-NAME)
           (DELETE-FILE ,TEMP-FILE-NAME)))))
  )

(DEFUN SED (START-PAT END-PAT NEW
            &KEY (IN *STANDARD-INPUT*) (OUT *STANDARD-OUTPUT*))
  (LOOP :WITH OPEN
        :FOR LINE := (READ-LINE IN NIL NIL) :WHILE LINE
        :DO (PROGN
              (WHEN (SEARCH START-PAT LINE)
                (SETQ OPEN 'T))
              (COND ((AND OPEN (SEARCH END-PAT LINE))
                     (SETQ OPEN NIL)
                     (WRITE-LINE NEW OUT))
                    ((NOT OPEN)
                     (WRITE-LINE LINE OUT))))))

(defun |#/-READER| (stream char arg)
  (declare (ignore char arg))
  (let ((g (gensym))
        (re (ppcre:regex-replace-all
             "\\\\/"
             (collect 'string
                      (choose
                       (let ((prev nil))
                         (until-if (lambda (c)
                                     (cond ((and (eql #\/ c)
                                                 (not (eql #\\ prev)))
                                            'T)
                                           (:else (setq prev c)
                                                  nil)))
                                   (scan-stream stream #'read-char)))))
             "/")))
    `(lambda (,g)
       (ppcre:scan ,re ,g))))

;(set-dispatch-macro-character #\# #\/ #'|#/-READER|)

(progn
  (defun uninterned-symbols (tree)
    (remove-if-not
     (lambda (x)
       (and (symbolp x)
            (not (symbol-package x))))
     (kl:flatten tree)))

  (defun count-symbol-names (syms)
    (let ((tab (make-hash-table :test 'equal)))
      (dolist (s syms)
        (incf (gethash (gensym-symbol-name s)
                       tab 0)))
      tab))

  (defun gensym-symbol-name (sym)
    (ppcre:regex-replace-all "-{0,1}\\d+$"
                             (symbol-name sym)
                             ""))
  (defun mexp (form)
    (let ((symtab (count-symbol-names
                   (remove-duplicates
                    (uninterned-symbols
                     (sb-cltl2:macroexpand-all form))))))
      (fare-utils:cons-tree-map
       (lambda (x)
         (cond
           ;; シンボルでない場合はスルー
           ((not (symbolp x)) x)
           ;; キーワードの場合はスルー
           ((keywordp x) x)
           ;; パッケージ名がある
           ((symbol-package x)
            (cond
              ;; 現在のパッケージ名と同じ
              ((string= (package-name (symbol-package x))
                        (package-name *package*))
               x)
              ;; 関数が束縛されていたらスルー
              ((fboundp x) x)
              ;; それ以外は、パッケージ名を省略(現在のパッケージにする)
              ('T (intern (symbol-name x)))))
           ;; 接頭辞が一度しか使われてない場合は数字を取り除く
           ((= 1 (gethash (gensym-symbol-name x)
                          symtab
                          0))
            (intern (gensym-symbol-name x)))
           ;; > 1
           ((< 1 (gethash (gensym-symbol-name x)
                          symtab
                          0))
            (intern (string-downcase (symbol-name x))))
           ;; それ以外は、スルー
           ('T x)))
       (sb-cltl2:macroexpand-all form))))

  (defun mexp-string (form)
    (write-to-string (mexp (read-from-string form)))) )


(defmacro w/outfile (out filename &body body)
  `(with-open-file (,out
                    ,filename
                    :direction :output
                    :if-exists :supersede)
     ,@body))


(defmacro w/outfile-sjis (out filename &body body)
  `(with-open-file (,out
                    ,filename
                    :direction :output
                    :if-exists :supersede
                    :external-format :sjis)
     ,@body))


;(defmacro w/> )

(defmacro with-< ((in filename &rest args) &body body)
  `(with-open-file (,in ,filename ,@args) ,@body))

(defmacro with-> ((out filename &rest args) &body body)
  (let ((args (copy-list args)))
    (remf args :direction)
    (remf args :if-exists)
    `(with-open-file (,out
                      ,filename
                      :direction :output
                      :if-exists :supersede
                      ,@args)
       ,@body)))

(defmacro with->> ((out filename &rest args) &body body)
  (let ((args (copy-list args)))
    (remf args :direction)
    (remf args :if-exists)
    `(with-open-file (,out
                      ,filename
                      :direction :output
                      :if-exists :append
                      ,@args)
       ,@body)))
