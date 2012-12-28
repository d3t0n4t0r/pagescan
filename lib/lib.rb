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


require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'uri'
require 'net/http'

$settings = { "User-Agent" => "Mozilla/5.0 (Windows; U; Windows NT 6.1; en-US; rv:1.9.2.13) Gecko/20101203 Firefox/3.6.13", 
					"Referer" => "http://www.google.com/" }
$seq = Array.new

def get_redirection(url,options)
	$time << Time.new

	site = Geturl.new(url,options)
	$url << site

	unless site.urlredirect.empty?
		options['referer'] = url
		get_redirection(site.urlredirect,options)
	end
end

def get_iframecon(options)
	iframearr = Array.new
	referer = Array.new

	$url.each do |site|
		if site.iframe.length > 0
			site.iframe.each do |frame|
				iframearr << [frame.to_s,site.url]
			end
		end
	end

	iframearr.uniq!

	if iframearr.length > 0
		iframearr.each do |iframe,referer|
			if iframe.match(/^http[s]{0,1}:\/\/.*?\.twitter\.com\//)
			elsif iframe.match(/^http[s]{0,1}:\/\/.*?\.facebook\.com\//)
			else
				$time << Time.new
				options['referer'] = referer
				$url << Geturl.new(iframe,options)
			end
		end
	end
end

class Geturl
	attr_reader :url, :ip, :blist, :code, :urlredirect, :con, :js, :iframe, :link, :referer


	def initialize(url,options)
		@url = httpurl(url)
		$seq << @url
		@ip = get_ip(@url)
		@blist = get_blacklisted(@url)
		@code = ''
		@urlredirect = ''
		@con = ''
		@js = Array.new
		@iframe = Array.new
		@link = Array.new
		$settings["User-Agent"] = options['user_agent'] unless options['user_agent'].nil?
		$settings["Referer"] = options['referer'] unless options['referer'].nil?
		@referer = $settings["Referer"]

		go
	end

	def go
		response = get_content(@url)

		if response.to_s =~ /ERROR/
			@code = response
		else
			@code = response.code
		
			unless response.body.nil?
				unless response.content_type.match(/application\/x-javascript|text\/html/)
					filename = ''
					path = URI.parse(@url).path
					if path.match(/\//)
						filesplit = path.split('/')
						filename = filesplit.last
					else
						filename = path
					end
					
					fileout = "#{$time.last.day}_#{$time.last.month}_#{$time.last.year}-#{$time.last.hour}_#{$time.last.min}_#{$time.last.sec}-#{filename}"
					File.open(fileout,"w") do |f|
						f.write(response.body)
					end
				end

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
		begin
			hostname = URI.parse(url).host
		rescue
		end

		ip = `dig +short @8.8.8.8 #{hostname}` # CHEATER !!
		
		if ip.empty? or ip.nil?
			if hostname.match(/(?:\d{1,3}\.){3}\d{1,3}/)
				ip = hostname
			else
				ip = "No record"
			end
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
			request.initialize_http_header($settings)
			response = http.request(request)
		rescue => e
			#@code = "ERROR: <#{e.class.name}> #{e.to_s}"
			return "ERROR: <#{e.class.name}> #{e.to_s}"
		end
	end

	def redirect(response)
		if @code =~ /302/ or @code =~ /301/
			if URI.parse(response['Location']).host.nil? == false
				@urlredirect = response['Location']
				$seq << @urlredirect
			else
				@urlredirect = URI.join(@url, response['Location']).to_s
				$seq << @urlredirect
			end
		else
			unless response.body.empty? or response.body.nil?
				html = ''
				url_redirect = Array.new
				meta_redirect = ''

				html = Nokogiri::HTML(response.body)
				jscode = parse_js(html)
                		
				jscode.each do |js|
					if js[1].match(/location\.replace\(\".*?\"\);/)
						js[1].scan(/location\.replace\(\"(.*?)\"\);/).flatten.each do |i|
							url_redirect << URI.parse(@url).merge(URI.parse(URI.escape(i))).to_s
						end
					end

					if js[1].match(/window\.navigate\(\".*?\"\);/)
						js[1].scan(/window\.navigate\(\"(.*?)\"\);/).flatten.each do |i|
							url_redirect << URI.parse(@url).merge(URI.parse(URI.escape(i))).to_s
						end
					end

					if js[1].match(/document\.location\s{0,}=\s{0,}["'].*?["'];/)
						js[1].scan(/document\.location\s{0,}=\s{0,}["'](.*?)["'];/).flatten.each do |i|
							url_redirect << URI.parse(@url).merge(URI.parse(URI.escape(i))).to_s
						end
					end

					if js[1].match(/window\.location\s{0,}=\s{0,}["'].*?["'];/)
						js[1].scan(/window\.location\s{0,}=\s{0,}["'](.*?)["'];/).flatten.each do |i|
							url_redirect << URI.parse(@url).merge(URI.parse(URI.escape(i))).to_s
						end
					end

					if js[1].match(/window\.location\.href\s{0,}=\s{0,}["'].*?["'];/)
						js[1].scan(/window\.location\.href\s{0,}=\s{0,}["'](.*?)["'];/).flatten.each do |i|
							url_redirect << URI.parse(@url).merge(URI.parse(URI.escape(i))).to_s
						end
					end

					if js[1].match(/self\.location\s{0,}=\s{0,}["'].*?["'];/)
						js[1].scan(/self\.location\s{0,}=\s{0,}["'](.*?)["'];/).flatten.each do |i|
							url_redirect << URI.parse(@url).merge(URI.parse(URI.escape(i))).to_s
						end
					end

					if js[1].match(/top\.location\s{0,}=\s{0,}["'].*?["'];/)
						js[1].scan(/top\.location\s{0,}=\s{0,}["'](.*?)["'];/).flatten.each do |i|
							url_redirect << URI.parse(@url).merge(URI.parse(URI.escape(i))).to_s
						end
					end

					if js[1].match(/top\.location\.href\s{0,}=\s{0,}["'].*?["'];/)
						js[1].scan(/top\.location\.href\s{0,}=\s{0,}["'](.*?)["'];/).flatten.each do |i|
							url_redirect << URI.parse(@url).merge(URI.parse(URI.escape(i))).to_s
						end
					end
				end

				html.search("meta[http-equiv='refresh']").map do |meta|
					if meta['content'].match(/url=/i)
						meta['content'].scan(/url=(.*?)$/i).flatten.each do |i|
							url_redirect << URI.parse(@url).merge(URI.parse(URI.escape(i))).to_s
						end
					end
				end

				html.search("meta[http-equiv='Refresh']").map do |meta|
					if meta['content'].match(/url=/i)
						meta['content'].scan(/url=(.*?)$/i).flatten.each do |i|
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
		js = Array.new

		unless parsecon.nil?
			parsecon.search('script').map do |scr|
				tempsrc = ''
				tempcode = ''

				unless scr['src'].nil?
					tempsrc = URI.parse(@url).merge(URI.parse(URI.escape(scr['src']))).to_s
					tempcode = get_content(tempsrc).body
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
		# TODO:
		# Check Iframe on JavaScript code in print()  
		# document.write('<iframe src="http://blabla.com" scrolling="auto" frameborder="no" align="center" height="2" width="2"></iframe>');
		# Check <IFRAME></IFRAME>
		# <frame src="http://evil.com/" name="dot_tk_frame_content" scrolling="auto" noresize>

		iframe = Array.new

		unless parsecon.nil?
			parsecon.search('iframe').map do |ifr|
				unless ifr['src'].nil? or ifr['src'].empty?
					iframe << URI.parse(@url).merge(URI.parse(URI.escape(ifr['src']))).to_s
				end
			end
		end

		return iframe.uniq
	end

	def parse_link(parsecon)
		links = Array.new

		unless parsecon.nil?
			parsecon.search('a').map do |lin|
				unless lin['href'].nil? or lin['href'].empty?	
					unless lin['href'].match(/^javascript/)
						links << URI.parse(@url).merge(URI.parse(URI.escape(lin['href']))).to_s
					end
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
