#!/usr/bin/ruby

require 'tempfile'
require 'net/ftp'

module NAS

class DBSync

    METHODS = [  :get_files, :insert_files, :table_insert, :table_updates ]

    def initialize( local_location=nil,time=Time.now-1.week )
        @time=time
        @settings = YAML::load( File.open( RAILS_ROOT + '/config/dbsync.yml' ) )
        if local_location
            @local=true
            @settings['dumps-location']=local_location
        else
            @local=false
        end
        @db = YAML::load( File.open( RAILS_ROOT + '/config/database.yml' ) ).fetch( RAILS_ENV )
    end

    def perform( *methods )
        methods=METHODS if methods.empty?
        for meth in methods
            self.method( meth ).call{ | ret | yield ret }
        end
    end

    def ftp_get_file( file )
        success = true
        location="#{@settings['dumps-location']}#{file['filename']}"
        msg = "Downloading: ftp://#{@settings['master-server']}#{location}"
        begin
            ftp = Net::FTP.new( @settings['master-server'] )
            ftp.login( @settings['server-login'], @settings['server-password'],1 )
            ftp.passive=true
            passes=0
            file['location']="/tmp/#{file['dest-table']}-#{rand(1000).to_s}.sql.bz2"
            ftp.getbinaryfile( location, file['location'], 32768 ) do | data |
                passes += 1
                yield [true, ( '|'*passes ) + ' ' + (passes*32768).to_s + ' bytes' ]
            end
            ftp.close
        rescue Exception=>e
            msg += "Failed - " + e.to_s
            success=false
        end
        yield [ success, msg ]
    end

    def get_files
        @settings['files'].each do | file |
            if @local
                location=@settings['dumps-location']+'/'+file['filename']
                file['location']=''

                if File.exists?( location ) && File.mtime( location ) > @time
                    yield [true,"#{location} exists,\n    and #{File.mtime( location )} > #{@time}"]
                    file['location']=location
                elsif File.exists?( location )
                    yield [false,"#{location} exists,\n    but #{File.mtime( location )} < #{@time}"]
                else
                    yield [false,"#{location} does not exist"]
                end

            else
                ftp_get_file( file ){ | tuple | yield tuple }
            end
        end
    end

    def table_updates
        @settings['files'].each do | file |
            msg="Updateing table #{file['dest-table']} - "
            next if file['location'].empty?
            obj=Object.const_get(file['class'])
            success = true
            begin
                obj.connection.execute( file['before_update_sql'] ) if file.has_key?( 'before_update_sql' )
                if file.has_key?( 'update_sql' )
                    sql=file['update_sql']
                else
                    sql="update #{file['dest-table']} set "
                    c=NAS::Util::Comma.new
                    obj.columns.each do | col |
                        src_col=file['map'].fetch( col.name, "#{file['src-table']}.#{col.name}" )
                        sql << "#{c}#{col.name}=#{src_col}" unless col.name == 'id'
                    end
                    sql << " FROM #{file['src-table']} "
                    dest_col=file['map'].fetch( file['key'], file['key'] )
                    sql << " where #{file['dest-table']}.#{dest_col} = #{file['src-table']}.#{file['key']}"
                end
                yield [true,sql]
                obj.connection.execute( sql )
                obj.connection.execute( file['after_update_sql'] ) if file.has_key?( 'after_update_sql' )
                msg << "OK"
            rescue Exception=>e
                msg << "Failed: #{e}"
                success = false
            end
            yield [ success, msg ]

        end
    end

    def table_insert
        @settings['files'].each do | file |
            next if file['location'].empty?
            obj=Object.const_get(file['class'])
            success = true
            begin
                obj.connection.execute( file['before_insert_sql'] ) if file.has_key?( 'before_insert_sql' )
                if file.has_key?( 'insert_sql' )
                    sql=file['insert_sql']
                else
                    sql="insert into #{file['dest-table']} ( "
                    c=NAS::Util::Comma.new
                    obj.columns.each do | col |
                        sql << "#{c}#{col.name}" unless col.name == 'id'
                    end
                    sql << ") select "
                    c.reset
                    obj.columns.each do | col |
                        src_col=file['map'].fetch( col.name, "#{file['src-table']}.#{col.name}")
                        sql << "#{c}#{src_col}" unless col.name == 'id'
                    end
                    sql << " from #{file['src-table']} where not exists( "
                    sql << "select 1 from #{file['dest-table']} where "
                    sql << " #{file['src-table']}.#{file['key']}=#{file['dest-table']}.#{file['key']} )"

                end
                yield [true, sql]
                obj.connection.execute( sql )
                obj.connection.execute( file['after_insert_sql'] ) if file.has_key?( 'after_insert_sql' )
            rescue Exception=>e
                yield [ false, e.to_s ]
                success = false
            end
        end
    end

    def insert_files
        @settings['files'].each do | file |
            next if file['location'].empty?
            msg="Inserting table #{file['dest-table']} - "
            obj=Object.const_get(file['class'])
            success=true
            begin
                loc = file['location']
                obj.connection.execute( "delete from #{file['src-table']}" )
                res=`bunzip2 --force #{loc}`
                yield [ res.empty?, "bunzip2 #{loc}" ]
                loc.gsub!(/\.bz2$/,'')
                clean = '/tmp/' + file['dest-table']
                File.open( clean, 'w') do | dest |
                    File.open( loc ) do | src |
                        src.each_line do  | line |
                            els=[]
                            line.split("\t").each do | el |
                                els.push el.gsub( /[^[:print:]]/,'' )
                            end
                            dest.write( els.join("\t") + "\n" )
                        end
                    end
                end
                cmd = "COPY #{file['src-table']} from '#{clean}'"
                obj.connection.execute( cmd )
                yield [ true, cmd ]
                File.unlink( clean )
                File.unlink( loc )
            rescue ActiveRecord::StatementInvalid
                success=false
                yield [false,"#{cmd} failed"]
            end
            unless success
                msg+= "OK\n"
                yield [ success, msg ]
            end
        end
    end



end # class DBSync

end # module NAS

if __FILE__ == $0
    quiet = false

    ARGV.options do |q|p
        q.def_option('--help', 'show this message') { puts q; puts ARGV; exit(0) }
        q.def_option('--quiet','only display error messages'){ quiet = true }
        q.parse!
    end or exit(1)

    cu = NAS::DBSync.new

    cu.do { | success,msg |
        puts msg if ! success || ! quiet
    }

end

