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
  
  def method_missing(sym, *args, &block)
    if !@attributes.include?(sym.to_s) and self.class.calculated.calculated[sym]
      self.class.scoped.calculated(sym).find(self.id).send(sym)
    else
      super(sym, *args, &block)
    end
  end
})

ActiveRecord::Relation.send(:include, Module.new {
  def calculated(*args)
    selection = [self.klass.arel_table[Arel.star]]
    args.each do |arg|
      sql = self.klass.calculated.calculated[arg].call
      sql = sql.to_sql unless sql.is_a? String
      selection.push "(#{sql}) as #{arg.to_s}"
    end
    self.klass.select(selection)
  end
})