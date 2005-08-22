#!/usr/bin/ruby

require 'nntp'



nntp = Net::NNTP.new('news.allmed.net')
puts nntp.article( ARGV[0] )
