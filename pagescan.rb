#!/usr/bin/ruby
#
# PageScan
#    by d3t0n4t0r
#
# version: 0.1
# 
# changelog:
#       21 Oct 2012 - Project started 
# 	08 Nov 2012 - (0.1) Initial release
# 	23 Nov 2012 - Added command-line options
# 			- User Agent
# 			- Referer
# 	27 Nov 2012 - Fix the output msg for Net::HTTP error handling
# 		    - Fix the URL escape found in links/iframe/js's src
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

require 'lib.rb'
require 'optparse'

def get_redirection(url,options)
        site = Geturl.new(url,options)
        $url << site

        unless site.urlredirect.empty?
                get_redirection(site.urlredirect,options)
        end
end

def get_iframecon(options)
        iframearr = Array.new
        $url.each do |site|
                if site.iframe.length > 0
                        site.iframe.each do |frame|
                                iframearr << frame
                        end
                end
        end

        iframearr.flatten!
        iframearr.uniq!

        if iframearr.length > 0
                iframearr.each do |url|
                        $url << Geturl.new(url,options)
                end
        end
end

def print(site)
	if site.code =~ /ERROR/
		p site.code
		p site.url
		puts site.code + " - " + URI.parse(site.url).host
	else
	puts "URL: " + site.url

	puts "IP Address: "
	site.ip.each do |i|
		puts "|\n+- " + i
	end
	puts

	puts "Code: " + site.code
	puts "Redirect to: " + site.urlredirect
	puts

	puts "Blacklist"
	puts "---------"
	puts "Google Safebrowsing: " + site.blist[:google]
	puts "Norton Safe Web: " + site.blist[:norton]
	#puts "McAfee Site Advisor: " + site.blist[:mcafee]
	puts

	puts "Content"
	puts "-------"
	puts site.con
	puts

	puts "JavaScript"
	puts "----------"
	site.js.each do |sc|
		puts "|\n+- URL: " + sc[0]
		puts "|\n+- Code: ", sc[1]
		puts
	end
	puts

	puts "Iframe"
	puts "------"
	site.iframe.each do |frame|
		puts "|\n+- " + frame
	end
	puts

	puts "Links"
	puts "-----"
	site.link.each do |lin|
		puts "|\n+- " + lin
	end
	puts
	end
end

if __FILE__ == $0
	options = {}

	opts = OptionParser.new do |opts|
        	opts.banner = "Usage: #{$0} [options] [url]"

        	opts.separator "Options:"

        	opts.on("-u", "--user-agent <user-agent>", "Use the specified User Agent. If not specified, default User Agent will be used") do |u|
                	options['user_agent'] = u
        	end

        	opts.on("-r", "--referer <referer-addr>", "Use the specified Referer Address. If not specified, default referer address will be used") do |r|
                	options['referer'] = r
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

        get_redirection(url,options)
        get_iframecon(options)

        $url.each do |site|
        	print(site)
	end
end
