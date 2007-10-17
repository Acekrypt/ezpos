
module NAS

module EZPOS

class CashDrawer

        def self.open
            IO.popen("lp -s -d #{DEF::CASH_DRAWER_PRINTER}","w") do | recpt |
        recpt.putc 0x1B
        recpt.putc 'p'
        recpt.putc 0
        recpt.putc 25
        recpt.putc 250
                       recpt.putc 7
                end
        end

end # CashDrawer

end # EZPOS

end # NAS

