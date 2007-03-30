;; compile mime-ui-en.texi and mime-ui-ja.texi

(find-file "mime-ui-en.texi")
(texi2info)
(set-default-coding-systems 'iso-2022-jp)
(find-file "mime-ui-ja.texi")
(texi2info)
