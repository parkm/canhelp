require 'net/http'
require 'pry'
require 'json'
require 'faraday'

module Canhelp
  def get_token
    File.open('.token').read
  end

  def get_request(token, url)
    conn = Faraday.new(url)
    conn.authorization :Bearer, token
    conn.get
  end

  def get_json(token, url)
    JSON.parse(get_request(token, url).body)
  end

  def get_next_link(link_headers)
    return unless link_headers
    next_link = link_headers.split(',').find { |link| link.include?('rel="next"') }
    next_link && next_link.slice(/\<(?<url>.+)\>/, 'url')
  end

  def get_all_pages(token, url, data = [])
    response = get_request(token, url)
    raise "Unsuccessful Response #{response.body}" unless response.success?

    body = JSON.parse(response.body)
    data += body.is_a?(Array) ? body : [body]
    next_page = get_next_link(response.headers['link'])
    if (next_page)
      get_all_pages(token, next_page, data)
    else
      data
    end
  end

  def get_json_paginated(token, url, parameters='')
    all_items = []
    page = 1
    while (!(items_on_page = get_json(token, "#{url}?recursive=true&per_page=100&page=#{page}&#{parameters}")).empty?)
      all_items += items_on_page
      page += 1
    end
    return all_items
  end

  def get_link_headers(token, url, parameters='')
    all_items = []
    items = get_json(
      token,
      "#{url}?#{parameters}"
    )
    #.map {|u| u['context_type']}
    all_items << items
  end

  def canvas_post(url, token, json_body)
    uri = URI(url)

    headers = {
      'Content-Type' => 'application/json',
      'Authorization' => "Bearer #{token}"
    }

    req = Net::HTTP::Post.new(uri.path, headers)
    req.body = json_body.to_json

    execute_http_request(uri, req)
  end

  def canvas_put(url, token, json_body)
    uri = URI(url)
    req = Net::HTTP::Put.new(uri)
    req['Content-Type'] = 'application/json'
    req['Authorization'] = "Bearer #{token}"
    req.body = json_body.to_json

    execute_http_request(uri, req)
  end

  def canvas_delete(url, token, json_body)
    uri = URI(url)
    req = Net::HTTP::Delete.new(uri)
    req['Content-Type'] = 'application/json'
    req['Authorization'] = "Bearer #{token}"
    req.body = json_body.to_json

    execute_http_request(uri, req)
  end

  def execute_http_request(uri, request)
    http = Net::HTTP.new(uri.hostname, uri.port)
    http.use_ssl = true
    http.request(request)
  end

  def prompt(value)
    puts "Enter a #{value.to_s}"
    print "> "
    $stdin.gets.chomp ""
  end

end
