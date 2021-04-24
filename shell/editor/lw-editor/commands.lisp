;;;; -*- Mode: Lisp; coding: utf-8 -*- 
;;; "l:src;rw;g000001;shell;editor;lw-editor;commands.lisp"

(in-package editor)


(defvar *bind-key-forms* '())


(defun stash-bind-key-form (form)
  (pushnew form *bind-key-forms* :test #'equalp))


(defun funcall-or-never (pkg name &rest args)
  (let ((name (string name))
        (pkg (string pkg)))
    (if-let (fctn (find-symbol name pkg))
        (apply fctn args)
        (warn "Function: ~A::~A not found." pkg name))))


(defcommand "Tweet Region" (p)
     ""
     ""
  (declare (ignore p))
  (funcall-or-never :? :twe (buffer-region-as-string (current-buffer))))


(defcommand "Cat Tweet" (p)
     ""
     ""
  (declare (ignore p))
  (funcall-or-never :? :twe/catface (buffer-region-as-string (current-buffer))))


(defcommand "Cat Tweet Continuosly" (p)
       ""
       ""
    (declare (ignore p))
    (funcall-or-never :? :con/catface (buffer-region-as-string (current-buffer))))


(defcommand "Markdownify" (p)
     ""
     ""
  (declare (ignore p))
  (let ((remarkable.exe 
         (format nil
                 "remarkable ~S"
                 (namestring
                  (buffer-pathname (current-buffer))))))
    (message remarkable.exe)
    (system:run-shell-command remarkable.exe)))


(defcommand "Editor Only" (p)
     ""
     ""
  (declare (ignore p))
  (let* ((ifs (capi:screen-interfaces (car (capi:screens))))
         (editor (find-if (lambda (x)
                            (search "Editor" (capi:interface-title x)))
                          ifs)))
    (capi:raise-interface editor)
    (dolist (i ifs)
      (unless (typep i 'lispworks-tools:editor)
        ;; (capi:quit-interface i)
        (capi:destroy i)))))


(defun count-white-spaces-to-the-next-sxp ()
  (let ((cnt 0))
    (block nil
      (map nil
           (lambda (c)
             (if (find c #(#\Space #\Newline #\Return #\Tab))
                 (incf cnt)
                 (return)))
           (points-to-string (current-point)
                             (editor::point-next (current-point)))))
    cnt))


(defun list-all-interfaces ()
  (let* ((ans (list nil))
         (tem ans))
    (dolist (s (capi:screens) (cdr ans))
      (dolist (i (capi:screen-interfaces s))
        (setf (cdr tem)
              (setq tem (list i)))))))


(defun the-top-interface ()
  (first (capi:collect-interfaces 'capi:interface :sort-by :visible)))


(defcommand "The Top Interface" (p)
     ""
     ""
  (declare (ignore p))
  (message (format nil "~A" (the-top-interface))))


(defun funcall-or-never (pkg name &rest args)
  (let ((name (string name))
        (pkg (string pkg)))
    (if-let (fctn (find-symbol name pkg))
        (apply fctn args)
        (warn "Function: ~A::~A not found." pkg name))))


(defcommand "Insert -" (p)
     ""
     ""
  (declare (ignore p))
  (insert-string (current-point) "-"))


(editor:bind-key "Insert -" "Meta-Space" :global :emacs)


(defcommand "Insert \"\"" (p)
     ""
     ""
  (declare (ignore p))
  (insert-string (current-point) "\"\"")
  (backward-character-command 1))


(editor:bind-key "Insert \"\"" "Meta-\"" :global :emacs)


(defcommand "Insert **" (p)
     ""
     ""
  (declare (ignore p))
  (insert-string (current-point) "**")
  (backward-character-command 1))


(defcommand "Go Output" (p)
     ""
     ""
  (declare (ignore p))
  (editor::with-random-typeout-to-window  
      ((let ((window (car (buffer-windows (current-buffer)))))
         (and window (window-text-pane window))))
    nil))


(editor:bind-key "Go Output" #("Meta-g" #\Space) :global :emacs)


(defcommand "Raise Listener" (p) 
     "Raise Listener pane"
     "Raise Listener pane"
  (declare (ignore p))
  (capi:raise-interface
   (find-if (lambda (x)
              (search "Listener" (capi:interface-title x)))
            (capi:collect-interfaces 'lispworks-tools:listener))))


(editor:bind-key "Raise Listener" #("Meta-g" #\r) :global :emacs)


(defcommand "Raise Editor" (p) 
     "Raise Editor pane"
     "Raise Ediror pane"
  (declare (ignore p))
  (capi:raise-interface
   (find-if (lambda (x)
              (search "Editor" (capi:interface-title x)))
            (capi:collect-interfaces 'lispworks-tools:editor))))


(editor:bind-key "Raise Editor" #("Meta-g" #\e) :global :emacs)


(defun read-to-string (&optional (stream *standard-input*)
                                 (eof-error-p T)
                                 (eof-value stream)
                                 recursivep
                                 (junk-allowed T))
  (with-output-to-string (outstring)
    (let* ((stream (make-echo-stream stream outstring))
           (*read-suppress* junk-allowed))
      (when (read stream eof-error-p eof-value recursivep)
        (return-from read-to-string eof-value)))))


(defun split-forms-evenly (path)
  (let* ((file path)
         (forms (with-open-stream (in (open file))
                  (loop :for xpr := (read-to-string in nil in)
                        :until (eq in xpr)
                        :collect xpr))))
    (with-open-stream (out (open file 
                                 :direction :output
                                 :if-exists :supersede
                                 :if-does-not-exist :create))
      (dolist (f forms (format out ";;; *EOF*~%"))
        (let ((op (ignore-errors (car (read-from-string f))))
              (xp (string-trim #(#\Space #\Newline #\Tab) f)))
          (format out
                  "~&~A~A~3%" 
                  xp
                  (case op
                    (eval-when "")
                    (otherwise ""))))))))


(defcommand "Lfmt" (p)
     ""
     ""
  (let ((path (buffer-pathname (current-buffer))))
    (split-forms-evenly path)
    (revert-buffer-command p)))


(defcommand "Just One Space *" (p)
     ""
     ""
  (declare (ignore p))
  (let ((cp (current-point)))
    (editor::delete-characters cp
                               (count-white-spaces-to-the-next-sxp))
    (insert-string cp " ")))


(editor:bind-key "Just One Space *" #("Control-[" #\Space) :global :emacs)


(defcommand "Evaluate Defun *" (p)
     ""
     ""
  (editor:evaluate-defun-command p)
  (when p (go-output-command p)))


(editor:bind-key "Evaluate Defun *" "Control-E" :global :emacs)


(editor:defcommand "Sort Lines" (reversep)
     ""
     ""
  (let ((buf (editor:current-buffer)))
    (editor::with-buffer-point-and-mark (buf)
      (editor:with-point ((start editor::%point% :before-insert)
                          (end   editor::%mark%  :after-insert))
        (let ((orig  (editor:points-to-string start end))
              (modifiedp (editor:buffer-modified buf)))
          (unwind-protect 
              (progn
                (editor:delete-between-points editor::%point% editor::%mark%)
                (editor:insert-string editor::%point%
                                      (format nil
                                              "~{~A~%~}"
                                              (sort (ppcre:split "\\n" orig)
                                                    (if reversep #'string> #'string<)))))
            (editor::record-replace-region start end orig modifiedp)))))))


(editor:bind-key "Insert **" "Meta-*" :global :emacs)


(editor:bind-key "undo" "Control-U" :global :emacs)


(editor:bind-key "redo" "control-R" :global :emacs)


(defun count-white-spaces-to-the-next-sxp ()
  (let ((cnt 0))
    (block nil
      (map nil
           (lambda (c)
             (if (find c #(#\space #\newline #\return #\tab))
                 (incf cnt)
                 (return)))
           (editor:points-to-string (editor:current-point)
                                    (editor::point-next (editor:current-point)))))
    cnt))


(defun listener-save-history ()
  (let ((hist (slot-value (find 'lispworks-tools:listener (capi:screen-interfaces (car (capi:screens)))
                                :key #'type-of)
                          'capi-toolkit::history)))
    (with-open-stream (out (open (merge-pathnames ".lispworks_listener_history" (user-homedir-pathname))
                                 :direction :output
                                 :if-exists :supersede
                                 :if-does-not-exist :create))
      (with-standard-io-syntax 
        (print hist out)))))


(defun listener-load-history ()
  (let ((hist (find 'lispworks-tools:listener (capi:screen-interfaces (car (capi:screens)))
                    :key #'type-of)))
    (with-open-stream (in (open (merge-pathnames ".lispworks_listener_history" (user-homedir-pathname))))
      (with-standard-io-syntax 
        (let ((ohist (read in)))
          (when ohist
            (setf (slot-value hist 'capi-toolkit::history)
                  (append (slot-value hist 'capi-toolkit::history)
                          ohist))
            (let ((histlen (length (slot-value hist 'capi-toolkit::history))))
              (if (> (length (slot-value hist 'capi-toolkit::history))
                     (slot-value hist 'capi-toolkit::history-limit))
                  (setf (slot-value hist 'capi-toolkit::history-limit)
                        (* 2 histlen))))))))))


(editor:bind-key "insert ()" "meta-l" :global :emacs)


(editor:bind-key "move over )" "meta-:" :global :emacs)


(defcommand "Clear Output Immediately" (p)
     "clear the output"
     "clear the output"
  (declare (ignore p))
  (let ((buf (current-buffer)))
    (when (eq (buffer-major-mode buf)
              (getstring "Output" *mode-names*))
      (clear-buffer buf))))


(editor:bind-key "clear output immediately" #("Control-c" "Meta-o")
                 :global :emacs)


(editor:bind-key "activate interface" "control-;"
                 :global :emacs)


(defcommand "close current interface" (p)
     "close current window"
     "close current window"
  (declare (ignore p))
  (let ((prevwin (previous-window (current-window))))
    (call-with-a-text-pane #'invoke-menu-item
                           '("works" "exit" "window"))
    (goto-to-window-and-buffer prevwin)))


(bind-key "close current interface" #("control-x" "control-c"))


(progn
  ;; echo area
  (bind-key "complete field" #\space :mode "echo area")
  (bind-key "illegal" "control-M" :mode "echo area")
  (bind-key "illegal" "control-J" :mode "echo area")
  (bind-key "illegal" "control-N" :mode "echo area")
  (bind-key "illegal" "control-P" :mode "echo area")
  (bind-key "complete input" "control-i" :mode "echo area"))


(defcommand "insert hh:mm" (p)
     ""
     ""
  (declare (ignore p))
  (insert-string (current-point)
                 (apply #'format
                        nil 
                        "~2,'0D:~2,'0D "
                        (reverse
                         (subseq 
                          (multiple-value-list (get-decoded-time))
                          1 3)))))


(editor:bind-key "delete previous character" "control-h" :global :emacs)


(editor:bind-key "undo" "control-z" :global :emacs)


(defcommand "show background output window" (p)
     "show background output window"
     "show background output window"
  (declare (ignore p))
  (make-window (buffer-point 
                (find "background output"
                      editor:*buffer-list*
                      :key #'buffer-name 
                      :test #'string=))))


(bind-key "show background output window" #("control-c" #\o))


(defcommand "delete other editor interfaces" (p)
     "delete other editor interfaces"
     "delete other editor interfaces"
  (declare (ignore p))
  (dolist (i (cdr (capi:collect-interfaces 'lw-tools:editor
                                           :sort-by :visible)))
    (capi:destroy i))
  (message "...destroyed."))


(bind-key "delete other editor interfaces" #("control-c" #\d))


(defcommand "one window per buffer" (p)
     "one window per buffer"
     "one window per buffer"
  (declare (ignore p))
  (let ((bufs (remove-if-not #'file-buffer-p
                             (remove "*messages buffer*"
                                     *buffer-list*
                                     :key #'buffer-name
                                     :test #'string=))))
    (dolist (b bufs)
      (unless (buffer-windows b)
        (make-window (buffer-point b))))))


(bind-key "one window per buffer" #("control-c" #\x))


(bind-key "just one space" #("control-c" #\space))


(bind-key "new window" "control-meta-I")


(bind-key "delete window" "control-meta-!")


(defcommand "Browse Url" (arg)
     "wip"
     "wip"
  (declare (ignore arg))
  (let ((curline (line-string (current-point)))
        (url-re (ppcre:create-scanner
                 "(?x:
                    (.*)
                    (http(s)*://[a-z\\$-_\\.\\+!\\*'\\(\\),]+)
                    (.*))")))
    (multiple-value-bind (url win)
                         (ppcre:regex-replace url-re curline "\\2")
      (hqn-web:browse 
       (if win
           (string-trim #(#\( #\)) url)
           (editor:prompt-for-string 
            :default-string "http://g000001.cddddr.org"))))))


;; --:=&?$+@-z_[:alpha:]~#,%;*()!'


(bind-key "browse url"
          #("control-c" "."))


(bind-key "evaluate last form in listener"
          #("control-c" "control-e"))


(bind-key "disassemble definition" #("control-c" "meta-d"))


(editor:bind-key "insert space and show arglist" #\space :global :emacs)


(editor:bind-key "walk form" "control-meta-m" :global :emacs)


(defun toggle-interface-toolbar ()
  (dolist (i (capi:collect-interfaces 'capi:interface))
    (ignore-errors
      (setf (lispworks-tools::lispworks-interface-toolbar-visible-p i)
            (not (lispworks-tools::lispworks-interface-toolbar-visible-p i))))))


(defcommand "Toggle Toolbar" (p)
     ""
     ""
  (declare (ignore p))
  (toggle-interface-toolbar))


(defcommand "region to string list" (more)
     "region to string list"
     "region to string list"
  (let* ((s (buffer-region-as-string (current-buffer)))
         (ss (split-sequence #(#\newline #\linefeed) s ))
         (ss (if more 
                 (mapcar (lambda (s)
                           (split-sequence #(#\space #\tab) s
                                           :coalesce-separators t)) 
                         ss)
                 ss)))
    (insert-string (current-point) 
                   (string-append (string #\newline)
                                  "'"
                                  (prin1-to-string ss)))))


(when-let (sym (find-symbol "*describe-attribute-formatter*" 
                            :sys))
  (defun cl-user::slot-printer (stream arg colon at)
    (declare (ignore colon at))
    (format stream "~a (~(~a~))" arg (package-name (symbol-package arg))))
  (set sym "~s"))


(defun indent-n (n str)
  (with-output-to-string (out)
    (dolist (line (ppcre:split "\\n" str))
      (format out "~VT~A~%" n line))))


(defcommand "Evaluate Last Form*" (p &optional (point (current-point)))
     "evaluates lisp forms before point."
     "evaluates lisp forms before point."
  (declare (ignore p))
  (with-point ((start point)
               (end point))
    (unless (form-offset start -1 t 0)
      (editor-error "cannot find start of the form to evaluate"))
    (let ((*package* (or (editor::get-buffer-current-package (point-buffer point))
                         (find-package 'cl-user)))
          (*standard-output* (make-string-output-stream))
          (*error-output* (make-string-output-stream))
          (result (list)))
      (setq result 
            (multiple-value-list 
             (ignore-errors
               (eval
                (read-from-string 
                 (points-to-string start end))))))
      (flet ((insert-result ()
               (insert-string (current-point)
                              (if result
                                  (format nil "~%→ ~S" (car result))
                                  (format nil "~%→ <no values>" (car result))))
               (dolist (r (cdr result))
                 (when (typep r 'condition)
                   (apply #'format *error-output* 
                          (simple-condition-format-control r)
                          (simple-condition-format-arguments r)))
                 (insert-string (current-point)
                                (format nil "~%  ~S" r)))
               (insert-string (current-point)
                              (format nil "~%")))
             (insert-output ()
               (let ((lines (ppcre:split "\\n" (get-output-stream-string *standard-output*))))
                 (dolist (line lines)
                   (insert-string (current-point)
                                  (format nil "~%▻ ~A" line)))))
             (insert-error ()
               (let ((lines (ppcre:split "\\n" (get-output-stream-string *error-output*))))
                 (dolist (line lines)
                   (insert-string (current-point)
                                  (format nil "~%⏏ ~A" line))))))
        (insert-output)
        (insert-error)
        (insert-result)))))


(bind-key "evaluate last form*" "control-J" :global :emacs)


(defcommand "Browse Class" (p)
     "browse class"
     "browse class"
  (let ((name (prompt-for-symbol p 
                                 :prompt "Symbol: "
                                 :tag 'lw-tools:class-browser)))
    (capi:display (make-instance 'lw-tools:class-browser :class name))))


(defun |Mon d, yyyy | ()
  (multiple-value-bind (.s .m .h d m y)
                       (get-decoded-time)
    (declare (ignore .s .m .h))
    (format nil 
            "~[~;Jan~;Feb~;Mar~;Apr~;May~;Jun~;~
                Jul~;Aug~;Sep~;Oct~;Nov~;Dec~] ~
                ~D, ~D "
            m
            d
            y)))


(defcommand "insert Mon d, yyyy" (p)
     "insert Mon d, yyyy"
     "insert Mon d, yyyy"
  (declare (ignore p))
  (insert-string (current-point)
                 (|Mon d, yyyy |)))


(defun in-string-p (pt)
  (let ((face (getf (text-properties-at pt)
                    'editor:face)))
    (and face
         (typecase face
           (face T)
           (T nil)))))


(defun get-out-in-string ()
  (loop
   (let ((pt (current-point)))
     (if (in-string-p pt)
         (character-offset pt -1)
         (return)))))


(compiler-let ((*packages-for-warn-on-redefinition* nil))
  (defcommand "Backward Up List" (p)
       "Move backward past one containing (."
       "Move backward past one containing (."
    (let ((point (current-point))
          (count (or p 1)))
      (when (in-string-p point)
        (get-out-in-string)
        (decf count))
      (if (minusp count)
          (forward-up-list-command (- count))
          (with-point ((m point))
            (dotimes (i count (move-point point m))
              (unless (backward-up-list m) (editor-error))))))))


(progn
  (defcommand "Paredit Forward Slurp Sexp" (p)
       ""
       ""
    (declare (ignore p))
    (forward-up-list (current-point))
    (let ((close (character-at (current-point) -1)))
      (delete-characters (current-point) -1)
      (loop
       (handler-case 
           (progn
             (form-offset (current-point) 1 T 0)
             (indent-command 1)
             (return nil))))
      (insert-character (current-point) close)))
  
  (bind-key "Paredit Forward Slurp Sexp" #("Control-c" "<") :global :emacs)
  (bind-key "Paredit Forward Slurp Sexp" "Control-<" :global :emacs))


(defcommand "Insert UNIVERSAL-TIME" (p)
     ""
     ""
  (declare (ignore p))
  (let ((ut (get-universal-time)))
    (multiple-value-bind (s m h d mo y)
                         (decode-universal-time ut)
      (declare (ignore s))
      (editor:insert-string (editor:current-point)
                            (format nil
                                    "~D ;~D-~2,'0D-~2,'0DT~2,'0D~2,'0D"
                                    ut y mo d h m)))))


(mapc #'eval *bind-key-forms*)


;;; *EOF*
