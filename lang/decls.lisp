(in-package :g1)

;; (make-decl-form :g1)
(progn
 (declaim-ftype japanese-tenji-to-hiragana (t) (values t &optional))
 (declaim-ftype package-exports (t) (values list &optional))
 (declaim-ftype mexp-string (t) *)
 (declaim-ftype gensym-symbol-name (t) *)
 (declaim-ftype make-decl-form (t) *)
 (declaim-ftype extract-function-decls (t) (values list &optional))
 (declaim-ftype qq-expand-list (t t) (values list &optional))
 (declaim-ftype strans (t) *)
 (declaim-ftype kasanejize (t) *)
 (declaim-ftype source-transform (t &optional t)
                (values t &optional (member t)))
 (declaim-ftype sed (t t t &key (:in t) (:out t)) (values null &optional))
 (declaim-ftype pkg-functions (t) (values list &optional))
 (declaim-ftype replace-youon-all (t) *)
 "tws"
 (declaim-ftype japanese-tenji-string (t) (values t &optional))
 (declaim-ftype uninterned-symbols (t) (values t &optional))
 (declaim-ftype find-youon-tenji (t) (values t &optional))
 (declaim-ftype kebunridge-word (t) (values t &optional))
 (declaim-ftype japanese-hankaku-string (t) (values t &optional))
 (declaim-ftype decode-tenji-youon (t) *)
 (declaim-ftype auto-import (t) (values list &optional))
 (declaim-ftype japanese-hankaku-char (t) (values t &optional))
 (declaim-ftype up-symbol (t t) *)
 (declaim-ftype decode-tenji-dakuon (t) *)
 (declaim-ftype symbol-to-intern-form (t t) (values list &optional))
 (declaim-ftype read-tolerant * (values t (mod 4611686018427387901) &optional))
 (declaim-ftype fold-tree-right (t t t) *)
 (declaim-ftype gauche-xref->exports (t) (values list &optional))
 (declaim-ftype find-dakuon (t)
                (values (or null (vector character) (vector nil) base-string)
                        &optional))
 (declaim-ftype japanese-tenji-char (t) (values t &optional))
 (declaim-ftype cr (t) (values t &optional))
 (declaim-ftype decode-tenji (t) (values t &optional))
 (declaim-ftype qq-expand (t t) (values t &optional))
 (declaim-ftype count-symbol-names (t) (values hash-table &optional))
 (declaim-ftype |#/-reader| (t t t) *)
 (declaim-ftype enable-quasiquote nil (values (member t) &optional))
 (declaim-ftype source-transform-string (t) *)
 (declaim-ftype find-youon (t) (values t &optional)))


;; (make-decl-form :g1.tao)
(progn
 (declaim-ftype root.user.g000001.tao::maknum (t)
                (values (unsigned-byte 64) &optional))
 (declaim-ftype root.user.g000001.tao::tform (t)
                (values t (mod 4611686018427387901) &optional))
 (declaim-ftype root.user.g000001.tao::comment-p (stream t)
                (values &optional (member t nil) &rest t))
 (declaim-ftype root.user.g000001.tao::frob-lisp-conditional (t)
                (values t &optional))
 (declaim-ftype root.user.g000001.tao::str *
                (values &optional
                        (or (vector character) (vector nil) base-string null)
                        &rest t))
 (declaim-ftype root.user.g000001.tao::prn * (values null &optional))
 (declaim-ftype root.user.g000001.tao::inst= (t t)
                (values &optional (member t nil) &rest t))
 (declaim-ftype root.user.g000001.tao::type-predicate-p (symbol)
                (values symbol &optional))
 (declaim-ftype root.user.g000001.tao::pkg-difference (t t)
                (values t &optional))
 (declaim-ftype root.user.g000001.tao::uninterned-symbols (t)
                (values t &optional))
 (declaim-ftype root.user.g000001.tao::gauche-xref->exports (t)
                (values list &optional))
 (declaim-ftype root.user.g000001.tao::yonda (t &optional t)
                (values t &optional))
 (declaim-ftype root.user.g000001.tao::cloogle (t) (values null &optional))
 (declaim-ftype root.user.g000001.tao::source-transform (t &optional t)
                (values t &optional (member t)))
 (declaim-ftype root.user.g000001.tao::get-title-simple (t)
                (values t &optional))
 (declaim-ftype root.user.g000001.tao::pp-aa (t) (values t &optional))
 (declaim-ftype root.user.g000001.tao::gensym-symbol-name (t)
                (values t &optional))
 (declaim-ftype root.user.g000001.tao::make-current-attribute-list-string nil
                (values &optional
                        (or (vector character) (vector nil) base-string null)
                        &rest t))
 (declaim-ftype root.user.g000001.tao::mexp-string (t) (values t &optional))
 (declaim-ftype root.user.g000001.tao::fintern (t &rest t)
                (values symbol (member :internal :external :inherited nil)
                        &optional))
 (declaim-ftype root.user.g000001.tao::munkam (t) (values t &optional))
 (declaim-ftype root.user.g000001.tao::compute-cursor-position (t t)
                (values number &optional))
 (declaim-ftype root.user.g000001.tao::sed (t t t &key (:in t) (:out t))
                (values null &optional))
 (declaim-ftype root.user.g000001.tao::qq-expand-list (t t)
                (values list &optional))
 (declaim-ftype root.user.g000001.tao::count-symbol-names (t)
                (values hash-table &optional))
 (declaim-ftype root.user.g000001.tao::cr (t) (values t &optional))
 (declaim-ftype root.user.g000001.tao::function-type (t) (values t &optional))
 (declaim-ftype root.user.g000001.tao::result-type (t) (values t &optional))
 (declaim-ftype root.user.g000001.tao::fun-segment-to-string (t)
                (values simple-string &optional))
 (declaim-ftype root.user.g000001.tao::coding-system-to-external-format
                (&optional t) (values t &optional))
 (declaim-ftype root.user.g000001.tao::pr * (values simple-string &optional))
 (declaim-ftype root.user.g000001.tao::pkg-intersection (t t)
                (values t &optional))
 (declaim-ftype root.user.g000001.tao::random-paren nil (values t &optional))
 (declaim-ftype root.user.g000001.tao::frob-lisp-conditional-string (string)
                (values string &optional))
 (declaim-ftype root.user.g000001.tao::ql
                ((or symbol (vector character) (vector nil) base-string) &rest
                 t)
                (values t &optional))
 (declaim-ftype root.user.g000001.tao::pkg-foo (t t t) (values t &optional))
 (declaim-ftype root.user.g000001.tao::html-to-stp (t) (values t &optional))
 (declaim-ftype root.user.g000001.tao::source-transform-string (t)
                (values t &optional))
 (declaim-ftype root.user.g000001.tao::title+url (t)
                (values &optional
                        (or (vector character) (vector nil) base-string null)
                        &rest t))
 (declaim-ftype root.user.g000001.tao::github-install (t t &optional t)
                (values t &optional))
 (declaim-ftype root.user.g000001.tao::qapropos (t) (values t &optional))
 (declaim-ftype root.user.g000001.tao::choose-elt (t t) (values t &optional))
 (declaim-ftype root.user.g000001.tao::qq-expand (t t) (values t &optional))
 (declaim-ftype root.user.g000001.tao::cond->typecase (cons)
                (values cons &optional))
 (declaim-ftype root.user.g000001.tao::wc (t &key (:external-format t))
                (values (mod 4611686018427387901)
                        (integer 1 4611686018427387901)
                        (mod 4611686018427387901) &optional))
 "yonderu-tw"
 (declaim-ftype root.user.g000001.tao::open-tweet nil (values t &optional))
 (declaim-ftype root.user.g000001.tao::fold-tree-right (t t t)
                (values t &optional))
 (declaim-ftype root.user.g000001.tao::fintern-in-package (t t &rest t)
                (values symbol (member :internal :external :inherited nil)
                        &optional))
 (declaim-ftype root.user.g000001.tao::title-filter (t) (values t &optional))
 (declaim-ftype root.user.g000001.tao::html-page-to-string (t)
                (values t &optional)))


;; (make-decl-form :g1.arc)
(progn
 (declaim-ftype root.user.g000001.arc::jazzset-mp3-url (t) *)
 (declaim-ftype root.user.g000001.arc::npr-media-url (t) *)
 (declaim-ftype root.user.g000001.arc::paramslen (t) *)
 (declaim-ftype root.user.g000001.arc::xml->stp (t) *)
 (declaim-ftype root.user.g000001.arc::succ (t) *)
 (declaim-ftype root.user.g000001.arc::reddit-session-cookie (t) *)
 (declaim-ftype root.user.g000001.arc::npr-media-query (t) *)
 (declaim-ftype root.user.g000001.arc::creddit-submit (t t t &optional t t)
                (values t &optional))
 (declaim-ftype root.user.g000001.arc::params-str (t) *)
 (declaim-ftype root.user.g000001.arc::code (t) (values t &optional))
 (declaim-ftype root.user.g000001.arc::reddit-session-user-hash (t) *)
 (declaim-ftype root.user.g000001.arc::redtw (t) *)
 (declaim-ftype root.user.g000001.arc::npr-check-query (t)
                (values t &optional))
 (declaim-ftype root.user.g000001.arc::dreddit-login (t) *)
 (declaim-ftype root.user.g000001.arc::htmlout-entry (t) *)
 (declaim-ftype root.user.g000001.arc::reddit-login (t) *)
 (declaim-ftype root.user.g000001.arc::reddit-post (t t) *)
 (declaim-ftype root.user.g000001.arc::dreddit-submit (t t t &optional t t) *)
 (declaim-ftype root.user.g000001.arc::apropos-char-name (t)
                (values sequence &optional))
 (declaim-ftype root.user.g000001.arc::http-case (t) (values t &optional))
 (declaim-ftype root.user.g000001.arc::red (t) *)
 (declaim-ftype root.user.g000001.arc::npr-media-download-url (t)
                (values (simple-array character (*)) &optional))
 (declaim-ftype root.user.g000001.arc::creddit-login (t) *)
 (declaim-ftype root.user.g000001.arc::curl (t t) *)
 (declaim-ftype root.user.g000001.arc::pub-entry (t) *)
 (declaim-ftype root.user.g000001.arc::set-modhash (t) *)
 (declaim-ftype root.user.g000001.arc::gmemo (t) *)
 (declaim-ftype root.user.g000001.arc::reddit-submit (t t t &optional t t)
                (values t &optional))
 (declaim-ftype root.user.g000001.arc::name (t) (values t &optional)))

;;; eof

