require 'calculated_attributes'

ActiveRecord::Base.establish_connection(adapter: 'sqlite3',
                                        database: "#{File.dirname(__FILE__)}/calculated_attributes.sqlite3")

%w(schema models data).each { |f| load File.dirname(__FILE__) + "/support/#{f}.rb" }
