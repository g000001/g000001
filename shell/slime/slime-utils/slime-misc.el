;; letのバインディング部分の編集を楽にしたい
(progn
  (defun edit-let-bind ()
    (interactive)
    (let ((foundp nil))
      (save-excursion
        (catch 'loop
          (while (not (c-at-toplevel-p))
            (backward-up-list)
            (down-list)
            (let ((thing (thing-at-point 'symbol)))
              (cond ((or (string= "LET" (upcase thing))
                         (string= "DO" (upcase thing)))
                   (down-list)
                   (setq foundp t)
                   (throw 'loop nil))
                  ('T (backward-up-list))))))
        (when foundp
          (recursive-edit)))))
  ;; keybind
  (define-key global-map [(control meta shift ?c)] 'edit-let-bind))


;; CLtL2も参照したい
;;   http://sourceforge.jp/projects/sfnet_ilisp/
;;   ilispの配布物のなかにcltl2.elは含まれている
(load "lisp/cltl2")
(eval-after-load "cltl2"
  '(progn
     (require 'cltl2)
     (defalias 'slime-cltl2-lookup 'cltl2-lookup)
     ;(setq cltl2-root-url "http://l:10081/docs/cltl/")
     (setq cltl2-root-url "http://www.cs.cmu.edu/Groups/AI/html/cltl/")
     ))

;; Gauche
(progn
  (defun gauche-ref-lookup ()
    (interactive)
    (browse-url
     (format "http://practical-scheme.net/gauche/man/?l=jp&p=%s" (thing-at-point 'symbol))))

  (define-key slime-mode-map [(control ?c) (control ?d) (shift ?h)] 'gauche-ref-lookup))

;; HyperSpecとCLtL2をいっぺんに開く
(defun slime-cltl2-&-hyperspec-lookup (symbol-name)
    (interactive
     (list (let ((symbol-at-point (thing-at-point 'symbol)))
             (if (and symbol-at-point
                      (intern-soft (downcase symbol-at-point)
                                   cltl2-symbols))
                 symbol-at-point
               (completing-read
                "Look up symbol in CLtL2: "
                cltl2-symbols #'boundp
                t symbol-at-point
                'cltl2-history)))))
    (slime-cltl2-lookup symbol-name)
    (slime-hyperspec-lookup symbol-name))

;; AMOPを開く
(progn
  (defun amop-lookup (&optional symbol-name)
    "シンボルをmilkode@localhostで検索"
    (interactive)
    (browse-url
     (format "http://www.alu.org/mop/dictionary.html#%s"
             (or symbol-name
                 (thing-at-point 'symbol)) )))
  ;; (defun amop-lookup ()
  ;;   (interactive)
  ;;   (browse-url
  ;;    (format "http://www.alu.org/mop/dictionary.html#%s"
  ;;            (let* ((name (thing-at-point 'symbol))
  ;;                   (pos (position ?: name)))
  ;;              (if pos
  ;;                  (subseq name (1+ pos))
  ;;                name)))))

  ;; (define-key slime-mode-map [(control ?c) (control ?d) ?m] 'amop-lookup)
  )

;; Google Code Searchで検索
(defun gcode-lookup ()
  "カーソル位置のシンボルをGoogle Codeで検索(lisp決め打ち)"
  (interactive)
  (browse-url
   (format "http://www.google.com/codesearch?q=%s+lang:%s+file:\\.%s$&hl=ja&num=20"
           (thing-at-point 'symbol) "lisp" "lisp")))

(define-key slime-mode-map [(control ?c) (control ?d) ?g] 'gcode-lookup)

(defun searchco.de-lookup (&rest args)
  "カーソル位置のシンボルをsearchco.deで検索(lisp決め打ち)"
  (interactive)
  (browse-url
   (format "http://searchco.de/?q=lang%%3A%s+%s+ext%%3A%s"
            "lisp" (thing-at-point 'symbol) "lisp")))

;; 良く分からない
(defun indent-or-complete (&optional arg)
  (interactive "p")
  (if (or (looking-back "^\\s-*") (bolp))
      (call-interactively 'lisp-indent-line)
    (call-interactively 'slime-indent-and-complete-symbol)))

(progn
  ;; indent
  (setq cl-indent-indenting-loop-macro-keyword
        "when\\|unless\\|if\\|:when\\|:unless\\|:if")
  (setq cl-indent-prefix-loop-macro-keyword
        "and\\|else\\|:and\\|:else")
  ;; slime-indentationを使うと何故かずれるので対処
                                        ;(define-cl-indent '(let 1))
  )


(setq *default-lisp-program* 'slime-sbcl)
(defvar *current-lisp-program* *default-lisp-program*)

(defun env-cl (implementation-type)
  (interactive "p")
  (let ((wd "~/lisp/work")
        (slime ))
    (cd wd)
    (if (minusp implementation-type)
        (let ((lisp (read-string "Which LISP Implementation?:")))
          (cond
           ;; 空の文字列があたえられれば、デフォルトの処理系を起動
           ((string= "" lisp)
            (or (slime-connected-p)
                (funcall *default-lisp-program*)))
           ;; 指定された場合、slime-fooという風に関数名を合成し、
           ;; 指定の処理系でSLIMEを起動
           ('T (funcall (intern (concat "slime-" lisp)))
               (setq *lisp-program* lisp))))
      ;; 引数を与えられていない場合は接続があるなら、
      ;; そのまま無ければ起動
      (or (slime-connected-p)
          (funcall *default-lisp-program*)))
    (delete-other-windows)
    (switch-to-buffer
     (find-file (format "%s/%s%s%s"
                        wd
                        "cl-"
                        (format-time-string "%Y-%m-%d" (current-time)) ".lisp")))))

(defun env-slime (implementation-type)
  (interactive "p")
  (let ((wd "~/lisp/work/g000001-cl-daily-scratch")
        (slime ))
    (cd wd)
    (let (lisp)
      (if (minusp implementation-type)
          (progn
            (setq lisp (read-string "Which LISP Implementation?:"))
            (cond
             ;; 空の文字列があたえられれば、デフォルトの処理系を起動
             ((string= "" lisp)
              (or (slime-connected-p)
                  (funcall *default-lisp-program*)))
             ;; 指定された場合、slime-fooという風に関数名を合成し、
             ;; 指定の処理系でSLIMEを起動
             ('T (funcall (intern (concat "slime-" lisp)))
                 (setq *lisp-program* lisp))))
        ;; 引数を与えられていない場合は接続があるなら、
        ;; そのまま無ければ起動
        (or (slime-connected-p)
            (funcall *default-lisp-program*)))
      (delete-other-windows)
      (switch-to-buffer
       (if (and lisp (string= "clojure" lisp))
           (find-file (format "%s/%s-%s%s"
                              wd
                              "clojure"
                              (format-time-string "%Y-%m-%d" (current-time)) ".clj"))
         (find-file (format "%s/%s%s%s"
                            wd
                            "cl-"
                            (format-time-string "%Y-%m-%d" (current-time)) ".lisp")))))))

(define-key slime-mode-map [(hyper ?i)]
  (defun insert-ignore-declaration ()
    (interactive)
    (backward-sexp 1)
    (insert "(declare (ignore ")
    (forward-sexp 1)
    (insert "))") ))


(defun dq-start-at ()
  (save-excursion
    (while (in-string-p)
      (backward-char 1))
    (current-column)))


(define-key slime-mode-map [(control return)] ;; [(control ?~)]
  (defun slime-format-ignored-newline (arg)
    (interactive "P")
    (cond ((in-string-p)
           (let ((start (1+ (dq-start-at))))
             (if (null arg) (insert "~"))
             (newline)
             (while (not (minusp (cl-decf start)))
               (insert " "))))
          (t (insert "~")))))

;; (define-key slime-mode-map [(control ?~)]
;;   (defun slime-format-ignored-newline ()
;;     (interactive)
;;     (and (in-string-p)
;;          (let* ((find-\" (lambda (n)
;;                            (string-match "\"" 
;;                                          (concat (nreverse (string-to-list thing)))
;;                                          (or n 0) )))
;;                 (thing (thing-at-point 'line))
;;                 ;; FIXME
;;                 (start (funcall find-\" 
;;                                 (1+ (funcall find-\" 0)) )))
;;            (insert "~")
;;            (cond (start
;;                    ;; (message (format "%s: %s" start thing))
;;                    (split-line)
;;                    (next-line)
;;                    (delete-backward-char (- start 2)) )
;;                  (t (let ((beg (string-match "\\S " thing)))
;;                       (newline)
;;                       (insert (make-string beg 32)) )))))))

;; 

;; slime no hello repl

;; override
'(defun slime-set-connection-info (connection info)
  "Initialize CONNECTION with INFO received from Lisp."
  (let ((slime-dispatching-connection connection)
        (slime-current-thread t))
    (destructuring-bind (&key pid style lisp-implementation machine
                              features version modules encoding
                              &allow-other-keys) info
      (slime-check-version version connection)
      (setf (slime-pid) pid
            (slime-communication-style) style
            (slime-lisp-features) features
            (slime-lisp-modules) modules)
      (destructuring-bind (&key type name version program) lisp-implementation
        (setf (slime-lisp-implementation-type) type
              (slime-lisp-implementation-version) version
              (slime-lisp-implementation-name) name
              (slime-lisp-implementation-program) program
              (slime-connection-name) (slime-generate-connection-name name)))
      (destructuring-bind (&key instance ((:type _)) ((:version _))) machine
        (setf (slime-machine-instance) instance))
      (destructuring-bind (&key coding-systems) encoding
        (setf (slime-connection-coding-systems) coding-systems)))
    (let ((args (when-let (p (slime-inferior-process))
                  (slime-inferior-lisp-args p))))
      (when-let (name (plist-get args ':name))
        (unless (string= (slime-lisp-implementation-name) name)
          (setf (slime-connection-name)
                (slime-generate-connection-name (symbol-name name)))))
      (slime-load-contribs)
      ;;(shobon-shakin)
      ;; (run-hooks 'slime-connected-hook)
      
      (when-let (fun (plist-get args ':init-function))
        (funcall fun)))
    (message "Connected. %s" (slime-random-words-of-encouragement))))

(defun slime-sbcl nil
  (interactive)
  (slime-connect "localhost" 4005)
  ;; (shobon-shakin)
  )


(define-key slime-mode-map [(control ?c) (control ?z)]
  (lambda ()
    (interactive)
    (slime-repl-connected-hook-function)
    (slime-switch-to-output-buffer)))


(defun slime-current-readtable-name ()
  (interactive)
  (slime-eval `(named-readtables:readtable-name
                (swank::guess-buffer-readtable 
                 ,(slime-current-package)))))

(defun arc-indentation-p (rt)
  (or (string-equal :g1.arc rt)
      (string-equal :arc rt)))


(defun slime-frob-indentation ()
  (interactive)
  (let ((rt (slime-current-readtable-name)))
    (cond ((arc-indentation-p rt)
           (slime-eval-async '(swank:eval-in-emacs 
                               '(|progn|
                                 (|def-lisp-indentation| |let| 2)
                                 (|def-lisp-indentation| |do| 0)
                                 (|def-lisp-indentation| |loop| 3)))))
          (t (message "nop")))))


(defadvice indent-region (before change-readtable activate)
  (slime-frob-indentation))
