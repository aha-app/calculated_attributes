require "calculated_attributes/version"
require "active_record"

ActiveRecord::Base.extend Module.new {
  def calculated(*args)
    @config ||= Config.new
    @config.calculated(args.first, args.last) if args.size == 2
    @config
  end
  
  class Config
    def calculated(title=nil, lambda=nil)
      @calculations ||= {}
      @calculations[title] ||= lambda if title and lambda
      @calculations
    end
  end
}

ActiveRecord::Base.send(:include, Module.new {
  def calculated(title)
    self.class.scoped.calculated(title).find(self.id)
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