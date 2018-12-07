#!/bin/env ruby

require 'rubygems'
require 'bundler'

Bundler.require
require 'optparse'

options = {sitemap: 'sitemap.xml'}
OptionParser.new do |opts|
  opts.banner = "Usage: #{File.basename(__FILE__)} [options]"

  opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
    options[:verbose] = v
  end
  opts.on('-s', '--sitemap', "Sitemap.xml path") do |s|
    options[:sitemap] = s
  end
end.parse!

options[:domain] = ARGV[0]
if ! options[:domain].match(/^http/)
  options[:domain] = 'https://' + options[:domain]
end

p options

sitemap = SitemapParser.new(options[:domain] + '/' + options[:sitemap], {recurse: true})
p sitemap.urls

