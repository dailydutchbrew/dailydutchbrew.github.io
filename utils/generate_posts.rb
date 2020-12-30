# frozen_string_literal: true

require 'yaml'

posts = YAML.load_file('post_data.yml')

posts.each do |post|
  path = '../_posts/'
  file_name = path + post['date'] + '-' + post['title'].split.join('-') + '.md'
  puts post['date']
  puts file_name.inspect
  next if File.exist?(file_name)

  post_string = <<~POST
    ---
    layout: post
    title: #{post['title']}
    date: #{post['date']}
    ---

    <div>
      #{post['iframe']}
    </div>
  POST

  File.write(file_name, post_string)
end
