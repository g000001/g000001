;;;
;;; 定義を自分好みに再定義系
;;;

'(progn
  ;; 
  ;; edit-definitionで(setf foo)を拾えるようにする
  ;; 
  
  ;; slime-read-function-name に変更しただけ
  (defun slime-edit-definition (name &optional where)
    "Lookup the definition of the name at point.  
If there's no name at point, or a prefix argument is given, then the
function name is prompted."
    (interactive (list (slime-read-function-name "Name: ")))
    (or (run-hook-with-args-until-success 'slime-edit-definition-hooks 
                                          name where)
        (slime-edit-definition-cont (slime-find-definitions name)
                                    name where)))
  
  ;; Emacsは大文字小文字を区別するんだよなー
  (defun STRING-EQUAL (x y)
    (string-equal (upcase (symbol-name x))
                  (upcase (symbol-name y))))

  ;; setf関数名を取り出す
  (defun setf-function-name (str)
    (let ((expr (slime-eval `(cl:read-from-string 
                              ,(substring-no-properties str)))))
      (cond 
        ;; (setf ...)
        ((STRING-EQUAL 'setf (car expr))
         (format "%s" expr))
        ;; #'(setf ...)
        ((and (STRING-EQUAL 'function (car expr))
              (STRING-EQUAL 'setf (car (cadr expr))))
         (format "%s" (cadr expr)))
        ((listp expr) (format "%s" (car expr)))
        (t (format "%s" expr)))))
  
  (defun slime-function-name-at-point ()
    (let ((name (thing-at-point 'list)))
      (if (and name (setf-function-name name))
          (setf-function-name name)
        (slime-symbol-at-point))))
  
  (defun slime-read-function-name (prompt &optional query)
    (cond ((or current-prefix-arg query (not (slime-function-name-at-point)))
           (slime-read-from-minibuffer prompt (slime-function-name-at-point)))
          (t (slime-function-name-at-point)))))





(progn
  ;;
  ;; fmakunboundで、(setf foo)を拾う
  ;; 
  (defun slime-undefine-function (symbol-name)
    "Unbind the function slot of SYMBOL-NAME."
    (interactive (list (slime-read-function-name "fmakunbound: " t)))
    (slime-eval-async `(swank:undefine-function ,symbol-name)
      (lambda (result) (message "%s" result))))
  
  )


(setq slime-repl-history-size 500000)
(setq slime-repl-history-trim-whitespaces nil)
