#!/usr/bin/ruby
#
# PageScan
#    by d3t0n4t0r
#
# version: 0.2
# 
#
# WTFPL - Do What The Fuck You Want To Public License
# ---------------------------------------------------
# This program is free software. It comes without any warranty, to
# the extent permitted by applicable law. You can redistribute it
# and/or modify it under the terms of the Do What The Fuck You Want
# To Public License, Version 2, as published by Sam Hocevar. See
# http://sam.zoy.org/wtfpl/COPYING for more details.
#


basedir = __FILE__
while File.symlink?(basedir)
	basedir = File.expand_path(File.readlink(basedir), File.dirname(basedir))
end
$:.unshift(File.join(File.expand_path(File.dirname(basedir))))

require 'lib/lib.rb'
require 'lib/report.rb'
require 'optparse'

PSVER = "0.1"

if __FILE__ == $0
	options = {}

	opts = OptionParser.new do |opts|
		opts.banner = "PageScan #{PSVER} by d3t0n4t0r\n\nUsage: #{$0} [options] [url]"
		opts.separator "Options:"
		
		opts.on("-u", "--user-agent <user-agent>", "Use the specified User Agent. If not specified, default User Agent will be used") do |u|
			options['user_agent'] = u
		end
		
		opts.on("-r", "--referer <referer-addr>", "Use the specified Referer Address. If not specified, default referer address will be used") do |r|
			options['referer'] = r
		end
		
		opts.on("-o", "--output <txt|html>", "Specified report format for further analysis") do |o|
			options['output'] = o
		end

		opts.on_tail("-h", "--help", "Show this message") do
			puts opts
			exit
		end
	end

	begin
		opts.parse!(ARGV)
	rescue OptionParser::InvalidOption
		puts "Invalid option, try -h for usage"
		exit
	end

	if ARGV[0].nil?
		puts "URL not specified, try -h for usage"
		exit
	end

	url = ARGV[0]
	$url = Array.new
	$time = Array.new

	get_redirection(url,options)
	get_iframecon(options)

	case options['output']
	when 'txt'
		print_txt
	when 'html'
		print_html
	else
		print_txt
	end
end
