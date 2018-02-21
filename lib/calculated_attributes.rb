require 'calculated_attributes/version'
require 'active_record'

# Include patches.
require 'calculated_attributes/rails_patches'
require 'calculated_attributes/arel_patches'
raise "Unsupported ActiveRecord version: #{ActiveRecord::VERSION::MAJOR}" unless [3, 4, 5].include? ActiveRecord::VERSION::MAJOR

if Gem::Version.new(ActiveRecord::VERSION::STRING) <= Gem::Version.new('5.1.4')
  require "calculated_attributes/rails_#{ActiveRecord::VERSION::MAJOR}_patches"
else
  require 'calculated_attributes/rails_5_2_patches'
end

# Include model code.
require 'calculated_attributes/model_methods'
