PageScan v0.1-alpha
========
*developed by d3t0n4t0r*

Description
-----------
PageScan is a web content scraper for web-based malware analysis. It assist analyst by detecting and listing any redirection, iframe, javascript, and links found inside the web page.

Requirement
------------
- ruby 1.8.7
- gem 1.3.7
- Nokogiri
  $ gem install nokogiri

Usage
-----
$ ruby pagescan.rb URL

e.g: ruby pagescan.rb http://blog.lab69.com

Future improvement (?)
---------------------
- Proper command-line options
- Better result output (text output & web-based output)
- Yara signature support
