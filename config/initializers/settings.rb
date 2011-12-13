require 'yaml'

SETTINGS = YAML::load(IO.read("#{::Rails.root.to_s}/config/settings.yml"))
