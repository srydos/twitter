#!/usr/bin/env ruby
require 'mysql'
require 'yaml'
class DBConnector
  @dbuser_hash = YAML.load_file( WORK_DIR + './config/dbuser.yml' )
  @user = @dbuser_hash["user"]
  @pass = @dbuser_hash["pass"]
end
