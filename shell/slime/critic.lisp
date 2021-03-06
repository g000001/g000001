(defun swank::lisp-critic (string &key (timeout 1000))
  (let ((mesgs (with-output-to-string (*standard-output*)
                 (lisp-critic:critique-definition (read-from-string string)))))
    #+(:or :sbcl :allegro :ccl :lispworks :clisp)
    (dolist (m (remove "" (ppcre:split "\\s*-{10,}\\s*" mesgs) :test #'string=))
      (notify-send "Lisp Critic" m :timeout timeout)))
  nil)
