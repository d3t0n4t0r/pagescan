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

require 'cgi'

def print_txt
	out = "\n"
	i = 0

	$url.each do |site|
		if i != 0
			out << "+" + "-"*78 + "+\n\n"
		end

		out << "+--------------+\n"
		out << "| URL Overview |\n"
		out << "+--------------+\n"
		out << " URL: #{site.url}\n"

		ip_i = 0
		site.ip.each do |ip|
			out << (ip_i == 0 ? " IP Address: #{ip}\n" : "             #{ip}\n")
			ip_i += 1
		end
	
		out << " Analyzed on: #{$time[i]}\n"

		if site.code.match(/ERROR/)
			out << " Status: Report error - #{site.code.gsub(/ERROR:\s/,'')}\n"
		else
			out << " Status: Report completed\n"
			out << " Response code: #{site.code}\n"
			out << " Redirect to: #{site.urlredirect}\n"
		end

		out << "\n"

		out << "+--------------+\n"
		out << "| URL Settings |\n"
		out << "+--------------+\n"

		out << " User Agent: #{$settings["User-Agent"]}\n"
		out << " Referer: #{site.referer}\n"

		out << "\n"

		out << "+--------------+\n"
		out << "| Blacklisting |\n"
		out << "+--------------+\n"

		out << " Google Safebrowsing: #{site.blist[:google]}\n"
		out << " Norton Safe Web: #{site.blist[:norton]}\n"

		out << "\n"
	
		unless site.con.empty? or site.con.nil?
			size_con = 0
			size_con = site.con.strip.length

			out << "+---------+\n"
			out << "| Content |\n"
			out << "+---------+\n"
			out << " +----------\n"
			out << " | Length: #{size_con}\n"
			out << "\n#{site.con.strip}\n\n"
		end

		unless site.js.empty? or site.js.nil?
			out << "+------------+\n"
			out << "| JavaScript |\n"
			out << "+------------+\n"

			size_sc = 0
			js_i = 1
			site.js.each do |sc|
				size_sc = sc[1].strip.length
				out << " +----------\n"
				out << " | Script ##{js_i}\n"
				out << " | Length: #{size_sc}\n"
				
				if sc[0].empty? or sc[0].nil?
					out << "\n"
				else
					out << " | URL: #{sc[0]}\n\n"
				end

				out << "#{sc[1].strip}\n\n"
                                
				js_i += 1
			end
		end

		unless site.iframe.empty? or site.iframe.nil?
			out << "+--------+\n"
			out << "| Iframe |\n"
			out << "+--------+\n"
			
			site.iframe.each do |ifr|
				out << " - #{ifr}\n"
			end
			
			out << "\n"
		end

		unless site.link.empty? or site.link.nil?
			out << "+-------+\n"
			out << "| Links |\n"
			out << "+-------+\n"

			site.link.each do |links|
				out << " - #{links}\n"
			end

			out << "\n"
		end

		i += 1
	end

	fileout = "#{$time[0].day}_#{$time[0].month}_#{$time[0].year}-#{$time[0].hour}_#{$time[0].min}_#{$time[0].sec}-#{URI.parse($url[0].url).host}.txt"

 	File.open(fileout, 'w') do |f|
		f.write(out)
	end

	puts out
	puts "\nPageScan TXT report has been generated - #{fileout}\n"
end


def print_html
	out =<<REPORT
