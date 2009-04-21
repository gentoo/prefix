(add-to-list 'load-path "@SITELISP@")

(autoload 'python-mode "python-mode" "Python editing mode." t)
(autoload 'jython-mode "python-mode" "Python editing mode." t)
(autoload 'py-shell "python-mode" "Start an interactive Python interpreter in another window." t)

(add-to-list 'auto-mode-alist '("\\.py$" . python-mode))

(add-to-list 'interpreter-mode-alist '("python" . python-mode))
(add-to-list 'interpreter-mode-alist '("jython" . jython-mode))
