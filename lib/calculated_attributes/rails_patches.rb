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
