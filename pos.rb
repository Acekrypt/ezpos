#!/usr/bin/ruby -I/usr/local/lib/rubylib

require 'pos_settings'
require 'libglade2'
require 'local_config'
require 'db'
require 'items_grid'
require 'find_items_ctrl'
require 'pos_sale'
require 'payment_ctrl'
require 'totals_display'
require 'drawer_ctrl'

POSSetting.init

class PointOfSale
  TITLE = "Simple Text Editor"
  NAME = "SimpleTextEditor"
  VERSION = "1.0"

  def initialize(path)
      @glade = GladeXML.new(path) do | handler |
	  case handler
	  when 'on_find_sku_entry_box_key_press_event'
	      FindItemsCtrl.instance.method(:update)
	  when 'on_found_skus_results_grid_row_activated'
	      FindItemsCtrl.instance.method(:select)
	  when 'on_find_sku_entry_done'
	      FindItemsCtrl.instance.method(:entry_complete )
	  when 'on_find_grid_focus'
	      FindItemsCtrl.instance.method(:grid_got_focus)
	  when 'on_found_skus_results_grid_cursor_changed'
	      FindItemsCtrl.instance.method(:grid_cursor )
	  when 'on_items_grid_key_press_event'
	      ItemsGrid.instance.method(:on_key_press_event)
	  when 'on_items_grid_focus'
	      ItemsGrid.instance.method(:grid_got_focus)
	  else
	      self.method( handler )
	  end
      end

      window = @glade.get_widget("ezpos_window")
      window.fullscreen
      window.set_has_frame( false )
      window.show

      FindItemsCtrl.instance.glade = @glade
      TotalsDisplay.instance.glade = @glade
      PaymentCtrl.instance.glade   = @glade 
      ItemsGrid.instance.glade     = @glade

      @sale = PosSale.new

  end


  def on_drawer_button_clicked( widget )
      Drawer.instance.open
  end


  def on_key_press_event( widget,k )
      key = k.keyval
      if 113 == key
	  Gtk.main_quit
      end
  end

  def on_discount_spin_ctrl_changed( widget )
      @sale.discount=widget.value.to_i
  end

  def on_set_receipt_header_set( widget )
      dialog =  @glade.get_widget("set_print_header_dialog")
      buffer = @glade.get_widget("print_header_text_ctrl").buffer
      buffer.delete( buffer.start_iter, buffer.end_iter )
      buffer.insert( buffer.start_iter, POSSetting.printHeader )
      dialog.run
  end

  def on_set_receipt_header_ok( widget )
      dialog =  @glade.get_widget("set_print_header_dialog")
      dialog.hide
      buffer = @glade.get_widget("print_header_text_ctrl").buffer
      POSSetting.printHeader = buffer.get_text
  end


  def on_set_receipt_header_cancel( widget )
      dialog =  @glade.get_widget("set_print_header_dialog")
      dialog.hide
  end


  def on_tax_exempt_toggle
      POSSetting.toggle_tax_exempt
      TotalsDisplay.instance.tax_exempt = $taxExempt
  end

  def on_set_tax_rate(*widget)
      dialog =  @glade.get_widget("tax_rate_dialog")
      dialog.show
      txt_entry = @glade.get_widget("tax_rate_text_entry_ctrl");
      txt_entry.text =  sprintf( "%0.2f",POSSetting.tax_rate * 100 )
  end

  def on_tax_rate_dialog_ok( widget )
      txt_entry = @glade.get_widget("tax_rate_text_entry_ctrl");
      POSSetting.tax_rate = ( txt_entry.text.to_f / 100 )
      dialog =  @glade.get_widget("tax_rate_dialog")
      dialog.hide
  end

  def on_tax_rate_dialog_quit( widget )
      dialog =  @glade.get_widget("tax_rate_dialog")
      dialog.hide
  end

  def on_quit_activate(*widget)
    Gtk.main_quit
  end

  def on_sale_finalize( widget )
      @sale = @sale.finalize( @glade )
  end

  def on_receive_payment_type( widget )
      
  end

  def on_about_activate( *widget )
      dialog = Gtk::MessageDialog.new( nil,Gtk::Dialog::MODAL,Gtk::MessageDialog::INFO,Gtk::MessageDialog::BUTTONS_OK,"EZPOS\nCreated by Nathan Stitt\nCopyright 2004, Alliance Medical Inc." )
      dialog.run
      dialog.destroy
  end

  def on_new_sale_activate( *widget )
      if ! @sale.empty?
	  dialog = Gtk::MessageDialog.new( nil,Gtk::Dialog::MODAL,Gtk::MessageDialog::WARNING,Gtk::MessageDialog::BUTTONS_YES_NO,'Do you want to abandon the current sale?' )
	  if  dialog.run == Gtk::Dialog::RESPONSE_YES
	      @sale = PosSale.new
	  end
	  dialog.destroy
      end
  end

end


begin
    Gnome::Program.new(PointOfSale::NAME, PointOfSale::VERSION)
    PointOfSale.new( File.dirname($0) + "/pos.glade")
    Gtk.main

rescue Exception
    msg = $!.to_s
    msg += "\n"
    for level in $!.backtrace
	msg += level + "\n"
    end

    fork do
	pig = IO.popen("mail -s 'POS ERROR' sysadmin@allmed.net", "w+")
	pig.puts msg
	pig.close_write
    end

    dialog = Gtk::MessageDialog.new( nil,Gtk::Dialog::MODAL,Gtk::MessageDialog::ERROR,Gtk::MessageDialog::BUTTONS_CLOSE, msg  )
    if  dialog.run == Gtk::Dialog::RESPONSE_YES
	@sale=Sale.new
    end


end
