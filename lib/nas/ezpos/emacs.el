

(defun my-save-and-compile ()
  (interactive "")
  (save-buffer 0)
  (compile "~/code/allmed/script/ezpos -e development"))
