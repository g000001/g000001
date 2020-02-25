(in-package :g1.arc)
(in-readtable :g1.arc)


(def ln*header (n)
  (let gou knum.n
    (cl:format nil
               "#<LISP-NEWS {0000000~3,'0,D}>

毎週金曜日発行

\【今週の目次】

1. メルマガ第~A号です
2. 今週目についたこと/記事/動画
3. 今週のLispブログ日本語記事
4. アップデートされた処理系/Lisp系アプリ
5. 編集後記

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
1. メルマガ第~A号です
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
こんにちは、g000001です。メルマガ第~A号です。

　毎度、適当なことを書き散らかしていますので、質問、間違いのご指摘等あ
りましたら、lisp-news@cdddddr.org までお願いします。

"
               n gou gou gou)))


"
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
2. 今週目についたこと/記事/動画
───────────────────────────────────


((( European Common Lisp Meeting, Madrid, June 2, 2013 -> registration is open (weitz.de)

    http://weitz.de/eclm2013/
    )))

European Lisp Symposiumと共同開催されるEuropean Common Lisp Meetingの
受け付けが開始されました。
ELSは比較的アカデミックですが、ECLMの方は実務でのCommon Lisp利用にター
ゲットを合せています。

2011年開催のECLM動画/資料
- http://weitz.de/eclm2011/
- http://blip.tv/eclm

自分が知る限りでは日本からも参加する予定の方もいるようです。


((( LispHub.jpに過去のイベントをまとめています。
    
    http://lisphub.jp/event/
    )))

過去のLisp系イベントを探してまとめています。
眺めてみるに、やはり80年代後半から90年代前半はかなり熱かったようです。

イベントの情報提供お待ちしています。
'(("イベント名" "場所" "イベントのURL" 人数 . その他) ...)
みたいな形式で情報を貰えると最高にありがたいです。

lisp-news@cdddddr.orgにメール、もしくは、@g000001にメンションを頂けれ
ば追記します。


((( The Guile 100 Project: Problem 4: tar file archives

    http://www.lonelycactus.com/guile100/
    http://www.lonelycactus.com/guile100/html/Problem-4.html
    )))

今週のguile 100ですが、第四問が3/27に出題されました。
今回は、POSIX tarで読める形式のUstar形式のサブセットをサポートするアーカイバの作成。
結構プラクティカルですね。


((( CDR 13 finalized

    http://cdr-blog.blogspot.jp/2013/03/cdr-13-finalized.html
    )))

CDRとは、SchemeでいうSRFIのCommon Lisp版です。
とはいえ、SchemeのSRFI程スタンダードになってはいません。
今回13番目の提案である、『優先度つきキュー』が決定となりました。
それはともかく参照実装が付いてないので、手元で動かせないのですが…。


((( Common Lispの父(の一人)は今もLispを使っているのか

    http://ja.reddit.com/r/lisp/comments/1bnlf4/common_lisp_user_of_the_first_hour_still_active/
    )))

Common Lisp策定の中心人物の一人でもあったCMUのScott E. Fahlman教授です
が、現在もLispを使っているのかという質問をされた方がいるようです。

回答としては、現在も研究で使っているそうで、大きい知識ベースシステム、
自然言語理解ツールを構築するのにSBCLを利用しているとのこと。
CMUCLのお膝元ですが、フォークした現在はSBCLを使ってるんですね。

ちなみに、Fahlman教授は、:-)の発明者としても有名です。


((( EmacsConf 開催

    http://experivis.com/collection/emacsconf2013/
    )))

3/30日にemacsconfが開催されました。
ストリーミングもされたとのことですが、残念ながら見逃してしまいました。
今回は、SLIME開発者のLuke Gorrie氏もSLIMEについて発表。

発表資料/録音/動画はこちら
- http://experivis.com/collection/emacsconf2013/

発表がスケッチとして眺められますがなかなか珍しいですね。


((( 第7回 関西Emacs勉強会

    http://atnd.org/event/ke7
    )))


4/27日に京都のはてなセミナールームにて開催とのこと。
定員が243人だそうで、結構広い会場なんですね。
200人位Emacsの人が集まると壮観な気もします。


((( InfoQでのLisp系のまとめ )))

先日、InfoQ(日本語)でLisp系のタグが付いた記事を一覧で見ることができる
ことを知りました。
良い感じのニュースソースです。残念ながらフィードは無い様子。

