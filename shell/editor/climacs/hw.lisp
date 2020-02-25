(defpackage :hw
  (:use :cl :drakma :kmrcl)
  (:export :login :logout
           :post-entry :delete-entry
           :post-todays-entry
           :post-todays-group-entry))

(in-package :hw)

(setq *drakma-default-external-format* :utf-8)

(defvar *outputz* (make-hash-table :test #'equal))

(declaim (inline sconc))
(defun sconc (&rest args)
  (apply #'concatenate 'string args))

(defun read-password-file (&optional (path (merge-pathnames ".hatena" (user-homedir-pathname))))
  (aif (probe-file path)
       (with-open-file (str it :direction :input)
         (let ((user-alist (read str nil nil)))
           (values (cdr (assoc :username user-alist))
                   (cdr (assoc :password user-alist)))))
       (error "初期化ファイル:~~/.hatenaが存在していません。:~A" path)))


(defun read-outputz-init (&optional (path (merge-pathnames ".outputz" (user-homedir-pathname))))
  (aif (probe-file path)
       (with-open-file (str it :direction :input)
         (values (read str nil nil)))
       (error "初期化ファイル:~~/.outputzが存在していません。:~A" path)))

#|(defmacro hr-post (url &rest params)
  `(http-request ,url
                 :external-format-in :utf-8
                 :external-format-out :utf-8
                 :method :post
                 ,@params))|#

(defun hr-post (url &rest params)
  (let ((*drakma-default-external-format*
         (flexi-streams:make-external-format :utf-8 :eol-style :crlf)))
    (apply #'http-request url :method :post params)))

(defun login ()
  (let ((cj (make-instance 'cookie-jar)))
    (multiple-value-bind (user password)
        (read-password-file)
      (values cj
              (hr-post "https://www.hatena.ne.jp/login"
                       :cookie-jar cj
                       :parameters `(("name" . ,user)
                                     ("password" . ,password)))))))

(defun rkm (cj base-url)
  (aand (nth-value 1
          (ppcre:scan-to-strings
           "rkm.*'(.*)'"
           (hr-post (sconc base-url "/edit") :cookie-jar cj)))
        (aref it 0)))

(defun *yyyymmdd (delimiter)
  (multiple-value-bind (ig no re d mo y)
      (decode-universal-time (get-universal-time))
    (declare (ignore ig no re))
    (format nil "~D~A~2,'0D~A~2,'0D" y delimiter mo delimiter d)))

(defun yyyymmdd () (*yyyymmdd ""))
(defun yyyy-mm-dd () (*yyyymmdd "-"))

(defun post-entry (base-url text cj &optional date)
  (let ((date (or date (yyyymmdd))))
    (ppcre:register-groups-bind (y m d) ("(....)(..)(..)" date)
      (hr-post (sconc base-url "/edit")
               ;:content-type "application/x-www-form-urlencoded"
               :content-type "multipart/form-data"
               :cookie-jar cj
               :parameters
               `(("mode" . "enter")
                 ("rkm" . ,(rkm cj base-url))
                 ("date" . ,d)
                 ("trivial" . "0")
                 ("year" . ,y)
                 ("month" . ,m)
                 ("day" . ,d)
                 ("title" . "")
                 ("body" . ,text))))
    (let ((outputz (FLOOR (length (flexi-streams:string-to-octets text :external-format :utf-8))
                          2))
          (prev (gethash (yyyymmdd) *outputz*)))
        (let ((uri "http://cadr.g.hatena.ne.jp/g000001/")
              (size (princ-to-string
                     (if prev
                         (max 1 (- outputz (gethash (yyyymmdd) *outputz*)))
                         outputz)))
              (key (read-outputz-init)))
            (http-request (apply #'format nil
                                 "http://outputz.com/api/post?uri=~A&size=~D&key=~A"
                                 (mapcar #'url-rewrite:url-encode (list uri size key)))
                          :method :post)
          (setf (gethash (yyyymmdd) *outputz*)
                outputz)))))


(defun clear-entry (base-url cj &optional date)
  (let ((date (or date (yyyymmdd))))
    (ppcre:register-groups-bind (y m d) ("(....)(..)(..)" date)
      (hr-post (sconc base-url "/edit")
               :content-type "application/x-www-form-urlencoded"
               :cookie-jar cj
               :parameters
               `(("mode" . "enter")
                 ("rkm" . ,(rkm cj base-url))
                 ("date" . ,d)
                 ("trivial" . "0")
                 ("year" . ,y)
                 ("month" . ,m)
                 ("day" . ,d)
                 ("title" . "")
                 ("body" . ""))))))


;(setf (gethash (yyyymmdd) *outputz*) 2497)

;(gethash (yyyymmdd) *outputz*)


;              :content-length
;              (length
;               (flexi-streams:string-to-octets text :external-format :utf-8))))))

(defun delete-entry (base-url cj &optional date)
  (let ((date (or date (yyyymmdd))))
    ;; confirm
    (hr-post (sconc base-url "/edit")
             :cookie-jar cj
             :parameters
             `(("mode" . "delete")
               ("rkm" . ,(rkm cj base-url))
               ("date" . ,date)))
    ;; delete
    (hr-post (sconc base-url "/deletediary")
             :cookie-jar cj
             :parameters
             `(("mode" . "enter")
               ("rkm" . ,(rkm cj base-url))
               ("date" . ,date)))))

(defun delete-entry/euc-jp (base-url cj &optional date)
  (let ((date (or date (yyyymmdd))))
    ;; confirm
    (hr-post (sconc base-url "/edit")
             :cookie-jar cj
             :parameters
             `(("mode" . "delete")
               ("rkm" . ,(rkm cj base-url))
               ("date" . ,date)))
    ;; delete
    (hr-post (sconc base-url "/deletediary")
             :cookie-jar cj
             :parameters
             `(("mode" . "enter")
               ("rkm" . ,(rkm cj base-url))
               ("date" . ,date)))))


