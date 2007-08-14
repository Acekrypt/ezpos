#################################
# 
# nntp.rb - an NNTP client implementing RFC 977
# ported from the Python code by Jefferson Heard
# this software is released under the terms of the GNU Library General Public License
# (C) 2001, Jefferson Heard
#
# Contributors: Jefferson Heard, Ward Wouts
#
# Release History
#   0.1: 11.7.2001 - Initial revision.
#   0.2: 11-9-2001 - fixed regexp bugs, 
#        fixed XHDR bugs, 
#        made internal methods private, 
#        changed constructor default arg
#   0.3: 11-14-2001 - Fixed numerous bugs and made things a little cleaner 
#                           as per the suggestions of Ward Wouts
#   0.4: 11-15-2001 - Fixed statcmd bug - Ward Wouts
#   0.5: 12-06-2001 - Fixed post buf - Ozawa, Sakuro
#################################

require 'socket'
require 'net/protocol'


module NAS

module Net

# Exceptions raised by NNTP

class NNTPError < RuntimeError; end
class NNTPReplyError < NNTPError; end
class NNTPTemporaryError < NNTPError; end
class NNTPPermanentError < NNTPError; end
class NNTPDataError < NNTPError; end

class NNTP
  NNTP_PORT = 119
  LONGRESP = ['100', '215', '220', '221', '222', '224', '230', '231', '282']
  CRLF = "\r\n"

  def initialize(host, port=NNTP_PORT, user=nil, password=nil, readermode=nil)
    @debuglevel = 0
    @host = host
    if port then @port = port else @port = NNTP_PORT end
    @socket = TCPSocket.new @host, @port
    @welcome = getresp
    readermode_afterauth = false

    if readermode
      begin
      @welcome = shortcmd('mode reader')
      rescue NNTPPermanentError
      rescue NNTPTemporaryError 
        if user and $!.response[0...3] == '480'
          readermode_afterauth = true
        else 
          raise
        end
      end
    end
      
    if user
      resp = shortcmd "authinfo user #{user}"
      if resp[0...3] == '381' # then we need a password
        raise NNTPReplyError, resp, caller unless password
        resp = shortcmd "authinfo pass #{password}"
        raise NNTPPermanentError, resp, caller unless resp[0...3] == '281'
      end
    end

    if readermode_afterauth
    begin
      @welcome = shortcmd('mode reader')
      rescue NNTPPermanentError
    end
    end
  end

  def welcome
    puts "*welcome*, #{@welcome}" if @debuglevel > 0
    return @welcome
  end

  attr_writer :debuglevel

  def putline(line)
    puts '*put* '+line+'\r\n' if @debuglevel > 1
    @socket.send "#{line}\r\n", 0
  end

  def putcmd(cmd)
    puts "*cmd* #{cmd}" if @debuglevel > 0 
    putline cmd
  end

  def getline
    line = ''
      until  line.length > 2  and  line[-1] == "\n" or line[-2..-1] == "\r\n"
	  line.concat( @socket.recv( 1 ) )
      end
    puts '*getline* '+line if @debuglevel > 0
    line = line[0...-2] if line[-2..-1] == "\r\n"
    line = line[0...-1] if "\r\n".include? line[-1].to_s
    return line
  end

  def getresp
    resp = getline
    puts "*getresp* #{resp}" if @debuglevel > 0
    c = resp[0]
    case c
      when c == '4' then raise NNTPTemporaryError, resp, caller
      when c == '5' then raise NNTPPermanentError, resp, caller
      when '123'.include?(c) then raise NNTPProtocolError, resp, caller
    end
    return resp
  end

  def getlongresp   
    resp = getresp
    raise NNTPReplyError, resp, caller unless LONGRESP.include? resp[0...3]
    list = []
    while true
      line = getline
      break if line == '.'
      line = line[1..-1] if line.to_s[0...2] == '..'
      list << line
    end
    return resp, list
  end

  def shortcmd(line)
    putcmd line
    return getresp
  end

  def longcmd(line)
    putcmd line
    return getlongresp
  end

  def newgroups(date, time)
    return longcmd( "NEWGROUPS #{date.to_s} #{time.to_s}")
  end

  def newnews(group, date, time)
    return longcmd("NEWNEWS #{group} #{date.to_s} #{time.to_s}")
  end

  def list
    resp, list = longcmd "LIST" 
    list.each_index {|ix| 
      list[ix] = list[ix].split " "
    }
    return resp, list
  end

  def group(name)
    resp = shortcmd( "GROUP #{name}")
    raise NNTPReplyError, resp, caller unless resp[0...3] == '211'
    words = resp.split " "
    count, first, last = 0
    n = words.length
    if n>1
      count = words[1]
      if n>2
        first = words[2]
        if n>3
          last = words[3]
          if n>4
            name = words[4].downcase
          end
       end
     end
    end
    return resp, count, first, last, name
  end

  def help
    return longcmd( "HELP" )
  end

  def statparse(resp)
    raise NNTPReplyError, resp, caller unless resp[0...2] == '22'
    words = resp.split " "
    nr = 0
    id = ''
    n = words.length
    if n>1
      nr = words[1]
      if n>2
        id = words[2]
      end
    end
    return resp, nr, id
  end

  def statcmd(line)
    resp = shortcmd line
    return statparse(resp)
  end
  
  def stat(id)
    return statcmd( "STAT #{id}" )
  end
 
  def next
    return statcmd( "NEXT" )
  end
  
  def last
    return statcmd( "LAST" )
  end

  def articlecmd(line)
    resp, list = longcmd( line )
    resp, nr, id = statparse(resp)
    return resp, nr, id, list
  end

  def head(id)
    return articlecmd( "HEAD #{id}")
  end      

  def body(id)
    return articlecmd( "BODY #{id}")
  end

  def article(id)
    return articlecmd( "ARTICLE #{id}")
  end
 
  def slave(id)
    return shortcmd( "SLAVE")
  end

  def xhdr(hdr, str)
    pat = Regexp.new '^([0-9]+) ?(.*)\n?'
    resp, lines = longcmd( "XHDR #{hdr} #{str}" )
    lines.each_index {|ix|
      line = lines[ix]
      m = pat.match line
      lines[ix] = m[1..2] if m
    }
    return resp, lines
  end

  def xover(start, ed)
    begin
    resp, lines = longcmd( "XOVER #{start}-#{ed}" )
    xover_lines = []
    lines.each {|line|
      elements = line.split "\t"
      elements[5].split! " "
      0.upto(7) {|ix| xover_lines << element[ix]}
    }
    return resp, xover_lines
    rescue RuntimeError
      raise NNTPDataError( line, caller)
    end
  end

  def xgtitle(group) 
    line_pat = Regexp.new "^([^\t]+)[\t]+(.*)$"
    resp, raw_lines = longcmd( "XGTITLE #{group}" )
    lines = []
    raw_lines.each {|line|
      match = line_pat.match line.strip
      lines << match[1..2] if match
    }
    return resp, lines
  end
  
  def date
    resp = shortcmd "DATE"
    raise NNTPReplyError unless resp[0...3] == '111'
    resp.split! " "
    raise NNTPDataError unless resp.length == 2
    date = resp[1][2...8]
    time = resp[1][-6..-1]
    raise NNTPDataError( resp, caller ) unless date.length == 6 and time.length == 6
    return resp, date, time
  end

  def post(f)
    resp = shortcmd "POST"
    raise NNTPReplyError unless resp =~ /^3/ #[0] == 3
#    lines = f.readlines
      f.each_line {|line| 
       line.chop!
       line = '.' + line if line[0] == '.'
       putline line
    }
    putline '.'
    return getresp
  end

  def quit
    resp = shortcmd "QUIT"
    @socket.close_read
    @socket.close_write
    return resp
  end     

  private :statparse, :getline, :putline, :articlecmd, :statcmd
  protected :getresp, :getlongresp 
end

end

if __FILE__ == $0 
   s = Net::NNTP.new('news.allmed.net')


msg=<<EOS
From:                       Nathan Stitt <nathan@allmed.net>
Message-ID:                 <c7jklb3ijksalfdm$740$2@thor.allmed.net>
Newsgroups:                 test
Organization:               Alliance Medical
Path:                       unknown!not-for-mail
Subject:                    Testing foolishly


MIME-Version:               1.0
Content-Type:               text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding:  7bit

for great justice

EOS
puts msg


   resp, count, first, last, name = s.group('allmed')
   puts resp
   puts "group #{name} has #{count} articles, range #{first} to #{last}"
   resp, subs = s.xhdr('subject', "#{first}-#{last}")

s.post( msg )
   puts resp
   subs.each do |sub| puts sub end
   resp = s.quit
   puts resp
end


end # module NAS
