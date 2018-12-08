#!/bin/env ruby

require 'rubygems'
require 'bundler'

Bundler.require
require 'optparse'
require 'open-uri'
require 'axlsx'

options = {sitemap: 'sitemap.xml', domain: ARGV[0], excel_file: 'sitemap-check-' + ARGV[0] + '.xls'}
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
end.parse!

sitemap = SitemapParser.new(options[:domain] + '/' + options[:sitemap], {recurse: true})
if sitemap.to_a.empty?
  puts "No entries in sitemap found"
end

pages = sitemap.to_a.collect do |url|
  html = Nokogiri::HTML(open(url))
  html.at('meta[name="description"]')
  {
    url: url,
    title: html.at('title')&.inner_text,
    description: html.at('meta[name="description"]')&.[]('content')&.strip,
    h1: html.css('h1')&.first&.inner_text&.to_s&.strip
  }
end

Axlsx::Package.new do |p|
  p.workbook.add_worksheet(:name => "Sitemap urls") do |sheet|
    sheet.add_row %w(url title description h1)
    pages.each do |page|
      sheet.add_row [ page[:url], page[:title], page[:description], page[:h1] ]
    end
  end
  p.serialize(options[:excel_file])
end
