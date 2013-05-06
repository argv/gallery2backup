#!/usr/bin/env ruby

if ARGV.empty?
	puts "naaaaaaah"
	exit
end

require 'nokogiri'
require 'open-uri'
require 'openssl'
require 'fileutils'
require 'cgi'

def http_get(uri = '')
	Nokogiri::HTML(open("#{ARGV.first}#{uri}", :ssl_verify_mode => OpenSSL::SSL::VERIFY_NONE))
end

def slug(t)
	t = t.strip
	t = t.downcase.gsub(' ', '-')
	t = CGI.escape(t)
	t = t.gsub('%E2%82%AC', 'euro')
	t = t.gsub('%C3%84', 'ae')
	t = t.gsub('%C3%A4', 'ae')
	t = t.gsub('%C3%96', 'oe')
	t = t.gsub('%C3%B6', 'oe')
	t = t.gsub('%C3%9C', 'ue')
	t = t.gsub('%C3%BC', 'ue')
	t = t.gsub('%C3%9F', 'ss')
	t = t.gsub('%C3%A8', 'e')
	t = t.gsub('%C3%A9', 'e')
	t = t.gsub('%C3%A0', 'a')
	t = t.gsub('%C3%A1', 'a')
	t = t.gsub('%25', '-prozent-')
	t = t.gsub('%26', '-und-')
	t = t.gsub('%40', '-at-')
	t = t.gsub('@', '-at-')
	t = CGI.unescape(t)
	t = t.gsub(/[^a-z0-9]+/i, '-')
	t = t.gsub(/[\-]+/, '-')
	t = t.gsub(/^\-/, '')
	t = t.gsub(/\-$/, '')
	t
end

http_get("/main.php").root.css('img.giThumbnail').each do |item|
	album = { :id => item.parent.attributes['href'].value.split('=', 2).last.to_i, :name => item.attribute('alt').value, :sets => [] }

	page = 1

	begin
		puts "getting album #{slug(album[:name])} page #{page}"

		set = http_get("/main.php?g2_itemId=#{album[:id]}&g2_page=#{page}").root.css('img.giThumbnail').collect do |item|
			id = item.parent.attributes['href'].value.split('=', 2).last.to_i
			name = item.attribute('alt').value
			url = "#{ARGV.first}/main.php?g2_view=core.DownloadItem&g2_itemId=#{id}&g2_serialNumber=4"

			puts "  getting #{slug(name)} from #{url}"

			leech = open(url, :ssl_verify_mode => OpenSSL::SSL::VERIFY_NONE)
			FileUtils.mkdir_p("./albums/#{slug(album[:name])}")
			File.open("./albums/#{slug(album[:name])}/#{slug(name)}_#{id}.jpg", 'wb') {|it| it.write(leech.read) }
			
			{ :id => id, :name => name, :page => page }
		end rescue []

		album[:sets] += set unless set.empty?
		page += 1
	end until set.empty?
end

=begin
g2_page=2
/main.php?g2_itemId=22568
-> <a href="main.php?g2_itemId=22569">
-> <img src="main.php?g2_view=core.DownloadItem&amp;g2_itemId=22570&amp;g2_serialNumber=4" width="150" height="150" id="IFid2" class="ImageFrame_none giThumbnail" alt="Alexandra ..."/>
-> </a>
-->
Vollgröße:
<a href="main.php?g2_itemId=22569&amp;g2_imageViewsIndex=1">
1600x1200

--> /main.php?g2_itemId=22569
--> <img src="main.php?g2_view=core.DownloadItem&amp;g2_itemId=20851&amp;g2_serialNumber=4" width="150" height="113" id="IFid1" class="ImageFrame_none" alt="CIMG0276.jpg"/>
--> /main.php?g2_view=core.DownloadItem&g2_itemId=22571&g2_serialNumber=4


title = doc.root.css('p.giTitle').collect do |it|
	it.inner_text.strip
end

id = doc.root.css('div.summary-keyalbum').collect do |it|
  it.css('a').last.inner_text
end

pp title
pp id

p title.length
p id.length

=end
