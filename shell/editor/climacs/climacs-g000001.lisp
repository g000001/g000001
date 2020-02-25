;;;; climacs-g000001.lisp

(in-package #:climacs-g000001)

;;; "climacs-g000001" goes here. Hacks and glory await!

;;;; quekさんの設定より

;; C-h をバックスペースにするために、C-h のキーストロークを削除。
(clim:remove-keystroke-from-command-table 'esa:help-table
                                          '(:keyboard #\h 512)
                                          :errorp nil)
;; C-h でバックスペース
(esa:set-key `(drei-commands::com-backward-delete-object
               ,clim:*numeric-argument-marker*
               ,clim:*numeric-argument-marker*)
             'drei:deletion-table
             '((#\h :control)))
;; C-m newline and indent
(esa:set-key 'drei-lisp-syntax::com-newline-indent-then-arglist
             'drei-lisp-syntax:lisp-table
             '((#\m :control)))
;; C-/ undo
(esa:set-key 'drei-commands::com-undo
             'drei:editing-table
             '((#\/ :control)))
;; C-i で補完
(esa:set-key 'drei-lisp-syntax::com-indent-line-and-complete-symbol
             'drei-lisp-syntax:lisp-table
             '((#\i :control)))


(in-package :climacs-commands)

(setf (logical-pathname-translations "SYS")
      '(("SYS:SRC;**;*.*.*" "/share/sys/cl/src/sbcl-1.0.45/src/**/*.*")
        ("SYS:CONTRIB;**;*.*.*" "/share/sys/cl/src/sbcl-1.0.45/contrib/**/*.*")))

(defun insert-doublequotes (mark syntax count)
  (insert-pair mark syntax count #\" #\"))

(define-command (com-insert-doublequotes :name t :command-table editing-table)
    ((count 'integer :prompt "Number of expressions" :default 1)
     (wrap-p 'boolean :prompt "Wrap expressions?" :default nil))
  ""
  (unless wrap-p (setf count 0))
  (insert-doublequotes (point) (current-syntax) count))

;; m-;


;; c-X c-O
;; FIXME
(defun delete-blank-lines ()
  (let ((whitechars '(#\Newline #\Space #\Tab)))
    (loop :for char := (object-before (point)) :while (member char whitechars)
          :do (backward-delete-object (point))
          :finally  (insert-object (point) #\Newline))
    (loop :for char := (object-after (point)) :while (member char whitechars)
          :do (forward-delete-object (point))
          :finally (progn
                     (insert-object (point) #\Newline)
                     (previous-line (point) 1)))))

(define-command (com-delete-blank-lines :name t :command-table editing-table) ()
  ""
  (delete-blank-lines))

(set-key '(com-delete-blank-lines)
         'editing-table
         '((#\x :control) (#\o :control)))


;; structeditに既に存在する模様
;; m-"
(set-key `(com-insert-doublequotes ,*numeric-argument-marker* ,*numeric-argument-marker*)
         'editing-table
         '((#\" :meta)))

;; m-sh-Lで括弧を挿入
(set-key `(drei-commands::com-insert-parentheses ,*numeric-argument-marker* ,*numeric-argument-marker*)
         'editing-table
         '((#\L :meta)))

#|(climacs:climacs)|#

#|(setq climacs::*background-color*
      (make-instance 'clim-internals::named-color
         :name "foo"
         :red (/ 00 #xff)
         :green (/ #x31 #xff)
         :blue (/ #x42 #xff)))|#

#|(setq climacs::*foreground-color*
      (make-instance 'clim-internals::named-color
         :name "bar"
         :red (/ #xff #xff)
         :green (/ #xff #xff)
         :blue (/ #xab #xff)))|#

(in-package :esa-io)

(defvar *common-lisp-working-directory*
  (merge-pathnames "lisp/work/"
                   (user-homedir-pathname)))

(defun todays-cl-file ()
  (merge-pathnames (make-pathname :name (format nil "cl-~A" (hw::yyyy-mm-dd))
                                  :type "lisp")
                   *common-lisp-working-directory*))

(define-command (com-open-todays-cl-file :name t :command-table esa-io-table)
    ()
  ""
  (handler-case (esa-io:com-find-file (todays-cl-file))
    (file-error (e)
      (display-message "~A" e))))

(set-key `(com-open-todays-cl-file ,*unsupplied-argument-marker*)
         'esa-io-table '((#\l :super)))

(defun how-many-days-old (from-ut)
  (let ((seconds (- (get-universal-time)
                    from-ut)))
    (values (truncate seconds (* 24 60 60)))))

(defvar *gazonk-file-directory*
  (merge-pathnames "tmp/" (user-homedir-pathname)))

(define-command (com-open-gazonk-file :name t :command-table esa-io-table)
    ()
  ""
  (handler-case (esa-io:com-find-file
                 (merge-pathnames
                  (format nil
                          "g~A.del"
                          (1+ (how-many-days-old
                               (encode-universal-time 0 0 0 4 5 1974))))
                  *gazonk-file-directory*))
    (file-error (e)
      (display-message "~A" e))))

(set-key `(com-open-gazonk-file ,*unsupplied-argument-marker*)
         'esa-io-table '((#\g :super)))

(in-package :esa-io)

(defmacro with-climacs (&body body)
  `(let ((clim:*application-frame* (clim:find-application-frame 'climacs-gui:climacs)))
     (drei:with-bound-drei-special-variables (clim:*application-frame*)
       ,@body)))


(in-package :drei-commands)

;; Mark Definition
(set-key `(com-mark-definition 1) ;nilが渡る可能性があったので対策
	 'marking-table
	 '((#\h :control :meta)))

;; Mark Expression
(set-key `(com-mark-expression ,*numeric-argument-marker*)
	 'marking-table
	 '((#\Space :control :meta)))

(set-key `(com-mark-expression ,*numeric-argument-marker*)
	 'drei-lisp-syntax:lisp-table
	 '((#\Space :control :meta)))


;; end