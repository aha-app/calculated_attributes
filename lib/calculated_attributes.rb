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
      Rails.logger.warn("Using calculated value without including it in the relation: #{sym}") if defined? Rails
      self.class.scoped.calculated(sym).find(self.id).send(sym)
    else
      super(sym, *args, &block)
    end
  end
})

ActiveRecord::Relation.send(:include, Module.new {
  def calculated(*args)
    projections = self.arel.projections
    args.each do |arg|
      sql = self.klass.calculated.calculated[arg].call
      if sql.is_a? String
        projections.push Arel.sql("(#{sql})").as(arg.to_s)
      else
        projections.push sql.as(arg.to_s)
      end
    end
    self.select(projections)
  end
})

Arel::SelectManager.send(:include, Module.new {
  def projections
    @ctx.projections
  end
})