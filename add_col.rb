#!/usr/bin/ruby -I/usr/local/lib/rubylib




require 'db'

if ARGV.size < 2
    $stderr.puts 'add_col.rb <table> <column> <type> [default value]'
    exit
end

sql =  'ALTER TABLE ' + ARGV[0] + ' add column ' + ARGV[1] + ' ' + ARGV[2]

DB.instance.exec( sql )

if ARGV.size == 4
    sql =  'update ' + ARGV[0] + ' set ' + ARGV[1] + ' =  ' + DB.quote( ARGV[3] )
    DB.instance.exec( sql )
    sql = 'ALTER TABLE ' + ARGV[0] + ' alter column ' + ARGV[1] + ' set not null'
    DB.instance.exec( sql )
    sql = 'ALTER TABLE ' + ARGV[0] + ' alter column ' + ARGV[1] + ' set default ' + DB.quote( ARGV[3] )
    DB.instance.exec( sql )

end

