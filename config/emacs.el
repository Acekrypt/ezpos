;;; $Id: emacs.el 1355 2005-11-22 15:34:52Z nas $

(defun my-save-and-compile ()
  (interactive "")
  (save-buffer 0)
  (compile "cd ~/code/allmed && ruby test/unit/pos_sale_sku_test.rb"))

(defun my-save-and-compile ()
  (interactive "")
  (save-buffer 0)
  (compile "cd ~/code/allmed && ./script/monthly-sales-summary -e development"))

(defun my-save-and-compile ()
  (interactive "")
  (save-buffer 0)
  (compile "cd ~/code/allmed && ruby test/unit/pos_payment_type_test.rb"))

(defun my-save-and-compile ()
  (interactive "")
  (save-buffer 0)
  (compile "cd ~/code/allmed && ./script/sales-report -e development -d 0"))

(defun my-save-and-compile()
  (interactive "")
  (save-buffer 0)
  (compile "cd ~/code/allmed && ./script/update_pos"))

(defun my-save-and-compile ()
  (interactive "")
  (save-buffer 0)
  (compile "cd ~/code/allmed && ./script/ezpos -e development"))

(defun my-save-and-compile ()
  (interactive "")
  (save-buffer 0)
  (compile "cd ~/code/ruby/vte/ext/gtk/vte && make && ruby ../../../test/test_vte.rb"))

;;; end of emacs.el
