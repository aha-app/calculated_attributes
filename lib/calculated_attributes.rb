require 'calculated_attributes/version'
require 'active_record'

# Include patches.
require 'calculated_attributes/rails_patches'
require 'calculated_attributes/arel_patches'
raise "Unsupported ActiveRecord version: #{ActiveRecord::VERSION::MAJOR}" unless [3, 4, 5, 6].include? ActiveRecord::VERSION::MAJOR

# Rails 5.2 has its own patches which are different from 5.0. In every other
# case, just require the patch file for the major version.
versions = Gem::Version.new(ActiveRecord::VERSION::STRING).canonical_segments.take(2)
if versions == [5, 2] || versions == [5, 1]
  require 'calculated_attributes/rails_5_2_patches'
else
  require "calculated_attributes/rails_#{ActiveRecord::VERSION::MAJOR}_patches"
end

# Include model code.
require 'calculated_attributes/model_methods'
