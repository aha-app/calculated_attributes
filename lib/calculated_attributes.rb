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
    projections = arel.projections
    args.each do |arg|
      sql = klass.calculated.calculated[arg].call
      if sql.is_a? String
        new_projection = Arel.sql("(#{sql})").as(arg.to_s)
        new_projection.is_calculated_attr!
        projections.push new_projection
      else
        new_projection = sql.as(arg.to_s)
        new_projection.is_calculated_attr!
        projections.push new_projection
      end
    end
    select(projections)
  end
})

Arel::SelectManager.send(:include, Module.new {
  def projections
    @ctx.projections
  end
})

module ActiveRecord
  module FinderMethods
    def find_with_associations
      join_dependency = construct_join_dependency_for_association_find
      relation = construct_relation_for_association_find(join_dependency, arel.projections.select{ |p| p.is_a?(Arel::Nodes::Node) and p.is_calculated_attr? })
      rows = connection.select_all(relation, 'SQL', relation.bind_values.dup)
      join_dependency.instantiate(rows)
    rescue ThrowResult
      []
    end
    
    def construct_join_dependency_for_association_find
      including = (@eager_load_values + @includes_values).uniq
      ActiveRecord::Associations::JoinDependency.new(@klass, including, [])
    end
    
    def construct_relation_for_association_find(join_dependency, calculated_columns)
      relation = except(:includes, :eager_load, :preload, :select).select(join_dependency.columns.concat(calculated_columns))
      apply_join_dependency(relation, join_dependency)
    end
  end
end

class Arel::Nodes::Node
  def initialize(left, right = nil)
    @is_calculated_attr = false
    super(left, right)
  end
  
  def is_calculated_attr!
    @is_calculated_attr = true
  end
  
  def is_calculated_attr?
    @is_calculated_attr
  end
end