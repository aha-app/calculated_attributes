require 'calculated_attributes/version'
require 'active_record'

# Include patches.
require 'calculated_attributes/rails_patches'
require 'calculated_attributes/arel_patches'

raise "Unsupported ActiveRecord version: #{ActiveRecord::VERSION::MAJOR}" unless [6, 7].include? ActiveRecord::VERSION::MAJOR

require "calculated_attributes/rails_#{ActiveRecord::VERSION::MAJOR}_patches"

# Include model code.
require 'calculated_attributes/model_methods'
