#!/usr/bin/ruby
#
# PageScan
#    by d3t0n4t0r
#
# version: 0.1
# 
# changelog:
# 	21 Oct 2012 - Project started 
# 	08 Nov 2012 - (0.1) Initial release
#       23 Nov 2012 - Added command-line options
#			- User Agent
#			- Referer
#	27 Nov 2012 - Fix the output msg for Net::HTTP error handling
#		    - Fix the URL escape found in links/iframe/js's src
#
#
# WTFPL - Do What The Fuck You Want To Public License
# ---------------------------------------------------
# This program is free software. It comes without any warranty, to
# the extent permitted by applicable law. You can redistribute it
# and/or modify it under the terms of the Do What The Fuck You Want
# To Public License, Version 2, as published by Sam Hocevar. See
# http://sam.zoy.org/wtfpl/COPYING for more details.


require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'uri'
require 'net/http'

$useragent = {
	"User-Agent" => "Mozilla/5.0 (Windows; U; Windows NT 6.1; en-US; rv:1.9.2.13) Gecko/20101203 Firefox/3.6.13", 
	"Referer" => "http://www.google.com/"
	}
$seq = []

class Geturl
	attr_reader :url, :ip, :blist, :code, :urlredirect, :con, :js, :iframe, :link


	def initialize(url,options)
		@url = httpurl(url)
		$seq << @url
		@ip = get_ip(@url)
		@blist = get_blacklisted(@url)
		@code = ''
		@urlredirect = ''
		@con = ''
		@js = []
		@iframe = []
		@link = []
		$useragent["User-Agent"] = options['user_agent'] unless options['user_agent'].nil?
		$useragent["Referer"] = options['referer'] unless options['referer'].nil?
	
		go
	end

	def go
		response = get_content(@url)

		if response.to_s =~ /ERROR/
			@code = response
		else
			@code = response.code
		
			unless response.body.nil?
				parsecon = Nokogiri::HTML(response.body)
				redirect(response)
				@con = response.body
				@js = parse_js(parsecon)
				@iframe = parse_iframe(parsecon)
				@link = parse_link(parsecon)
			end
		end
	end

	def httpurl(url)
        	if (url =~ URI::regexp(%w(http https))).nil?
                	url = "http://" + url
        	end

        	url = URI.escape(url)

        	return url
	end

	def get_ip(url)
        	hostname = URI.parse(url).host
        	ip = `dig +short @8.8.8.8 #{hostname}` # CHEATER !!
		
		if ip.empty? or ip.nil?
			ip = hostname if hostname.match(/(?:\d{1,3}\.){3}\d{1,3}/)
		else
			ip = ip.scan(/((?:\d{1,3}\.){3}\d{1,3})/).flatten
		end

        	return ip
	end

	def get_content(uri)
                begin
                        response = ''
                        uri = URI.parse(uri)
                        http = Net::HTTP.new(uri.host, uri.port)
                        request = Net::HTTP::Get.new(uri.request_uri)
                        request.initialize_http_header($useragent)
                        response = http.request(request)
                rescue => e
			#@code = "ERROR: <#{e.class.name}> #{e.to_s}"
			return "ERROR: <#{e.class.name}> #{e.to_s}"
                end
        end

	def redirect(response)
		if @code =~ /302/ or @code =~ /301/
			if response['Location'] =~ /http|https/
				@urlredirect = response['Location']
				$seq << @urlredirect
			else
				@urlredirect = @url + response['Location']
				$seq << @urlredirect
			end
		else
			unless response.body.empty? or response.body.nil?
                		html = ''
                		url_redirect = []
                		meta_redirect = ''

                		html = Nokogiri::HTML(response.body)

                		jscode = parse_js(html)
                		jscode.each do |js|
                        		if js[1].match(/location\.replace\(\".*?\"\);/)
						js[1].scan(/location\.replace\(\"(.*?)\"\);/).each do |i|
							url_redirect << URI.parse(@url).merge(URI.parse(URI.escape(i))).to_s
						end
                        		end

                                        if js[1].match(/window\.navigate\(\".*?\"\);/)
                                                js[1].scan(/window\.navigate\(\"(.*?)\"\);/).each do |i|
                                                        url_redirect << URI.parse(@url).merge(URI.parse(URI.escape(i))).to_s
                                                end
                                        end

                                        if js[1].match(/document\.location\s{0,}=\s{0,}["'].*?["'];/)
                                                js[1].scan(/document\.location\s{0,}=\s{0,}["'](.*?)["'];/).each do |i|
                                                        url_redirect << URI.parse(@url).merge(URI.parse(URI.escape(i))).to_s
                                                end
                                        end

                                        if js[1].match(/window\.location\s{0,}=\s{0,}["'].*?["'];/)
                                                js[1].scan(/window\.location\s{0,}=\s{0,}["'](.*?)["'];/).each do |i|
                                                        url_redirect << URI.parse(@url).merge(URI.parse(URI.escape(i))).to_s
                                                end
                                        end

                                        if js[1].match(/window\.location\.href\s{0,}=\s{0,}["'].*?["'];/)
                                                js[1].scan(/window\.location\.href\s{0,}=\s{0,}["'](.*?)["'];/).each do |i|
                                                        url_redirect << URI.parse(@url).merge(URI.parse(URI.escape(i))).to_s
                                                end
                                        end

                                        if js[1].match(/self\.location\s{0,}=\s{0,}["'].*?["'];/)
                                                js[1].scan(/self\.location\s{0,}=\s{0,}["'](.*?)["'];/).each do |i|
                                                        url_redirect << URI.parse(@url).merge(URI.parse(URI.escape(i))).to_s
                                                end
                                        end

                                        if js[1].match(/top\.location\s{0,}=\s{0,}["'].*?["'];/)
                                                js[1].scan(/top\.location\s{0,}=\s{0,}["'](.*?)["'];/).each do |i|
                                                        url_redirect << URI.parse(@url).merge(URI.parse(URI.escape(i))).to_s
                                                end
                                        end

                                        if js[1].match(/top\.location\.href\s{0,}=\s{0,}["'].*?["'];/)
                                                js[1].scan(/top\.location\.href\s{0,}=\s{0,}["'](.*?)["'];/).each do |i|
                                                        url_redirect << URI.parse(@url).merge(URI.parse(URI.escape(i))).to_s
                                                end
                                        end
                                end

                		html.search("meta[http-equiv='refresh']").map do |meta|
                        		if meta['content'].match(/url=/)
						meta['content'].scan(/url=(.*?)$/).each do |i|
							url_redirect << URI.parse(@url).merge(URI.parse(URI.escape(i))).to_s
						end
                        		end
                		end

                		html.search("meta[http-equiv='Refresh']").map do |meta|
                        		if meta['content'].match(/url=/)
						meta['content'].scan(/url=(.*?)$/).each do |i|
							url_redirect << URI.parse(@url).merge(URI.parse(URI.escape(i))).to_s
						end
                        		end
                		end

				url_redirect.flatten!
				url_redirect.uniq!

                		unless url_redirect.empty? or url_redirect.nil?
                                	if url_redirect.length == 1
						@urlredirect = url_redirect.to_s
						$seq << @urlredirect
                                	else
						@urlredirect = url_redirect[0].to_s
						$seq << @urlredirect
                        		end
				end
                	end
        	end
	end

	def parse_js(parsecon)
		tempsrc = ''
        	tempcode = ''
        	js = []

        	unless parsecon.nil?
                	parsecon.search('script').map do |scr|
                        	tempsrc = ''
                        	tempcode = ''

                        	unless scr['src'].nil?
                                	tempsrc = URI.parse(@url).merge(URI.parse(URI.escape(scr['src']))).to_s
                                	begin
                                        	tempcode = get_content(tempsrc).body
                                	rescue
                                	end
                        	end

                        	unless scr.text.empty?
                                	tempcode = scr.text
                        	end

                        	js << [tempsrc,tempcode]
                	end
        	end

        	return js
	end

	def parse_iframe(parsecon)
		# Check Iframe on JavaScript code in print()  
		# document.write('<iframe src="http://blabla.com" scrolling="auto" frameborder="no" align="center" height="2" width="2"></iframe>');
        	# Check <IFRAME></IFRAME>
        	# <frame src="http://evil.com/" name="dot_tk_frame_content" scrolling="auto" noresize>
        	# Get iframe content
        	# Whitelist:
        	# - facebook
        	# -  http://platform.twitter.com/widgets/follow_button.html?screen_name=bnp2tki

		iframe = []

        	unless parsecon.nil?
                	parsecon.search('iframe').map do |ifr|
                        	iframe << URI.parse(@url).merge(URI.parse(URI.escape(ifr['src']))).to_s
                	end
        	end

        	return iframe.uniq
	end

	def parse_link(parsecon)
        	links = []

        	unless parsecon.nil?
                	parsecon.search('a').map do |lin|
                        	begin
                                	links << URI.parse(@url).merge(URI.parse(URI.escape(lin['href']))).to_s
                        	rescue
                        	end
                	end
        	end

        	return links.uniq
	end

	def get_blacklisted(site)
		result = Hash.new
        	result.merge!(google(site))
        	result.merge!(norton(site))
		#result.merge!(mcafee(site))

		return result
	end

	def google(site)
        	gurl = "http://safebrowsing.clients.google.com/safebrowsing/diagnostic?site="
        	blacklist = 'No'

        	gcon = get_content(gurl+site)


        	unless gcon.nil?
                	if gcon.body.match(/Site\s{1}is\s{1}listed\s{1}as\s{1}suspicious/i)
                        	blacklist = 'Yes'
                	end
        	end

        	return :google => blacklist
	end

	def norton(site)
        	nurl = "http://safeweb.norton.com/report/show?url="
        	blacklist = 'No'

        	ncon = get_content(nurl+site)

        	unless ncon.nil?
                	if ncon.body.match(/<div\s{1,}class="ratingIcon\s{1,}icoWarning">.*?<label>\s{0,}WARNING/m)
                        	blacklist = 'Warning'
                	elsif ncon.body.match(/<div\s{1,}class="ratingIcon\s{1,}icoCaution">.*?<label>\s{0,}CAUTION/m)
                        	blacklist = 'Caution'
                	elsif ncon.body.match(/<div\s{1,}class="ratingIcon\s{1,}icoUntested">.*?<label>\s{0,}UNTESTED/m)
                        	blacklist = 'Untested'
                	end
        	end

        	return :norton => blacklist
	end

	def mcafee(site)
		murl = "http://www.siteadvisor.com/sites/"
		blacklist = "No"
		
		mcon = get_content(murl+site)

		unless mcon.nil?
		end
		
		return :mcafee => blacklist
	end
end
