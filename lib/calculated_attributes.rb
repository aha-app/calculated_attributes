require "calculated_attributes/version"
require "active_record"
require 'byebug'

ActiveRecord::Base.extend Module.new {
  def calculated(*args)
    @calculations ||= {}
    case args.size
    when 1
      @calculations[args.first]
    when 2
      @calculations[args.first] ||= args.last
      @calculations
    else
      raise ArgumentError.new("wrong number of arguments (#{args.size} for 1..2)")
    end
  end
}

ActiveRecord::Relation.send(:include, Module.new {
  def calculated(*args)
    args.each do |arg|
      # select()
    end
    byebug
  end
})
