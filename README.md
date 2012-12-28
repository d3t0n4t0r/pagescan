PageScan v0.2
========
*developed by [d3t0n4t0r](http://blog.lab69.com)*

Description
-----------
PageScan is a web content scraper for web-based malware analysis. It assist analyst by detecting and listing any redirection, iframe, javascript, and links found inside the web page.

Requirement
------------
* ruby 1.8.7
* gem 1.3.7
* nokogiri
* optparse

Usage
-----
	Usage: /usr/local/bin/pagescan [options] [url]
	Options:
	  -u, --user-agent <user-agent>    Use the specified User Agent. If not specified, default User Agent will be used
	  -r, --referer <referer-addr>     Use the specified Referer. If not specified, default Referer will be used
	  -o, --output <txt|html>          Specified report format for further analysis
	  -h, --help                       Show this message


Future improvement (?)
---------------------
- Better result output (text & HTML output)
- Yara signature support

License
-----------
PageScan licensed under [WTFPL V2](http://sam.zoy.org/wtfpl/)

Credit
-------
- [LAB69](http://lab69.com)
- [MyYaraSIG](https://twitter.com/MyYaraSIG)
