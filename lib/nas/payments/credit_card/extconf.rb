
require 'mkmf'

unless have_library("lptxn", "") && have_library("lpssl", "")
    STDERR.puts "Could not find lptxn and/or lpssl libraries: Makefile not created" 
    exit 1
end

create_makefile("c_yourpay")
arr=Array.new
File::open("Makefile","r"){|f| 
    f.each_line{ | l | 
        arr << l.gsub(/gcc/,'g++') 
    }
}

File::open("Makefile","w"){|f|
  arr.each{|l|
    f.puts(l)
  }
}

