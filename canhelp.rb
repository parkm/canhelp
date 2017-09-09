#!/usr/bin/env ruby
require 'optparse'
Dir["./plugins/*.rb"].each {|file| require file }

options = {}
OptionParser.new do |opt|
  opt.banner += ' [plugin name]'
  #opt.on('--test TEST') { |o| options[:test] = o }
  if !opt.default_argv.empty?
    options[:plugin] = opt.default_argv[0]
  end
  options[:default_argv] = opt.default_argv
end.parse!

include CanhelpPlugin
if options[:plugin]
  args = options[:default_argv].slice(1, options[:default_argv].count)
  CanhelpPlugin.send(options[:plugin], *args)
end

puts options
