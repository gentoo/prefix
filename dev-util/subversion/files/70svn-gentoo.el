;;; svn site-lisp configuration

(setq load-path (cons "@SITELISP@" load-path))
(add-to-list 'vc-handled-backends 'SVN)
(require 'psvn)