#|(defun file-to-string (file)
  (format nil "~{~A~%~}"
          (series:collect
            (series:scan-file file #'read-line))))|#


(defun readl (stream)
  (let ((line (read-line stream nil nil)))
    ;; cliki CLIKI:(.*) =>
    (setq line
          (ppcre:regex-replace-all " CLIKI:([^ ]+) "
                                   line
                                   (lambda (x y)
                                     (declare (ignore x))
                                     (format nil "[http://www.cliki.net/~A:title=~:*~A]" y))
                                   :simple-calls 'T))
    ;; github
    (setq line
          (ppcre:regex-replace-all " G1:([^ ]+) "
                                   line
                                   (lambda (x y)
                                     (declare (ignore x))
                                     (format nil "[https://github.com/g000001/~A:title=~:*~A]" y))
                                   :simple-calls 'T))
    ;;
    line))

(defun file-to-string (file)
  (format nil "~{~A~%~}"
          (with-open-file (in file :external-format :utf-8)
            (loop :for line := (readl in)
                  :while line
                  :collect line))))

#|(print (file-to-string "/u/mc/var/hatena/g000001/group/cadr/2008-12-15.txt"))|#

(defun logout (cj)
  (http-request "https://www.hatena.ne.jp/logout"
                :external-format-in :utf-8
                :external-format-out :utf-8
                :cookie-jar cj))

(defun group-url (group-name user-id)
  (sconc "http://" (string-downcase (string group-name)) ".g.hatena.ne.jp/" user-id))

(defun diary-url (user-id)
  (sconc "http://d.hatena.ne.jp/" user-id))

(defun post-todays-entry (file user-id &key group)
  (let ((base-url (if group (group-url group user-id) (diary-url user-id)))
        (cj (login)))
    (unwind-protect
         (progn
           ;(clear-entry base-url cj)
      ;     (print base-url)
           (delete-entry base-url cj)
           (post-entry base-url (file-to-string file) cj))
      (logout cj))))


(defun post-yyyymmdd-entry (file user-id &key group)
  (let ((base-url (sconc (if group (group-url group user-id) (diary-url user-id)) "/" (filename-to-yyyymmdd file)))
        (cj (login)))
    (unwind-protect
         (progn
           ;(clear-entry base-url cj)
           (delete-entry base-url cj)
           (post-entry base-url (file-to-string file) cj))
      (logout cj))))

(defun filename-to-yyyymmdd (filename)
  (format nil "~{~A~}"
          (coerce (nth-value 1 (ppcre:scan-to-strings "(....)-(..)-(..)\\.txt" filename))
                  'list)))

;(group-url :cadr "foo")
;(post-yyyymmdd-entry "/u/mc/var/hatena/g000001/group/cadr/2008-04-08.txt" home::*hatena-id* :group :cadr)
;(hw:post-todays-entry "/u/mc/var/hatena/g000001/group/cadr/2008-03-24.txt" *hatena-id* :group :cadr)

#|(let ((cj (hw:login))
      (base *hw-base-url*))
  (hw:delete-entry base cj)
  (hw:post-entry base
                 (hw::file-to-string "/u/mc/var/hatena/g000001/group/cadr/2008-03-02.txt")
           cj)
  (hw:logout cj))|#


;(hw::POST-YYYYMMDD-ENTRY
; "/u/mc/heihachi-darwin/var/hatena/g000001/group/cadr/2008-04-30.txt"
; "g000001" :GROUP "cadr")

(defun post-todays-group-entry ()
  (hw:post-todays-entry
   (make-pathname :directory #+lispworks "u" #-lispworks "/home"
		  :name (format nil "mc/var/hatena/g000001/group/cadr/~A" (hw::yyyy-mm-dd))
		  :type "txt")
   "g000001"
   :group :cadr))

(defun post-todays-entry* ()
  (hw:post-todays-entry
   (make-pathname :directory #+lispworks "u" #-lispworks "/home"
		  :name (format nil "mc/var/hatena/g000001/diary/~A" (hw::yyyy-mm-dd))
		  :type "txt")
   "g000001"))

(defvar *cadr.g.hatena.ne.jp-base-directory*
  (merge-pathnames "var/hatena/g000001/group/cadr/"
                   (user-homedir-pathname)))

(defun todays-file ()
  (merge-pathnames (make-pathname :name (yyyy-mm-dd)
                                  :type "txt")
                   *cadr.g.hatena.ne.jp-base-directory*))


(in-package :esa-io)

(define-command (com-open-todays-file :name t :command-table esa-io-table)
    ()
  ""
  (handler-case (esa-io:com-find-file (hw::todays-file))
    (file-error (e)
      (display-message "~A" e))))

(set-key `(com-open-todays-file ,*unsupplied-argument-marker*)
         'esa-io-table '((#\d :super)))

(define-command (com-insert-hatena-date :name t :command-table esa-io-table)
    ()
  ""
  (handler-case (drei-buffer:insert-sequence (point)
                                             (format nil
                                                     "*~A*"
                                                     (kl:utime-to-posix-time (get-universal-time))))
    (file-error (e)
      (display-message "~A" e))))


(define-command (com-post-todays-group-entry :name t :command-table esa-io-table)
    ()
  ""
  (handler-case (print (hw::post-todays-group-entry))
    (file-error (e)
      (display-message "~A" e))))

(set-key `(com-post-todays-group-entry ,*unsupplied-argument-marker*)
         'esa-io-table '((#\c :control) (#\p :control)))
