;; 接続系
(defmacro define-slime-connect-function (name host port)
  `(defun ,(intern (concat "slime-" (symbol-name name))) ()
     (interactive)
     (slime-connect ,host ,port)))

(define-slime-connect-function sbcl "localhost" 4005)
(define-slime-connect-function clisp "localhost" 4006)
(define-slime-connect-function cmu "localhost" 4007)
(define-slime-connect-function ecl "localhost" 4008)
(define-slime-connect-function allegro "localhost" 4009)
(define-slime-connect-function lw "localhost" 4010)
(define-slime-connect-function ccl "localhost" 4011)
(define-slime-connect-function clojure "localhost" 9696)
(define-slime-connect-function abcl "localhost" 4012)
(define-slime-connect-function scl "localhost" 4013)

(slime-setup '(slime-fancy
                                        ;slime-indentation
               ))

(setq slime-net-coding-system 'utf-8-unix)
(setq slime-autodoc-use-multiline-p t)
(setq slime-complete-symbol*-fancy t)
(setq slime-complete-symbol-function 'slime-fuzzy-complete-symbol)

;; インデント系
(progn
  ;; hooks
  (add-hook 'slime-mode-hook
            (lambda () 
              ;; indent
              ;; slime-indentationを使うと何故かずれるので対処
                                        ;(define-cl-indent '(let 1))
              ;(cond ((assoc 'Lowercase (buffer-local-variables))
               ;      (shift-lock-mode -1)
                ;     (message "=== shift-lock disabled ==="))
                 ;   ('T (shift-lock-mode 1)
                  ;      (message "=== shift-lock enabled ===")))
              ))
  
  '(add-hook 'inferior-lisp-mode-hook
             (lambda () (inferior-slime-mode t)))
  
  (add-hook 'clojure-mode-hook
            (lambda () (slime-mode t)))
  )

'(eval-after-load "slime-indentation"
  '(progn 
     (define-cl-indent '(defmethod defun))
     (define-cl-indent '(let 1))
     (define-cl-indent '(mapping 1))))