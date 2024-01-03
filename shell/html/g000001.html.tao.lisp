;;;; g000001.html.lisp -*- Mode: Lisp;-*- 
(tao:tao)

(cl:in-package :g000001.html.internal)


;(in-readtable :tao)


;; (in-readtable :g000001.html)

(de choose-elt (item shtml)
  (collect
    (choose-if (lambda (elt)
                 (and (consp elt)
                      (equal item (car elt)) ))
               (scan-lists-of-lists shtml) )))


(de title-filter (str)
  (ppcre:regex-replace-all "((?:&nbsp;)+|\\n+|\\s+)"
                           str
                           " "))


(de get-title-simple (uri)
  (with-input-from-string (str (g000001.ja:decode-jp
                                (drakma:http-request uri
                                                     :force-binary 'T)))
    (first
     (mapcar (kl:compose #'title-filter #'second)
             (choose-elt :title
                         (html-parse:parse-html str))))))


(de html-page-to-string (uri)
  (g000001.ja:decode-jp (drakma:http-request uri :force-binary 'T)))


#|(de html-to-stp (html-string)
  (chtml:parse html-string (cxml-stp:make-builder)))|#

(de html-to-dom (html-string)
  (plump:parse html-string))


#|(de get-title (uri)
  (handler-case (let* ((page (html-page-to-string uri))
                       (stp  (html-to-stp page))
                       (ns   (stp:namespace-uri (stp:document-element stp))) )
                  (xpath:with-namespaces (("" ns))
                    (xpath:string-value
                     (xpath:first-node (xpath:evaluate "//title" stp)) )))
    ((or cl:error #+sbcl sb-kernel::control-stack-exhausted) ()
      (get-title-simple uri))))|#


(de get-title (uri)
  (handler-case (let* ((page (html-page-to-string uri))
                       (dom  (html-to-dom page))
                       (title (clss:select "title" dom)))
                  (and title (plump:text title)))
    ((or cl:error #+sbcl sb-kernel::control-stack-exhausted) ()
      (get-title-simple uri))))


(defmacro with-output-to-browser ((stream &key (browser "firefox")) &body body)
  (let ((filename (format nil "/mc/tmp/~A.html" (gensym "__tempfile-"))))
    `(macrolet ((#0=#:command-output-status (form) `(nth-value 2 ,form)))
       (with-open-file (,stream ,filename :direction :output :if-exists :supersede)
         ,@body)
       (zerop (#0# (kl:command-output "~A ~A" ,browser ,filename))))))


(de pp-aa (str)
  (with-output-to-browser (out)
    (yaclml:with-yaclml-stream out
      (<:pre :style "font-family:'giko','ＭＳ Ｐゴシック','ＭＳＰゴシック','MSPゴシック','MS Pゴシック';font-size:16px;line-height:17px;"
             (<:format str)))))


;;; *EOF*
