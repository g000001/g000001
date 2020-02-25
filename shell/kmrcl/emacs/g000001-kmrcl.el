;;; g000001-kmrcl.el --- Browse g000001's KMRCL blog entry

;; Copyright 2010 CHIBA Masaomi, <chiba.masaomi@gmail.com>
;; inspired by Utz-Uwe Haus's <haus@uuhaus.de> cltl2.el 
;; inspired by Eric Naggum's <erik@naggum.no> hyperspec.el

;; This file is not part of GNU Emacs, but distributed under the same
;; conditions as GNU Emacs, and is useless without GNU Emacs.

;; GNU Emacs is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.

;; GNU Emacs is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to
;; the Free Software Foundation, Inc., 59 Temple Place - Suite 330,
;; Boston, MA 02111-1307, USA.

;;; Commentary:

;; KMRCLの関数等の説明をg000001のブログから探す。なんという手前味噌。

;;; Code:

(require 'cl)
(require 'browse-url)			;you need the Emacs 20 version
(require 'thingatpt)

;; maybe this should be a (defcustom g000001-kmrcl-root-url ...) ?
(defvar g000001-kmrcl-root-url 
  "http://cadr.g.hatena.ne.jp/g000001/")

(defvar g000001-kmrcl-history nil
  "History of symbols looked up in G000001-Kmrcl.")

(defvar g000001-kmrcl-symbols (make-vector 127 0)
  "This variable holds the access information for the symbols indexed
in the G000001-Kmrcl lookup index.")

(defun g000001-kmrcl-lookup (symbol-name)
  (interactive
   (list (let ((symbol-at-point (thing-at-point 'symbol)))
	   (if (and symbol-at-point
		    (intern-soft (downcase symbol-at-point)
				 g000001-kmrcl-symbols))
	       symbol-at-point
	     (completing-read
	      "Look up symbol in G000001-Kmrcl: "
	      g000001-kmrcl-symbols #'boundp
	      t symbol-at-point
	      'g000001-kmrcl-history)))))
  (maplist (lambda (entry)
	     (browse-url (concat g000001-kmrcl-root-url (car entry)))
	     (if (cdr entry)
		 (sleep-for 1.5)))
	   (let ((symbol (intern-soft (downcase symbol-name)
				      g000001-kmrcl-symbols)))
	     (if (and symbol (boundp symbol))
		 (progn
		   (message (format "Showing %d matching entries."
				    (length (symbol-value symbol))))
		   (symbol-value symbol))
	       (error "The symbol `%s' is not indexed in G000001-Kmrcl"
		      symbol-name)))))

(mapcar (lambda (entry)
	  (let ((symbol (intern (car entry) g000001-kmrcl-symbols)))
	    (if (boundp symbol)
                (push (cadr entry) (symbol-value symbol))
	      (set symbol (cdr entry)))))
	'(("let-when" "20091028/1256738984") ("aif" "20091031/1256978010")
          ("let-if" "20091031/1256917068") ("awhen" "20091102/1257093421")
          ("awhile" "20091103/1257238430") ("aand" "20091104/1257342379")
          ("acond" "20091106/1257437429") ("alambda" "20091107/1257527492")
          ("aif2" "20091109/1257696287") ("awhen2" "20091109/1257696287")
          ("awhile2" "20091111/1257946674") ("mac" "20091114/1258208512")
          ("acond2" "20091114/1258135473")
          ("print-form-and-results" "20091116/1258297271")
          ("until" "20091117/1258464083") ("while" "20091119/1258642183")
          ("for" "20091120/1258728792") ("with-each-stream-line" "20091121/1258786792")
          ("with-each-file-line" "20091122/1258885585") ("in" "20091123/1258924583")
          ("mean" "20091124/1258992442") ("with-gensyms" "20091125/1259159200")
          ("time-seconds" "20091125/1259159200") ("mv-bind" "20091128/1259411315")
          ("time-iterations" "20091128/1259339455") ("deflex" "20091129/1259488846")
          ("def-cached-vector" "20091202/1259682168")
          ("with-ignore-errors" "20091203/1259847038")
          ("def-cached-instance" "20091203/1259768422") ("ppmx" "20091204/1259932804")
          ("defconstant*" "20091205/1260010568")
          ("defvar-unbound" "20091206/1260100403") ("mklist" "20091208/1260283482")
          ("map-and-remove-nils" "20091209/1260369083") ("filter" "20091210/1260456611")
          ("remove-from-tree-if" "20091212/1260620023")
          ("appendnew" "20091212/1260597491") ("find-tree" "20091213/1260698312")
          ("flatten" "20091215/1260887773") ("remove-keyword" "20091216/1260970277")
          ("remove-keywords" "20091217/1261053202") ("mapappend" "20091219/1261234768")
          ("mapcar-append-string-nontailrec" "20091220/1261244741")
          ("mapcar-append-string" "20091221/1261330470")
          ("mapcar2-append-string-nontailrec" "20091222/1261408741")
          ("mapcar2-append-string" "20091223/1261505628")
          ("append-sublists" "20091224/1261591336")
          ("alist-elem-p" "20091225/1261667900") ("alistp" "20091226/1261755653")
          ("update-alist" "20091227/1261842492") ("get-alist" "20091228/1261926668")
          ("(setf get-alist)" "20091229/1262016724") ("alist-plist" "20091230/1262108234")
          ("plist-alist" "20091231/1262188881") ("update-plist" "20100101/1262273843")
          ("unique-slot-values" "20100102/1262360001")
          ("print-file-contents" "20100103/1262444632")
          ("read-stream-to-string" "20100104/1262540544")
          ("read-file-to-string" "20100105/1262695999")
          ("read-file-to-usb8-array" "20100106/1262780656")
          ("read-stream-to-strings" "20100108/1262882751")
          ("read-file-to-strings" "20100109/1263008448")
          ("stream-subst" "20100112/1263305868") ("file-subst" "20100114/1263401091")
          ("print-n-chars" "20100115/1263566687")
          ("print-n-strings" "20100117/1263657529")
          ("indent-spaces" "20100119/1263833185")
          ("indent-html-spaces" "20100120/1263917177")
          ("print-list" "20100121/1264004557") ("print-rows" "20100122/1264090307")
          ("write-fixnum" "20100124/1264268581")
          ("null-output-stream" "20100125/1264349445")
          ("with-utime-decoding" "20100126/1264516050") ("is-dst" "20100127/1264601992")
          ("with-utime-decoding-utc-offset" "20100128/1264689977")
          ("write-utime-hms-stream" "20100129/1264720761")
          ("write-utime-hms" "20100131/1264913403")
          ("write-utime-hm-stream" "20100203/1265206341")
          ("write-utime-hm" "20100204/1265291471")
          ("write-utime-ymdhms-stream" "20100205/1265380605")
          ("write-utime-ymdhms" "20100206/1265462955")
          ("write-utime-ymdhm-stream" "20100207/1265523518")
          ("write-utime-ymdhm" "20100208/1265639366")
          ("copy-binary-stream" "20100210/1265728422")
          ("canonicalize-directory-name" "20100211/1265892565")
          ("probe-directory" "20100212/1265985944")
          ("directory-tree" "20100214/1266149043")
          ("string-append" "20100215/1266244182")
          ("list-to-string" "20100216/1266325986")
          ("count-string-words" "20100217/1266417877")
          ("position-char" "20100218/1266499815")
          ("position-not-char" "20100219/1266587914")
          ("delimited-string-to-list" "20100220/1266666170")
          ("list-to-delimited-string" "20100221/1266763816")
          ("string-invert" "20100223/1266932740")
          ("string-trim-last-character" "20100224/1267018259")
          ("nsubseq" "20100225/1267108233")
          ("nstring-trim-last-character" "20100226/1267158845")
          ("string-hash" "20100227/1267280500")
          ("is-string-empty" "20100228/1267342791")
          ("string-substitute" "20100301/1267451202")
          ("is-char-whitespace" "20100302/1267507186")
          ("is-string-whitespace" "20100303/1267593267")
          ("string-right-trim-whitespace" "20100304/1267680270")
          ("string-left-trim-whitespace" "20100305/1267765590")
          ("string-trim-whitespace" "20100306/1267874588")
          ("replaced-string-length" "20100307/1267961787")
          ("substitute-chars-strings" "20100308/1268025093")
          ("escape-xml-string" "20100309/1268109843")
          ("make-usb8-array" "20100310/1268196874")
          ("usb8-array-to-string" "20100311/1268282538")
          ("string-to-usb8-array" "20100312/1268368575")
          ("concat-separated-strings" "20100313/1268491737")
          ("only-null-list-elements-p" "20100314/1268573320")
          ("print-separated-strings" "20100315/1268663780")
          ("def-prefixed-number-string" "20100316/1268715126")
          ("prefixed-fixnum-string" "20100317/1268831478")
          ("prefixed-integer-string" "20100318/1268916743")
          ("integer-string" "20100319/1269010463")
          ("fast-string-search" "20100320/1269093879")
          ("string-delimited-string-to-list" "20100321/1269169853")
          ("string-to-list-skip-delimiter" "20100322/1269259543")
          ("string-starts-with" "20100324/1269405788")
          ("count-string-char" "20100325/1269492072")
          ("count-string-char-if" "20100326/1269577860")
          ("non-alphanumericp" "20100327/1269696996") ("hexchar" "20100328/1269787541")
          ("charhex" "20100330/1269878321")
          ("binary-sequence-to-hex-string" "20100331/1269961522")
          ("encode-uri-string" "20100403/1270269942")
          ("decode-uri-string" "20100404/1270384585")
          ("uri-query-to-alist" "20100405/1270442669")
          ("random-char" "20100406/1270533324") ("random-string" "20100407/1270615638")
          ("first-char" "20100408/1270705805") ("last-char" "20100409/1270789623")
          ("ensure-string" "20100410/1270895464")
          ("string-right-trim-one-char" "20100412/1271046712")
          ("remove-char-string" "20100414/1271220975")
          ("string-strip-ending" "20100416/1271392059")
          ("string-elide" "20100418/1271574628")
          ("string-maybe-shorten" "20100420/1271737121")
          ("shrink-vector" "20100422/1271912718") ("lex-string" "20100424/1272097455")
          ("split-alphanumeric-string" "20100427/1272344832")
          ("collapse-whitespace" "20100428/1272430140")
          ("string-&gt;list" "20100501/1272697055")
          ("trim-non-alphanumeric" "20100503/1272869596")
          ("substitute-string-for-char" "20100505/1273040289")
          ("escape-backslashes" "20100509/1273400424")
          ("escape-backslashes" "20100511/1273554830")
          ("html/xml" "20100513/1273726580") ("user-agent-ie-p" "20100515/1273910964")
          ("base-url!" "20100518/1274186160") ("make-url" "20100521/1274434753")
          ("decode-uri-query-string" "20100524/1274677744")
          ("split-uri-query-string" "20100526/1274828441") ("if*" "20100529/1275126086")
          ("memo-proc" "20100602/1275433019") ("memoize" "20100604/1275605738")
          ("defun-memo" "20100608/1275972482") ("_f" "20100610/1276168606")
          ("compose" "20100613/1276405740") ("cl-variables" "20100616/1276664749")
          ("cl-functions" "20100619/1276926558") ("cl-symbols" "20100621/1277095077")
          ("string-default-case" "20100623/1277266742")
          ("concat-symbol-pkg" "20100625/1277470456")
          ("concat-symbol" "20100629/1277820150")
          ("ensure-keyword" "20100701/1277984820")
          ("ensure-keyword-upcase" "20100703/1278162455")
          ("ensure-keyword-default-case" "20100706/1278421952")
          ("show-variables" "20100707/1278509107")
          ("show-functions" "20100708/1278596477") ("show" "20100710/1278688430")
          ("find-test-generic-functions" "20100720/1279637098")
          ("run-tests-for-instance" "20100721/1279719591")
          ("getpid" "20100723/1279896483") ("file-size" "20100724/1279980889")
          ("command-output" "20100727/1280234520")
          ("run-shell-command" "20100728/1280292129")
          ("delete-directory-and-files" "20100729/1280413737")
          ("quit" "20100803/1280807228")
          ("command-line-arguments" "20100804/1280932190")
          ("copy-file" "20100808/1281271372") ("cwd" "20100813/1281708560")
          ("canonicalize-directory-name" "20100816/1281967773")
          ("probe-directory" "20100817/1282054877")
          ("pretty-date" "20100818/1282134482") ("pretty-date-ut" "20100820/1282309922")
          ("date-string" "20100823/1282574653")
          ("print-float-units" "20100824/1282651711")
          ("posix-time-to-utime" "20100826/1282793069")
          ("utime-to-posix-time" "20100827/1282881858")
          ("monthname" "20100829/1283093322") ("day-of-week" "20100830/1283173521")
          ("function-to-string" "20100831/1283232442")
          ("generalized-equal-function" "20100902/1283429418")
          ("generalized-equal-array" "20100904/1283608051")
          ("generalized-equal-hash-table" "20100906/1283779300")
          ("class-slot-names" "20100907/1283865676")
          ("generalized-equal-fielded-object" "20100908/1283917883")
          ("structure-slot-names" "20100909/1284005912")
          ("generalized-equal" "20100910/1284127548"))
        )


(provide 'g000001-kmrcl)

;;; g000001-kmrcl.el ends here
