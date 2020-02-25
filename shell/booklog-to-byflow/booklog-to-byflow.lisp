;;;; booklog-to-byflow.lisp

(cl:in-package :booklog-to-byflow-internal)

(def-suite booklog-to-byflow)

(in-suite booklog-to-byflow)

;;; booklog形式
;;; ASIN(アマゾン商品コード) / 13桁ISBN / タイトル / 作者名 / 出版社名 / 発行年 / 分類 / カテゴリ / タグ / ★評価 / レビュー / 非公開メモ / 読書状況 / 登録日時 / 更新日時

;;; byflow形式
;;; http://www.byflow.com/help/api/
;;; ASIN	4274065979	ハッカーと画家	2011/04/04	1	好きだけど、なんだかどこか、中二病と同じ香りがするのはなぜだろう。	読んだ,best of 2010

(defun |YYYY-MM-DD HH:MM:SS-TO-YYYY/MM/DD| (s)
  (ppcre:register-groups-bind (yyyy mm dd)
      ("(\\d{4})-(\\d{2})-(\\d{2}) .*" s)
    (format nil "~D/~D/~D" yyyy mm dd)))

(defun booklog-to-byflow-list (file &optional (start 0) end)
  (with-< (< file :external-format :sjis)
    (do ((line (read-line < nil :eof)
               (read-line < nil :eof))
         (pat (ppcre:create-scanner "([^\\t]*)\\t([^\\t]*)\\t([^\\t]*)\\t([^\\t]*)\\t([^\\t]*)\\t([^\\t]*)\\t([^\\t]*)\\t([^\\t]*)\\t([^\\t]*)\\t([^\\t]*)\\t([^\\t]*)\\t([^\\t]*)\\t([^\\t]*)\\t([^\\t]*)\\t([^\\t]*)"))
         ans)
        ((eq :eof line)
         (subseq (nreverse ans) start end))
      (ppcre:register-groups-bind
          (asin isbn title author publisher year kind category tags point review memo flag created updated)
          (pat (string-trim #(#\Newline #\Return) line))
        (declare (ignorable asin isbn title author publisher year kind category tags point review memo flag created updated))
        (push (list "ASIN"
                    asin
                    title
                    (|YYYY-MM-DD HH:MM:SS-TO-YYYY/MM/DD| created)
                    "0"
                    review
                    tags
                    "")
              ans)))))

(defun list-to-tsv (list stream)
  (dolist (item list)
    (format stream
            #.(concatenate 'string
                           "~{~A~^"
                           (string #\Tab)
                           "~}~%")
            item)))

#|(g000001::with-output-to-browser (out)
  (list-to-tsv
   (booklog-to-byflow-list "~/booklog20110719195737.txt" 0 100)
   out))|#

;; eof