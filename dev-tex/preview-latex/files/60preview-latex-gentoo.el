
;; preview-latex gentoo site configuration

(add-hook 'LaTeX-mode-hook #'LaTeX-preview-setup)
(autoload 'LaTeX-preview-setup "preview")

