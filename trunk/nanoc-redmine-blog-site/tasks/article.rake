desc 'Create new article file.'

task :create_article do
  require 'yaml'

  name = ENV['name'].dup
  raise 'usage: rake create_item name="article_name"' if name.to_s == ''
  raise 'name must not include slash.' if name =~ /\//

  name.gsub!(/ /, '-')

  yaml_name = "content/articles/#{name}.yaml"
  raise 'article already exists.' if File.exist?(yaml_name)

  system "nanoc3 create_item 'articles/#{name}'"

  h = YAML.load_file(yaml_name)
  h['title'] = name
  h['tags'] = []
  h['created_at'] = Time.now.to_s
  h['kind'] = 'article'
  
  File.open(yaml_name, "w") do |io|
    YAML.dump(h, io)
  end
end
