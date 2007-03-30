
;;; bbdb site-lisp configuration

(add-to-list 'load-path "@SITELISP@")
(add-to-list 'load-path "@SITELISP@/bits")
(require 'bbdb)
(bbdb-initialize)

