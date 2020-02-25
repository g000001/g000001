;;;; stumpwm-setagaya-library-utilities.lisp

(cl:in-package :stumpwm-setagaya-library-utilities-internal)

(def-suite stumpwm-setagaya-library-utilities)

(in-suite stumpwm-setagaya-library-utilities)

(defvar *setagaya-library-login-uri*
  "https://libweb.city.setagaya.tokyo.jp/clis/login" )

(defvar *previous-login-time* 0)

(defun load-password ()
  "~/.setagaya_libraryには、((\"UID\" . \"foo\") (\"PASS\" . \"bar\"))というalist形式で記述"
  (with-open-file (in (merge-pathnames ".setagaya_library"
                                       (user-homedir-pathname) ))
    (read in) ))

(defun request (url &key (method :get) parameters)
  (multiple-value-bind (body stat)
                       (drakma:http-request url
                                            :parameters parameters
                                            :method method
                                            :force-binary T)
    (values (babel:octets-to-string body :encoding :cp932)
            stat )))

(let (cache)
  (defun login ()
    (if (< (+ *previous-login-time* (* 60 8))
           (get-universal-time) )

        (multiple-value-bind (body stat)
                             (request *setagaya-library-login-uri*
                                      :method :post
                                      :parameters (load-password))
          (when (= 200 stat)
            (setq *previous-login-time* (get-universal-time)
                  cache body)
            body ))

        cache )))

(defun menu ()
  (let ((ans '() ))
    (stp:do-recursively (a (chtml:parse (login)
                                        (stp:make-builder) ))
      (when (and (typep a 'stp:element)
                 (equal (stp:local-name a) "a") )
        (setq ans
              (acons (stp:string-value (stp:nth-child 0 a))
                     (stp:attribute-value a "href")
                     ans ))))
    ans ))

(defun reservation-status-uri ()
  (cdr (assoc "予約状況照会へ" (menu) :test #'string=)) )

(defun rental-status-uri ()
  (cdr (assoc "貸出状況照会へ" (menu) :test #'string=)) )


;;; ================================================================


(defstruct (book (:type list))
  num type title library-name booking-date status due)


(defun rental-status-page ()
  (multiple-value-bind (body stat)
                       (drakma:http-request (rental-status-uri)
                                            :force-binary T)
    (when (= 200 stat)
      (chtml:parse (babel:octets-to-string body :encoding :cp932)
                   (stp:make-builder)))))


(defstruct checked-out-book
  num type title library-name id due detail-uri bibid isbn)


(defun checked-out-book-detail-page (uri)
  (multiple-value-bind (body stat)
                       (drakma:http-request uri
                                            :force-binary T)
    (when (= 200 stat)
      (chtml:parse (babel:octets-to-string body :encoding :cp932)
                   (stp:make-builder)))))


(defun fill-bibid-isbn (cobook)
  (check-type cobook checked-out-book)
  (let ((page (checked-out-book-detail-page
               (checked-out-book-detail-uri cobook))))
    (xpath:with-namespaces (("" (stp:namespace-uri (stp:document-element page))))
      (flet ((first-text (nset)
               (let ((n (xpath:first-node nset)))
                 (if n
                     (ppcre:regex-replace-all "(\\s|-)" (stp:string-value n) "")
                     ""))))
        (setf (checked-out-book-isbn cobook)
              (first-text (xpath:evaluate "//th[text()='ＩＳＢＮ']/../td|//th[text()='発売番号']/../td" page))
              (checked-out-book-bibid cobook)
              (first-text (xpath:evaluate "//th[text()='書誌番号']/../td" page))))))
  cobook)


(defun checked-out-books (&optional (page (rental-status-page)))
  (xpath:with-namespaces (("" (stp:namespace-uri (stp:document-element page))))
    (let* ((ans '() )
           (table (xpath:map-node-set->list #'identity 
                                            (xpath:evaluate "//tbody//tr" page)))
           stat overdue)
      (when table
        (destructuring-bind (s o &rest items)
                            table
          (setq stat (stp:map-children 'list #'stp:string-value s))
          (setq overdue (stp:map-children 'list #'stp:string-value o))
          (dolist (c items)
            (let* ((book (make-checked-out-book))
                   (query (stp:map-children
                           'list
                           (lambda (e)
                             (stp:do-recursively (a e)
                               (when (and (typep a 'stp:element)
                                          (string= "a" (stp:local-name a)))
                                 (setf (checked-out-book-detail-uri book)
                                       (stp:attribute-value a "href"))))
                             (stp:string-value e))
                           c)))
              (when query
                (destructuring-bind (num type title library-name id due)
                                    query
                  (setf (checked-out-book-num book) num
                        (checked-out-book-type book) type
                        (checked-out-book-title book) title
                        (checked-out-book-library-name book) library-name
                        (checked-out-book-id book) id
                        (checked-out-book-due book) due)
                  (fill-bibid-isbn book)))
              (push book ans)))))
      (values ans stat overdue))))


(defun reservation-page ()
  (multiple-value-bind (body stat)
                       (drakma:http-request (reservation-status-uri)
                                            :force-binary T)
    (when (= 200 stat)
      (chtml:parse (babel:octets-to-string body :encoding :cp932)
                   (stp:make-builder)))))


(defun reservation-data (page)
  ;; 1) trノードを全部拾って
  ;; 2) n図書という文字列(string-value)を拾って(手抜き)
  ;; 3) bookのリストにする
  (xpath:with-namespaces (("x" (stp:namespace-uri (stp:document-element page))))
    (mapcar (lambda (e)
              (stp:map-children 'cl:list #'stp:string-value 
                                e))
            (remove-if-not (lambda (e)
                             ;; 手抜き
                             (ppcre:scan "^\\d+(図書|ＡＶ)"
                                         (stp:string-value e) ))
                           (xpath:all-nodes (xpath:evaluate "//x:tr" page)) ))))


(defun reservation-status ()
  (let ((dat (reservation-data (reservation-page))))
    (list (length dat)
          (count-if (lambda (b) (string= "用意できています" (book-status b)))
                    dat))))


(defun reservation-status-string (&optional (status (reservation-status)))
  (format nil "~A/~A" (second status) (first status)))



(defun overdues ()
  (let ((bs (parse-integer (elt (nth-value 2 (checked-out-books)) 5)
                           :junk-allowed T)))
    (and (not (zerop bs)) bs)))


(defvar *resv-prev-time* 0)


(defvar *resv-prev-stat-string* "something went wrong.")


(defvar *overdues* "something went wrong.")


(defun watch-reservation-status ()
  (let ((cur (get-universal-time)))
    (when (< (* 30 60) (- cur *resv-prev-time*))
      (setq *resv-prev-stat-string*
            (ignore-errors (reservation-status-string))
            *overdues*
            (ignore-errors (overdues))
            *resv-prev-time* cur))
    (format nil
            "~A ~A"
            (or *resv-prev-stat-string* "error")
            (when *overdues* (format nil "^b overdues:[^[^7*~D^]]" *overdues*)))))


;;; eof
