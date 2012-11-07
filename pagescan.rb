#!/usr/bin/ruby

basedir = __FILE__
while File.symlink?(basedir)
        basedir = File.expand_path(File.readlink(basedir), File.dirname(basedir))
end
$:.unshift(File.join(File.expand_path(File.dirname(basedir))))

require 'lib.rb'

def get_redirection(url)
        site = Geturl.new(url)
        $url << site

        unless site.urlredirect.empty?
                get_redirection(site.urlredirect)
        end
end

def get_iframecon
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
                        $url << Geturl.new(url)
                end
        end
end

if __FILE__ == $0
        url = ARGV[0]
        $url = Array.new

        get_redirection(url)
        get_iframecon

        $url.each do |site|
                if site.code =~ /ERROR/
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
                        puts "McAfee Site Advisor: " + site.blist[:mcafee]
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
end
