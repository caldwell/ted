#!/usr/bin/env ruby

require 'nokogiri'
require 'httparty'
require 'docopt'
require 'json'

begin
  opt = Docopt::docopt(<<-USAGE)
Usage: $0 [options]

--help         Show this.
-v --verbose   Print more text.
-o FILE        Specify output file [default: ./test.txt].
-h <ted-host>  TED6000 host [default: ted].
-s <seconds>   Number of seconds to average [default: 10]
  USAGE
rescue Docopt::Exit => e
  raise e.message
end

class Array
  def sum
    reduce(0.0) { |result, el| result + el }
  end

  def mean
    sum / size
  end
end

require 'pp'

url = "http://#{opt['-h']}/history/export.xml?T=1&D=0&M=1&C=#{opt['-s']}"
warn "GET #{url}" if opt['--verbose']
response = HTTParty.get(url)

raise response.message unless response.code == 200

doc = Nokogiri::XML(response.body)

puts({
  power: doc.xpath('//POWER/text()').map {|t| t.to_s.to_f}.mean,
  voltage: doc.xpath('//VOLTAGE/text()').map {|t| t.to_s.to_f}.mean,
  mtu: 'mains',
}.to_json)