<html>
<head>
	<script src="http://code.jquery.com/jquery.min.js" type="text/javascript"></script>
	<script>
		/* 	
			* HIGHLIGHT.JS
			* by Software Maniacs
			*
			* http://softwaremaniacs.org/soft/highlight/en/ 
		    	*/
		
			var hljs=new function(){function l(o){return o.replace(/&/gm,"&amp;").replace(/</gm,"&lt;").replace(/>/gm,"&gt;")}function b(p){for(var o=p.firstChild;o;o=o.nextSibling){if(o.nodeName=="CODE"){return o}if(!(o.nodeType==3&&o.nodeValue.match(/\\s+/))){break}}}function h(p,o){return Array.prototype.map.call(p.childNodes,function(q){if(q.nodeType==3){return o?q.nodeValue.replace(/\\n/g,""):q.nodeValue}if(q.nodeName=="BR"){return"\\n"}return h(q,o)}).join("")}function a(q){var p=(q.className+" "+q.parentNode.className).split(/\\s+/);p=p.map(function(r){return r.replace(/^language-/,"")});for(var o=0;o<p.length;o++){if(e[p[o]]||p[o]=="no-highlight"){return p[o]}}}function c(q){var o=[];(function p(r,s){for(var t=r.firstChild;t;t=t.nextSibling){if(t.nodeType==3){s+=t.nodeValue.length}else{if(t.nodeName=="BR"){s+=1}else{if(t.nodeType==1){o.push({event:"start",offset:s,node:t});s=p(t,s);o.push({event:"stop",offset:s,node:t})}}}}return s})(q,0);return o}function j(x,v,w){var p=0;var y="";var r=[];function t(){if(x.length&&v.length){if(x[0].offset!=v[0].offset){return(x[0].offset<v[0].offset)?x:v}else{return v[0].event=="start"?x:v}}else{return x.length?x:v}}function s(A){function z(B){return" "+B.nodeName+'="'+l(B.value)+'"'}return"<"+A.nodeName+Array.prototype.map.call(A.attributes,z).join("")+">"}while(x.length||v.length){var u=t().splice(0,1)[0];y+=l(w.substr(p,u.offset-p));p=u.offset;if(u.event=="start"){y+=s(u.node);r.push(u.node)}else{if(u.event=="stop"){var o,q=r.length;do{q--;o=r[q];y+=("</"+o.nodeName.toLowerCase()+">")}while(o!=u.node);r.splice(q,1);while(q<r.length){y+=s(r[q]);q++}}}}return y+l(w.substr(p))}function f(q){function o(s,r){return RegExp(s,"m"+(q.cI?"i":"")+(r?"g":""))}function p(y,w){if(y.compiled){return}y.compiled=true;var s=[];if(y.k){var r={};function z(A,t){t.split(" ").forEach(function(B){var C=B.split("|");r[C[0]]=[A,C[1]?Number(C[1]):1];s.push(C[0])})}y.lR=o(y.l||hljs.IR,true);if(typeof y.k=="string"){z("keyword",y.k)}else{for(var x in y.k){if(!y.k.hasOwnProperty(x)){continue}z(x,y.k[x])}}y.k=r}if(w){if(y.bWK){y.b="\\\\b("+s.join("|")+")\\\\s"}y.bR=o(y.b?y.b:"\\\\B|\\\\b");if(!y.e&&!y.eW){y.e="\\\\B|\\\\b"}if(y.e){y.eR=o(y.e)}y.tE=y.e||"";if(y.eW&&w.tE){y.tE+=(y.e?"|":"")+w.tE}}if(y.i){y.iR=o(y.i)}if(y.r===undefined){y.r=1}if(!y.c){y.c=[]}for(var v=0;v<y.c.length;v++){if(y.c[v]=="self"){y.c[v]=y}p(y.c[v],y)}if(y.starts){p(y.starts,w)}var u=[];for(var v=0;v<y.c.length;v++){u.push(y.c[v].b)}if(y.tE){u.push(y.tE)}if(y.i){u.push(y.i)}y.t=u.length?o(u.join("|"),true):{exec:function(t){return null}}}p(q)}function d(D,E){function o(r,M){for(var L=0;L<M.c.length;L++){var K=M.c[L].bR.exec(r);if(K&&K.index==0){return M.c[L]}}}function s(K,r){if(K.e&&K.eR.test(r)){return K}if(K.eW){return s(K.parent,r)}}function t(r,K){return K.i&&K.iR.test(r)}function y(L,r){var K=F.cI?r[0].toLowerCase():r[0];return L.k.hasOwnProperty(K)&&L.k[K]}function G(){var K=l(w);if(!A.k){return K}var r="";var N=0;A.lR.lastIndex=0;var L=A.lR.exec(K);while(L){r+=K.substr(N,L.index-N);var M=y(A,L);if(M){v+=M[1];r+='<span class="'+M[0]+'">'+L[0]+"</span>"}else{r+=L[0]}N=A.lR.lastIndex;L=A.lR.exec(K)}return r+K.substr(N)}function z(){if(A.sL&&!e[A.sL]){return l(w)}var r=A.sL?d(A.sL,w):g(w);if(A.r>0){v+=r.keyword_count;B+=r.r}return'<span class="'+r.language+'">'+r.value+"</span>"}function J(){return A.sL!==undefined?z():G()}function I(L,r){var K=L.cN?'<span class="'+L.cN+'">':"";if(L.rB){x+=K;w=""}else{if(L.eB){x+=l(r)+K;w=""}else{x+=K;w=r}}A=Object.create(L,{parent:{value:A}});B+=L.r}function C(K,r){w+=K;if(r===undefined){x+=J();return 0}var L=o(r,A);if(L){x+=J();I(L,r);return L.rB?0:r.length}var M=s(A,r);if(M){if(!(M.rE||M.eE)){w+=r}x+=J();do{if(A.cN){x+="</span>"}A=A.parent}while(A!=M.parent);if(M.eE){x+=l(r)}w="";if(M.starts){I(M.starts,"")}return M.rE?0:r.length}if(t(r,A)){throw"Illegal"}w+=r;return r.length||1}var F=e[D];f(F);var A=F;var w="";var B=0;var v=0;var x="";try{var u,q,p=0;while(true){A.t.lastIndex=p;u=A.t.exec(E);if(!u){break}q=C(E.substr(p,u.index-p),u[0]);p=u.index+q}C(E.substr(p));return{r:B,keyword_count:v,value:x,language:D}}catch(H){if(H=="Illegal"){return{r:0,keyword_count:0,value:l(E)}}else{throw H}}}function g(s){var o={keyword_count:0,r:0,value:l(s)};var q=o;for(var p in e){if(!e.hasOwnProperty(p)){continue}var r=d(p,s);r.language=p;if(r.keyword_count+r.r>q.keyword_count+q.r){q=r}if(r.keyword_count+r.r>o.keyword_count+o.r){q=o;o=r}}if(q.language){o.second_best=q}return o}function i(q,p,o){if(p){q=q.replace(/^((<[^>]+>|\\t)+)/gm,function(r,v,u,t){return v.replace(/\\t/g,p)})}if(o){q=q.replace(/\\n/g,"<br>")}return q}function m(r,u,p){var v=h(r,p);var t=a(r);if(t=="no-highlight"){return}var w=t?d(t,v):g(v);t=w.language;var o=c(r);if(o.length){var q=document.createElement("pre");q.innerHTML=w.value;w.value=j(o,c(q),v)}w.value=i(w.value,u,p);var s=r.className;if(!s.match("(\\\\s|^)(language-)?"+t+"(\\\\s|$)")){s=s?(s+" "+t):t}r.innerHTML=w.value;r.className=s;r.result={language:t,kw:w.keyword_count,re:w.r};if(w.second_best){r.second_best={language:w.second_best.language,kw:w.second_best.keyword_count,re:w.second_best.r}}}function n(){if(n.called){return}n.called=true;Array.prototype.map.call(document.getElementsByTagName("pre"),b).filter(Boolean).forEach(function(o){m(o,hljs.tabReplace)})}function k(){window.addEventListener("DOMContentLoaded",n,false);window.addEventListener("load",n,false)}var e={};this.LANGUAGES=e;this.highlight=d;this.highlightAuto=g;this.fixMarkup=i;this.highlightBlock=m;this.initHighlighting=n;this.initHighlightingOnLoad=k;this.IR="[a-zA-Z][a-zA-Z0-9_]*";this.UIR="[a-zA-Z_][a-zA-Z0-9_]*";this.NR="\\\\b\\d+(\\\\.\\\\d+)?";this.CNR="(\\\\b0[xX][a-fA-F0-9]+|(\\\\b\\\\d+(\\\\.\\\\d*)?|\\\\.\\\\d+)([eE][-+]?\\\\d+)?)";this.BNR="\\\\b(0b[01]+)";this.RSR="!|!=|!==|%|%=|&|&&|&=|\\\\*|\\\\*=|\\\\+|\\\\+=|,|\\\\.|-|-=|/|/=|:|;|<|<<|<<=|<=|=|==|===|>|>=|>>|>>=|>>>|>>>=|\\\\?|\\\\[|\\\\{|\\\\(|\\\\^|\\\\^=|\\\\||\\\\|=|\\\\|\\\\||~";this.BE={b:"\\\\\\\\[\\\\s\\\\S]",r:0};this.ASM={cN:"string",b:"'",e:"'",i:"\\\\n",c:[this.BE],r:0};this.QSM={cN:"string",b:'"',e:'"',i:"\\\\n",c:[this.BE],r:0};this.CLCM={cN:"comment",b:"//",e:"$"};this.CBLCLM={cN:"comment",b:"/\\\\*",e:"\\\\*/"};this.HCM={cN:"comment",b:"#",e:"$"};this.NM={cN:"number",b:this.NR,r:0};this.CNM={cN:"number",b:this.CNR,r:0};this.BNM={cN:"number",b:this.BNR,r:0};this.inherit=function(q,r){var o={};for(var p in q){o[p]=q[p]}if(r){for(var p in r){o[p]=r[p]}}return o}}();hljs.LANGUAGES.javascript=function(a){return{k:{keyword:"in if for while finally var new function do return void else break catch instanceof with throw case default try this switch continue typeof delete let yield const",literal:"true false null undefined NaN Infinity"},c:[a.ASM,a.QSM,a.CLCM,a.CBLCLM,a.CNM,{b:"("+a.RSR+"|\\\\b(case|return|throw)\\\\b)\\\\s*",k:"return throw case",c:[a.CLCM,a.CBLCLM,{cN:"regexp",b:"/",e:"/[gim]*",i:"\\\\n",c:[{b:"\\\\\\\\/"}]},{b:"<",e:">;",sL:"xml"}],r:0},{cN:"function",bWK:true,e:"{",k:"function",c:[{cN:"title",b:"[A-Za-z$_][0-9A-Za-z$_]*"},{cN:"params",b:"\\\\(",e:"\\\\)",c:[a.CLCM,a.CBLCLM],i:"[\\"'\\\\(]"}],i:"\\\\[|%"}]}}(hljs);hljs.LANGUAGES.xml=function(a){var c="[A-Za-z0-9\\\\._:-]+";var b={eW:true,c:[{cN:"attribute",b:c,r:0},{b:'="',rB:true,e:'"',c:[{cN:"value",b:'"',eW:true}]},{b:"='",rB:true,e:"'",c:[{cN:"value",b:"'",eW:true}]},{b:"=",c:[{cN:"value",b:"[^\\\\s/>]+"}]}]};return{cI:true,c:[{cN:"pi",b:"<\\\\?",e:"\\\\?>",r:10},{cN:"doctype",b:"<!DOCTYPE",e:">",r:10,c:[{b:"\\\\[",e:"\\\\]"}]},{cN:"comment",b:"<!--",e:"-->",r:10},{cN:"cdata",b:"<\\\\!\\\\[CDATA\\\\[",e:"\\\\]\\\\]>",r:10},{cN:"tag",b:"<style(?=\\\\s|>|$)",e:">",k:{title:"style"},c:[b],starts:{e:"</style>",rE:true,sL:"css"}},{cN:"tag",b:"<script(?=\\\\s|>|$)",e:">",k:{title:"script"},c:[b],starts:{e:"<\\/script>",rE:true,sL:"javascript"}},{b:"<%",e:"%>",sL:"vbscript"},{cN:"tag",b:"</?",e:"/?>",c:[{cN:"title",b:"[^ />]+"},b]}]}}(hljs);
	</script>

	<script>
	  hljs.tabReplace = '    ';
	  hljs.initHighlightingOnLoad();
	</script>

	<script type="text/javascript">
		/*!
		 * Vallenato 1.0
		 * A Simple JQuery Accordion
		 *
		 * Designed by Switchroyale
		 * 
		 * Use Vallenato for whatever you want, enjoy!
		 */

		$(document).ready(function()
		{
			$('.accordion-header').toggleClass('inactive-header');
			
			var contentwidth = $('.accordion-header').width();
			$('.accordion-content').css({'width' : contentwidth });

			$('.accordion-header').click(function () {
				if($(this).is('.inactive-header')) {
					$(this).next().slideToggle().toggleClass('open-content');
				}
				
				else {
					$(this).next().slideToggle().toggleClass('open-content');
				}
			});
			
			return false;
		});
	</script>

<style type="text/css">
		body {
			background: #ebebeb;
			margin: 0;
			padding: 0;
			font-family: Arial, sans-serif;
			color: #666666;
			font-size: 14px;
			line-height: 24px;
		}

		#wrapper {
			width: 980px;
			margin: 20px auto;
		}

		#header {
			padding: 5px 20px;
			background: #333333;
			color: #cccccc;
			position: relative;
			margin: 0 0 20px 0;
		}

		#footer {
			font-size: 11px;
			text-align: center;
		}

		table {
			width:100%;
			border-spacing:0;
			border-collapse:collapse;
			border: 1px solid #cccccc;
			font-family: Arial, sans-serif;
			font-size: 14px;
		}
		
		tr {
			border: 1px solid #cccccc;
		}
		
		td {
			padding:3px;
			border: 1px solid #cccccc;
		}
		
		td.head {
			padding:3px;
			border: 1px solid #cccccc;
			width: 160px;
			background-color:#fafafa;
		}
		
		ul {
			font-family: Arial, sans-serif;
			font-size: 14px;
		}

		a {
			color: #6a9e2e;
			text-decoration: none;
		}

		a.header {
			color: #cccccc;
			text-decoration: none;
		}

		a.header:hover {
			text-decoration: underline;
		}

		a:hover {
			text-decoration: underline;
		}
		
		a.yes {
			color: red;
			text-decoration: none;
		}

		a.yes:hover {
			text-decoration: underline;
		}

		a.warning {
			color: red;
			text-decoration: none;
		}

		a.warning:hover {
			text-decoration: underline;
		}

		a.caution {
			color: #FFBF00;
			text-decoration: none;
		}

		a.caution:hover {
			text-decoration: underline;
		}

		a.untested {
			color: #1C1C1C;
			text-decoration: none;
		}

		a.untested:hover {
			text-decoration: underline;
		}

		.completed {
			color: #6a9e2e;
		}

		.error {
			color: red;
		}

		pre {
			width: 100%;
			white-space: pre-wrap;       /* css-3 */
			white-space: -moz-pre-wrap;  /* Mozilla, since 1999 */
			white-space: -pre-wrap;      /* Opera 4-6 */
			white-space: -o-pre-wrap;    /* Opera 7 */
			word-wrap: break-word;       /* Internet Explorer 5.5+ */
		}

		/* Start Accordion CSS */
		#accordion-container {
			font-size: 13px;
			background: #ffffff;
			padding: 5px 10px 10px 10px;
			border: 1px solid #cccccc;
		}

		.accordion-header {
			font-size: 16px;
			background: #ebebeb;
			margin: 5px 0 0 0;
			padding: 5px 20px;
			border: 1px solid #cccccc;
			cursor: pointer;
			color: #666666;
		}

		.active-header {
			background: #cef98d;
			background-repeat: no-repeat;
			background-position: right 50%;
		}

		.active-header:hover {
			background: #c6f089;
			background-repeat: no-repeat;
			background-position: right 50%;
		}

		.inactive-header {
			background: #ebebeb;
			background-repeat: no-repeat;
			background-position: right 50%;
		}

		.inactive-header:hover {
			background: #f5f5f5;
			background-repeat: no-repeat;
			background-position: right 50%;
		}

		.accordion-content {
			display: none;
			padding: 20px;
			background: #ffffff;
			border: 1px solid #cccccc;
			border-top: 0;
		}
		
		/* End Accordion CSS */

		.content-header {
			font-size: 16px;
			background: #ebebeb;
			margin: 5px 0 0 0;
			padding: 5px 20px;
			border: 1px solid #cccccc;
			color: #666666;
		}

		.content-content {
			font-size: 12px;
			padding: 20px;
			background: #ffffff;
			border: 1px solid #cccccc;
			border-top: 0;
		}
		
		.refer {
			vertical-align: text-bottom;
			font-size: 0.8em;
			position: relative;
			bottom: -0.4em;
			float: right;
		}

		.wrap {
			width: 700px;
			word-wrap: break-word;
		}
		
		/* Start Code Styling CSS */
		/*

		github.com style (c) Vasily Polovnyov <vast@whiteants.net>

		*/

		pre code {
		  display: block; padding: 0.5em;
		  color: #333;
		  background: #f8f8ff
		}

		pre .comment,
		pre .template_comment,
		pre .diff .header,
		pre .javadoc {
		  color: #998;
		  font-style: italic
		}

		pre .keyword,
		pre .css .rule .keyword,
		pre .winutils,
		pre .javascript .title,
		pre .nginx .title,
		pre .subst,
		pre .request,
		pre .status {
		  color: #333;
		  font-weight: bold
		}

		pre .number,
		pre .hexcolor,
		pre .ruby .constant {
		  color: #099;
		}

		pre .string,
		pre .tag .value,
		pre .phpdoc,
		pre .tex .formula {
		  color: #d14
		}

		pre .title,
		pre .id {
		  color: #900;
		  font-weight: bold
		}

		pre .javascript .title,
		pre .lisp .title,
		pre .clojure .title,
		pre .subst {
		  font-weight: normal
		}

		pre .class .title,
		pre .haskell .type,
		pre .vhdl .literal,
		pre .tex .command {
		  color: #458;
		  font-weight: bold
		}

		pre .tag,
		pre .tag .title,
		pre .rules .property,
		pre .django .tag .keyword {
		  color: #000080;
		  font-weight: normal
		}

		pre .attribute,
		pre .variable,
		pre .lisp .body {
		  color: #008080
		}

		pre .regexp {
		  color: #009926
		}

		pre .class {
		  color: #458;
		  font-weight: bold
		}

		pre .symbol,
		pre .ruby .symbol .string,
		pre .lisp .keyword,
		pre .tex .special,
		pre .prompt {
		  color: #990073
		}

		pre .built_in,
		pre .lisp .title,
		pre .clojure .built_in {
		  color: #0086b3
		}

		pre .preprocessor,
		pre .pi,
		pre .doctype,
		pre .shebang,
		pre .cdata {
		  color: #999;
		  font-weight: bold
		}

		pre .deletion {
		  background: #fdd
		}

		pre .addition {
		  background: #dfd
		}

		pre .diff .change {
		  background: #0086b3
		}

		pre .chunk {
		  color: #aaa
		}

		/* End Code Styling CSS */
	</style>

	<title>PageScan - Scan report for #{$url[0].url}</title>
</head>
<body>
REPORT

	i = 0
	$url.each do |site|
		begin
			domain = URI.parse(site.url).host
		rescue
			domain = site.url
		end

		# Header
		if i == 0
			out << "<div id=\"wrapper\">"
			out << "<div id=\"header\">"
			out << "<h2><a class=\"header\" href=\"https://github.com/d3t0n4t0r/pagescan\" target=\"_blank\">PageScan</a></h2>"
			out << "</div>"
		else
			out << "<div id=\"wrapper\">"
			out << "<div id=\"header\"><h2></h2></div>"
		end
		
		# URL Overview
		out << "<div id=\"accordion-container\">"
		out << "<h2 class=\"content-header\">URL Overview</h2>"
		out << "<div class=\"content-content\">"
		out << "<table><tbody><tr>"
		out << "<td class=\"head\">URL</td>"
		out << "<td><div class=\"wrap\">#{site.url}</div> "
		out << "<div class=\"refer\">"
		out << "<a href=\"http://whois.domaintools.com/#{domain}\" target=\"_blank\">whois</a> "
		out << "<a href=\"http://dns.robtex.com/#{domain}.html\" target=\"_blank\">robtex</a> "
		out << "<a href=\"http://www.malwaredomainlist.com/mdl.php?search=#{domain}&colsearch=Domain\" target=\"_blank\">mdl</a> "
		out << "<a href=\"http://support.clean-mx.de/clean-mx/viruses.php?domain=#{domain}\" target=\"_blank\">clean-mx</a> "
		out << "<a href=\"http://urlquery.net/search.php?q=#{domain}&type=string\" target=\"_blank\">urlquery</a>"
		out << "</div></td></tr>"

		ip_i = 0
		site.ip.each do |ip|
			out << (ip_i == 0 ? "<tr><td class=\"head\">IP Address</td>" : "<tr><td class=\"head\"></td>")

			if ip.match(/No\srecord/)
				out << "<td>#{ip}</td></tr>"
			else
				out << "<td>#{ip} "
				out << "<div class=\"refer\">"
				out << "<a href=\"http://whois.domaintools.com/#{ip}\" target=\"_blank\">whois</a> "
				out << "<a href=\"http://ip.robtex.com/#{ip}.html\" target=\"_blank\">robtex</a> "
				out << "<a href=\"http://www.malwaredomainlist.com/mdl.php?search=#{ip}&colsearch=IP\" target=\"_blank\">mdl</a> "
				out << "<a href=\"http://support.clean-mx.de/clean-mx/viruses.php?ip=#{ip}\" target=\"_blank\">clean-mx</a> "
				out << "<a href=\"http://urlquery.net/search.php?q=#{ip}&type=string\" target=\"_blank\">urlquery</a>"
				out << "</div></td></tr>"			
			end

			ip_i += 1
		end

		out << "<tr>"
		out << "<td class=\"head\">Analyzed on</td>"
		out << "<td>#{$time[i]}</td>"
		out << "</tr>"

		if site.code.match(/ERROR/)
			out << "<tr>"
			out << "<td class=\"head\">Status</td>"
			out << "<td><div class=\"error\">Report error - #{site.code.gsub(/ERROR:\s/,'').gsub(/</,'&lt;').gsub(/>/,'&gt;')}</div></td>"
			out << "</tr>"
		else
			out << "<tr>"
			out << "<td class=\"head\">Status</td>"
			out << "<td><div class=\"completed\">Report completed</div></td>"
			out << "</tr><tr>"
			out << "<td class=\"head\">Response Code</td>"
			out << "<td>#{site.code}</td>"
			out << "</tr><tr>"
			out << "<td class=\"head\">Redirect to</td>"
			out << "<td><div class=\"wrap\">#{site.urlredirect}</div></td>"
			out << "</tr>"
		end

		out << "</tbody></table></div>"
		
		# URL Settings
		out << "<h2 class=\"content-header\">URL Settings</h2>"
		out << "<div class=\"content-content\">"
		out << "<table><tbody><tr>"
		out << "<td class=\"head\">User Agent</td>"
		out << "<td><div class=\"wrap\">#{$settings["User-Agent"]}</div></td>"
		out << "</tr><tr>"
		out << "<td class=\"head\">Referer</td>"
		out << "<td><div class=\"wrap\">#{site.referer}</div></td>"
		out << "</tr></tbody></table>"
		out << "</div>"

		# Blacklisting
		out << "<h2 class=\"content-header\">Blacklisting</h2>"
		out << "<div class=\"content-content\">"
		out << "<table><tbody><tr>"
		out << "<td class=\"head\">Google Safebrowsing</td>"
		out << "<td><a class=\"#{site.blist[:google].downcase}\" href=\"http://safebrowsing.clients.google.com/safebrowsing/diagnostic?site=#{site.url}\" target=\"_blank\">#{site.blist[:google]}</a></td>"
		out << "</tr><tr>"
		out << "<td class=\"head\">Norton Safe Web</td>"
		out << "<td><a class=\"#{site.blist[:norton].downcase}\" href=\"http://safeweb.norton.com/report/show?url=#{site.url}\" target=\"_blank\">#{site.blist[:norton]}</a></td>"
		out << "</tr></tbody></table>"
		out << "</div>"

		# Content
		unless site.con.empty? or site.con.nil?
			size_con = 0
			size_con = site.con.strip.length
			out << "<h2 class=\"content-header\">Content</h2>"
			out << "<div class=\"content-content\">"
			out << "<h2 class=\"accordion-header\">HTML Content - (Length: #{size_con})</h2>"
			out << "<div class=\"accordion-content\">"
			out << "<pre><code>#{CGI.escapeHTML(site.con.strip)}</code></pre>"
			out << "</div>"
			out << "</div>"
		end

		# JavaScript
		unless site.js.empty? or site.js.nil?
			out << "<h2 class=\"content-header\">JavaScript</h2>"
			out << "<div class=\"content-content\">"
	
			size_sc = 0
			js_i = 1
			site.js.each do |sc|
				size_sc = sc[1].strip.length

				if sc[0].empty? or sc[0].nil?
					out << "<h2 class=\"accordion-header\">Script ##{js_i} - (Length: #{size_sc})</h2>"
					out << "<div class=\"accordion-content\">"
					out << "<pre><code>#{CGI.escapeHTML(sc[1].strip)}</code></pre>"
					out << "</div>"
				else
					out << "<h2 class=\"accordion-header\">Script ##{js_i} - (Length: #{size_sc}) - #{sc[0]}</h2>"
					out << "<div class=\"accordion-content\">"
					out << "<pre><code>#{CGI.escapeHTML(sc[1].strip)}</code></pre>"
					out << "</div>"
				end

				js_i += 1
			end
		
			out << "</div>"
		end

		# Iframe
		unless site.iframe.empty? or site.iframe.nil?
			out << "<h2 class=\"content-header\">Iframe</h2>"
			out << "<div class=\"content-content\"><ul>"
		
			site.iframe.each do |ifr|
				out << "<li>#{ifr}</li>"
			end

			out << "</ul></div>"
		end

		# LINKS
		unless site.link.empty? or site.link.nil?
			out << "<h2 class=\"content-header\">Links</h2>"
			out << "<div class=\"content-content\"><ul>"
		
			site.link.each do |link|
				out << "<li>#{link}</li>"
			end

			out << "</ul></div>"
		end

		out << "</div></div>"
		i += 1
	end

	out << "<div id=\"wrapper\">"
	out << "<div id=\"footer\">"
	out << "<a href=\"https://github.com/d3t0n4t0r/pagescan\" target=\"_blank\">PageScan 0.2</a> by "
	out << "<a href=\"https://twitter.com/d3t0n4t0r\" target=\"_blank\">@d3t0n4t0r</a>"
	out << "</div>"
	out << "</div>"

	out << "</body></html>"

	fileout = "#{$time[0].day}_#{$time[0].month}_#{$time[0].year}-#{$time[0].hour}_#{$time[0].min}_#{$time[0].sec}-#{URI.parse($url[0].url).host}.html"

	File.open(fileout, 'w') do |f| 
		f.write(out)
	end

	puts "PageScan HTML report has been generated - #{fileout}"
end
