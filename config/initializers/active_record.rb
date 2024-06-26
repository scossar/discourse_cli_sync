# frozen_string_literal: true

require 'active_record'
require 'yaml'

db_config = YAML.load_file('config/database.yml')
ActiveRecord::Base.establish_connection(db_config['development'])
