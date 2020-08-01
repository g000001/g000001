;; metasyntactic variable
;; http://catb.org/jargon/html/M/metasyntactic-variable.html

(defpackage :metasyntactic-variables
  (:use :cl :editor))

(in-package :metasyntactic-variables)

(defvar *metasyntactic-variables*)
(setq *metasyntactic-variables*
      '(foo
        bar
        baz
        qux
        quux
        bazola
        ztesch
        thud
        grunt
        gorp
        bletch
        fum
        fred
        jim
        sheila
        barney
        flarp
        zxc
        spqr
        wombat
        shme
        bongo
        spam
        eggs
        snork
        zot
        blarg
        wibble
        toto
        titi
        tata
        tutu
        pippo
        pluto
        paperino
        aap
        noot
        mies
        oogle
        foogle
        boogle
        zork
        gork
        bork
        hoge
        fuga
        piyo
        frob
        frobozz
        frobnitz
        gazonk
        ))

#+lw-editor
(defcommand "Insert Random Spell" (arg)
     "Insert Random Spell"
     "Insert Random Spell"
  (declare (ignore arg))
  (let ((len (length *metasyntactic-variables*)))
    (insert-string (current-point)
                   (string-downcase
                    (symbol-name 
                     (nth (random len) 
                          *metasyntactic-variables*)))) ))

#+lw-editor
(bind-key "Insert Random Spell" #("C-c" "r" "s"))

(defvar *wizardry-spells*
  '("halito" "mogref" "katino" "dumapic" "dilto" "sopic" "mahalito" "molito"
    "morlis" "dalto" "lahalito" "mamorlis" "makanito" "madalto" "lakanito"
    "masopic" "haman" "zilwan" "malor" "mahaman" "tiltowaito" "kalki" "dios"
    "badios" "milwa" "porfic" "matu" "calfo" "manifo" "montino" "lomilwa" "dialko"
    "latumapic" "bamatu" "dial" "badial" "latumofis" "maporfic" "dialma"
    "badialma" "litokan" "kandi" "di" "badi" "lorto" "madi" "mabadi" "loktofeito"
    "maliikto" "kadorto"))

(defvar *wizardry-spell-it*)

#+lw-editor
(defcommand "Insert Random Wizardry Spell" (arg)
     "Insert Random Wizardry Spell"
     "Insert Random Wizardry Spell"
  (let ((item (nth (random (length *wizardry-spells*))
                   *wizardry-spells*)))
    (cond (arg (insert-string (current-point)
                              *wizardry-spell-it*))
          (T (setq *wizardry-spell-it* item)
             (insert-string (current-point)
                            *wizardry-spell-it*)))))

#+lw-editor
(bind-key "Insert Random Wizardry Spell" #("C-c" "r" "w"))

;; ================================================================

#||
(defvar sorcery-spells
  '("zap" "hot" "fof" "wal" "law" "dum" "big" "wok" "dop" "raz" "sus" "six"
    "jig" "gob" "yob" "gum" "how" "doc" "doz" "dud" "mag" "pop" "fal" "dim"
    "fog" "mud" "nif" "tel" "gak" "sap" "god" "kin" "pep" "rok" "nip" "huf"
    "fix" "nap" "zen" "yaz" "sun" "kid" "rap" "yap" "zip" "far" "res" "zed"))


(defvar sorcery-spell-it)


(define-key global-map [(super meta ?I)]
  (defun random-sorcery-spell-insert (arg)
    (interactive "P")
    (let ((item (nth (random (length sorcery-spells))
                     sorcery-spells)))
      (cond (arg (insert sorcery-spell-it))
            (t (setq sorcery-spell-it item)
               (insert sorcery-spell-it))))))


||#

;; eof
