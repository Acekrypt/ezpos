require 'nas/widgets/get_number'
require 'nas/widgets/get_string'
require 'nas/widgets/get_text'
require 'nas/ezpos/about_dialog'
require 'nas/ezpos/set_display_pole'

module NAS

module EZPOS

class MainMenu < Gtk::MenuBar


    def initialize( app )
        super()
        @app=app

        # SALE
        sale_menu = Gtk::Menu.new

        dep = Gtk::MenuItem.new("_Enter Days Recpts")
        dep.signal_connect( 'activate' ){ | wid | @app.enter_deposits }
        sale_menu.append( dep )

        report = Gtk::MenuItem.new("_Sales Report")
        report.signal_connect( 'activate' ) do | wid |
            sr=NAS::EZPOS::SalesReport.new( Time.now-604800,Time.now )
            file="/tmp/pos-report-#{Process.pid}.pdf"
            sr.pdf( file )
            `xpdf #{file} &`
            File.unlink( file )
        end
        sale_menu.append( report )

        quit = Gtk::MenuItem.new("_Quit")
        quit.signal_connect( 'activate' ){ | wid | @app.shutdown }
        sale_menu.append( quit )

        menu = Gtk::MenuItem.new('_POS')
        menu.set_submenu( sale_menu )
        self.append( menu )

        # SETTINGS

        settings_menu = Gtk::Menu.new

        tax_rate = Gtk::MenuItem.new("_Tax Rate")
        tax_rate.signal_connect( 'activate' ) do | wid |
            gn=NAS::Widgets::GetNumber.new('Tax Rate:','Enter Tax Rate', Settings['tax_rate'] )
            if gn.ok?
                Settings['tax_rate']=gn.to_s
                @app.update
            end
        end
        settings_menu.append( tax_rate )


        receipt = Gtk::MenuItem.new("_Receipt Header")
        receipt.signal_connect('activate') do | wid |
            gs=NAS::Widgets::GetText.new('Receipt Header:','Enter Receipt Header', Settings['receipt_header'], Gtk::JUSTIFY_CENTER )
            gs.run
            if gs.ok?
                Settings['receipt_header']=gs.to_s
            end
            gs.destroy
        end
        settings_menu.append( receipt )

        receipt = Gtk::MenuItem.new("_Receipt Footer")
        receipt.signal_connect('activate') do | wid |
            gs=NAS::Widgets::GetText.new('Receipt Footer:','Enter Receipt Footer', Settings['receipt_footer'], Gtk::JUSTIFY_CENTER )
            gs.run
            if gs.ok?
                Settings['receipt_footer']=gs.to_s
            end
            gs.destroy
        end
        settings_menu.append( receipt )


        display_pole = Gtk::MenuItem.new("_Display Pole Messages")
        display_pole.signal_connect('activate') do | widget |
            dp=SetDisplayPole.new( self )
        end

    #    Gtk.main_quit

        settings_menu.append( display_pole )

        menu = Gtk::MenuItem.new('_Settings')
        menu.set_submenu( settings_menu )

        self.append(menu)

        # HELP

        help_menu = Gtk::Menu.new

        shortcuts = Gtk::MenuItem.new("_Keyboard Shortcuts")
        shortcuts.signal_connect( 'activate' ){ | wid |
            dialog=Gtk::MessageDialog.new( nil,
                                      Gtk::Dialog::MODAL,
                                      Gtk::MessageDialog::INFO,
                                      Gtk::MessageDialog::BUTTONS_CLOSE,
                                      "F12 - Finalize Sale\n  / - Edit Description on selected item\n  * - Edit Price on selected item\n  + - Increase Qty of selected item\n   - - Descrease Qty of selected item" )
            dialog.window_position=Gtk::Window::POS_CENTER_ALWAYS
            dialog.run
            dialog.destroy
        }
        help_menu.append( shortcuts )


        about = Gtk::MenuItem.new("_About")
        about.signal_connect( 'activate' ){ | wid |
            a=AboutDialog.new
            a.run
            a.destroy
        }
        help_menu.append( about )


        menu = Gtk::MenuItem.new('_Help')
        menu.set_submenu( help_menu )


        self.append(menu)

    end

end # MainMenu

end # EZPOS

end # NAS
