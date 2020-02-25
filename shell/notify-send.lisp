(defun notify-send (title mesg &key (timeout 10)
                                 (icon "~/lisp/lisplogo_alien_256.png")
                                 (urgency :normal))
  #|(sb-ext:run-program "/usr/bin/X11/notify-send"
  (list "-u" (string-downcase urgency)
  "-t" (princ-to-string timeout)
  "-i" icon
  "--"
  title
  mesg))|#
  (kl:run-shell-command
   (format nil
           "/usr/bin/X11/notify-send -u ~A -t ~A -i ~A -- \"~A\" \"~A\""
           (string-downcase urgency)
           (princ-to-string timeout)
           icon
           ;; --
           title
           mesg)))
