#!/bin/env ruby

require 'rubygems'
require 'bundler'
require 'pp'

Bundler.require
require 'optparse'
require 'open-uri'
require 'axlsx'

options = {sitemap: 'sitemap.xml', domain: ARGV[0], excel_file: "sitemap-check-#{ARGV[0]}-#{Date.today.to_s}.xls"}
if ! options[:domain].match(/^http/)
  options[:domain] = 'https://' + options[:domain]
end

OptionParser.new do |opts|
  opts.banner = "Usage: #{File.basename(__FILE__)} [options]"

  opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
    options[:verbose] = v
  end
  opts.on('-s', '--sitemap', "Sitemap.xml path") do |s|
    options[:sitemap] = s
  end
  opts.on('-e', '--excel', 'Excel file to output') do |e|
    options[:excel_file] = e
  end
  opts.on('-c', '--count-css', 'CSS filters that you want counted. Separate with , commas') do |c|
    options[:count_css] = ARGV.first.split(',').map(&:strip)
  end
end.parse!

puts "Reading sitemap"
sitemap = SitemapParser.new(options[:domain] + '/' + options[:sitemap], {recurse: true})
if sitemap.to_a.empty?
  puts "No entries in sitemap found"
end

urls = sitemap.urls.collect{ |url| url.at('loc').inner_text.strip }
puts "Reading #{urls.size} urls"
pages = urls.collect do |url|
  putc '.'
  begin
    opened_url = open(url, {"User-Agent" => "Sitemap-SEO-Checker-Bot",})
  rescue OpenURI::HTTPError => ex
    puts "#{url} #{ex.message}"
    next({ url: url, title: ex.message })
  end
  html = Nokogiri::HTML(opened_url)
  count_css = options.fetch(:count_css, []).collect { |c| html.css(c).count }

  {
    url: url,
    title: html.at('title')&.inner_text,
    description: html.at('meta[name="description"]')&.[]('content')&.strip,
    h1: html.css('h1')&.first&.inner_text&.to_s&.strip,
    count_css: count_css
  }
end

Axlsx::Package.new do |p|
  p.workbook.add_worksheet(:name => "Sitemap urls") do |sheet|
    sheet.add_row %w(url title description h1) + options.fetch(:count_css, [])
    pages.each do |page|
      sheet.add_row [ page.fetch(:url, ''), page.fetch(:title, ''), page.fetch(:description, ''), page.fetch(:h1, '')] + page.fetch(:count_css, [])
    end
  end
  p.serialize(options[:excel_file])
end
