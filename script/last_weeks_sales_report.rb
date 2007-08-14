#!/usr/bin/env ruby

ENV["RAILS_ENV"] = "production"

require File.dirname(__FILE__) + '/../config/boot'
require RAILS_ROOT + '/config/environment'
require 'nas/dbsync'
require 'nas/ezpos/sales_report'
require 'nas/payments/credit_card/yourpay'

sr=NAS::EZPOS::SalesReport.new( Time.now-604800,Time.now )

sr.xls( "/tmp/pos-#{sr.suggested_file_name}.xls" )

