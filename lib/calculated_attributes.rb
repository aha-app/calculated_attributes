require "calculated_attributes/version"
require "active_record"

module CalculatedAttributes
  def calculated(*args)
    @config ||= CalculatedAttributes::Config.new
    @config.calculated(args.first, args.last) if args.size == 2
    @config
  end
  
  class CalculatedAttributes::Config
    def calculated(title=nil, lambda=nil)
      @calculations ||= {}
      @calculations[title] ||= lambda if title and lambda
      @calculations
    end
  end
end
ActiveRecord::Base.extend CalculatedAttributes

ActiveRecord::Base.send(:include, Module.new {
  def calculated(*args)
    self.class.scoped.calculated(*args).find(self.id)
  end
})

ActiveRecord::Relation.send(:include, Module.new {
  def calculated(*args)
    selection = [self.klass.arel_table[Arel.star]]
    args.each do |arg|
      selection.push "(#{self.klass.calculated.calculated[arg].call}) as #{arg.to_s}"
    end
    self.klass.select(selection)
  end
})