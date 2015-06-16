require 'calculated_attributes/version'
require 'active_record'

module CalculatedAttributes
  def calculated(*args)
    @config ||= CalculatedAttributes::Config.new
    @config.calculated(args.first, args.last) if args.size == 2
    @config
  end

  class CalculatedAttributes
    class Config
      def calculated(title = nil, lambda = nil)
        @calculations ||= {}
        @calculations[title] ||= lambda if title && lambda
        @calculations
      end
    end
  end
end
ActiveRecord::Base.extend CalculatedAttributes

ActiveRecord::Base.send(:include, Module.new do
  def calculated(*args)
    self.class.scoped.calculated(*args).find(id)
  end

  def method_missing(sym, *args, &block)
    if !@attributes.include?(sym.to_s) && (self.class.calculated.calculated[sym] || self.class.base_class.calculated.calculated[sym])
      Rails.logger.warn("Using calculated value without including it in the relation: #{sym}") if defined? Rails
      class_with_attr =
        if self.class.calculated.calculated[sym]
          self.class
        else
          self.class.base_class
        end
      class_with_attr.scoped.calculated(sym).find(id).send(sym)
    else
      super(sym, *args, &block)
    end
  end

  def respond_to?(method, include_private = false)
    super || (!@attributes.include?(method.to_s) && (self.class.calculated.calculated[method] || self.class.base_class.calculated.calculated[method]))
  end
end)

ActiveRecord::Relation.send(:include, Module.new do
  def calculated(*args)
    projections = arel.projections
    args.each do |arg|
      lam = klass.calculated.calculated[arg] || klass.base_class.calculated.calculated[arg]
      sql = lam.call
      if sql.is_a? String
        new_projection = Arel.sql("(#{sql})").as(arg.to_s)
        new_projection.calculated_attr!
        projections.push new_projection
      else
        new_projection = sql.as(arg.to_s)
        new_projection.calculated_attr!
        projections.push new_projection
      end
    end
    select(projections)
  end
end)

Arel::SelectManager.send(:include, Module.new do
  def projections
    @ctx.projections
  end
end)

module ActiveRecord
  module FinderMethods
    def construct_relation_for_association_find(join_dependency)
      calculated_columns = arel.projections.select { |p| p.is_a?(Arel::Nodes::Node) && p.calculated_attr? }
      relation = except(:includes, :eager_load, :preload, :select).select(join_dependency.columns.concat(calculated_columns))
      join_dependency.calculated_columns = calculated_columns
      apply_join_dependency(relation, join_dependency)
    end
  end
end

module ActiveRecord
  module Associations
    class JoinDependency
      attr_writer :calculated_columns

      def instantiate(rows)
        primary_key = join_base.aliased_primary_key
        parents = {}

        records = rows.map do |model|
          primary_id = model[primary_key]
          parent = parents[primary_id] ||= join_base.instantiate(model)
          construct(parent, @associations, join_associations, model)
          @calculated_columns.each { |column| parent[column.right] = model[column.right] }
          parent
        end.uniq

        remove_duplicate_results!(active_record, records, @associations)
        records
      end
    end
  end
end

module Arel
  module Nodes
    class Node
      def calculated_attr!
        @is_calculated_attr = true
      end

      def calculated_attr?
        @is_calculated_attr
      end
    end
  end
end