- InfoQ:LISPに関するすべてのコンテンツ (infoq.com)
  http://www.infoq.com/jp/lisp

- INFOQ:Schemeに関するすべてのコンテンツ (infoq.com)
  http://www.infoq.com/jp/scheme/

- Clojureに関するすべてのコンテンツ (infoq.com)
  http://www.infoq.com/jp/clojure

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
3. 今週のLispブログ日本語記事
───────────────────────────────────

+【369】Gimp でオリオン座を描いてみる(3) - 分室の分室 (d.hatena.ne.jp)
| http://d.hatena.ne.jp/foussin/20130404/1365013375
|
+【368】Gimp でオリオン座を描いてみる(2) - 分室の分室 (d.hatena.ne.jp)
|  http://d.hatena.ne.jp/foussin/20130403/1364918969
|
+【366】オリオン座の座標データを Scheme で記述してみる - 分室の分室 (d.hatena.ne.jp)
  http://d.hatena.ne.jp/foussin/20130328/1364479482
  ;; gimpのscript-fuはschemeなのは有名ですが、活用しているschemerはそれ
  ;;  ほどいないですね。
  ;;  グラフ等の出力として簡単に使えたりしたらschemeコードを生成してgimp
  ;;  に描かせるなんてことも良いかもしれないですね。

- 時の羅針盤＠blog: OCI binding (compassoftime.blogspot.jp)
  http://compassoftime.blogspot.jp/2013/04/oci-binding.html

- fixedpoint.jp - SRFI-110 の役割 (fixedpoint.jp)
  http://www.fixedpoint.jp/2013/04/03/srfi-110.html

- Stumpwm で Redmine のチケットのタイトルを簡単にコピペ - アクトインディ技術部隊報告書 (tech.actindi.net)
  http://tech.actindi.net/3573940318
  ;; StumpWMは色々Common Lispで拡張できるのが良いです。

- LLerのための関数指向入門 (gist.github.com)
  https://gist.github.com/ympbyc/5278140

- 何故か今ＬＩＳＰ - cocodecocolabの日記 (d.hatena.ne.jp)
  http://d.hatena.ne.jp/cocodecocolab/20130331/1364741664

- Land of Lisp の歌を訳して見た - 非現実的非日常的非常識的、非日記。 (d.hatena.ne.jp)
  http://d.hatena.ne.jp/Kinokkory/20130329/p1

- LispWorks Professional 32bit for Windows 買いました（さわった感想）: 峯島雄治のブログ (bmonkey.cocolog-nifty.com)
  http://bmonkey.cocolog-nifty.com/blog/2013/02/lispworks-profe.html


■学習の記録系

- 対話によるCommon Lisp入門 13 クォート - by shigemk2 (d.hatena.ne.jp)
  http://d.hatena.ne.jp/shigemk2/20130331/1364657168

- Clojure勉強日記（その３ ２．２ リーダマクロ／２．３関数 - 夢とガラクタの集積場 (d.hatena.ne.jp)
  http://d.hatena.ne.jp/kimutansk/20130402/1364854510

- SICP 2.1.2 Abstraction Barriers - プログラミング再入門 (d.hatena.ne.jp)
  http://d.hatena.ne.jp/tetsu_miyagawa/20130330/1364608304


━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
4. アップデートされた処理系/Lisp系アプリ
───────────────────────────────────
- xyzzy 0.2.2.248 (エディタ)
  http://xyzzy-022.github.com/xyzzy/2013/03/29/xyzzy-0_2_2_248-release-note/

- SBCL 1.1.6
  http://qiita.com/items/5cb12ac4e61da9e4b0b6
  http://www.sbcl.org/news.html#1.1.6
  ;; リリース後、珍しく色々問題が発覚したバージョンとなってしまったよ
  ;;  うです。安定性を重視する場合はバージョンアップしない方が吉かも、との
  ;;  こと。
  ;;  主にsvrefとsymbolmacroの組み合わせでのバグが報告されています。

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
5. 編集後記
───────────────────────────────────
　求職中ですがパチンコとか携帯ゲームのテスターの面接に行ってきました。
適当にぷかぷかしていたいです。

----------------------------------------------------------------------
lisp-news
発行システム：『まぐまぐ！』 http://www.mag2.com/
配信中止はこちら http://www.mag2.com/m/0001548450.html
----------------------------------------------------------------------
"
