(IN-PACKAGE :G000001)

;; lispm
(defparameter user-id ""
  "The value of user-id is either the name of the logged in user,
as a string, or else an empty string if there is no user logged in.
 It appears in the who-line.")

;logout-list Variable
(defparameter logout-list ()
  "The value of logout-list is a list of forms
which are evaluated when a user logs out.")

(defun login (name &optional (load-init))
  "If anyone is logged into the machine, login logs him out.
 (See logout .) Then user-id is set from name.
 Finally login attempts to find your INIT file.
It first looks in \"user-id ; .LISPM (INIT)\", then in \"(INIT);
user-id .LISPM\", and finally in the default init file
 \"(INIT); * .LISPM\". When it finds one of these that exists,
 it loads it in. login returns t ."
  (setq user-id (string name))
  (unless load-init
    (load (merge-pathnames "lispm.init" (user-homedir-pathname)))))

(defun logout (&optional name)
  "First, logout evaluates the forms on logout-list.
 Then it tries to find a file to run, looking first in
\"user-id ; .LSPM_ (INIT)\", then in \"(INIT); user-id .LSPM_\",
and finally in the default file \"(INIT); * .LSPM_\".
If and when it finds one it these that exists,
it loads it in. Then it sets user-id to an empty string and
 logout-list to nil , and returns t ."
  (declare (ignore name))
  (setq user-id "")
  (eval `(progn ,@logout-list))
  (setq logout-list () ))


(defmacro setq-return-undo (var val)
;  "setqを実行し、実行内容をアンドゥする式を返す。2値目は、setqの返り値"
  `(let ((undo (if (boundp ',var)
		   '(setq ,var ',(and (boundp var) (symbol-value var)))
		   '(makunbound ',var))))
     (push undo logout-list)
     (values undo (setq ,var ,val))))

(defmacro login-setq (&rest form)
  "login-setq is like setq except that it puts a setq form on
 logout-list to set the variables to their previous values."
  `(progn
     ,@(do ((l form (cddr l))
	    (res () (cons `(nth-value 1 (setq-return-undo ,(car l) ,(cadr l)))
			  res)))
	   ((endp l) (nreverse res)))))

;(login-setq foo 33 bar 44)

;login-eval x
(defmacro login-eval (&rest form)
  "login-eval is used for functions which are \"meant to be called\"
from INIT files, such as eine:ed-redefine-keys,
which conveniently return a form to undo what they did.
 login-eval adds the result of the form x to the logout-list."
  `(progn
     ,@(loop :for l :in form
	     :collect `(push ,l logout-list))))


;;; eof