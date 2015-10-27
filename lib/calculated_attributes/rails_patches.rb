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
  module AttributeMethods
    module Write
      # Updates the attribute identified by <tt>attr_name</tt> with the specified +value+. Empty strings
      # for fixnum and float columns are turned into +nil+.
      def write_attribute(attr_name, value)
        if ActiveRecord::VERSION::MAJOR == 4 && ActiveRecord::VERSION::MINOR == 2
          write_attribute_with_type_cast(attr_name, value, true)
        else
          attr_name = attr_name.to_s
          attr_name = self.class.primary_key if attr_name == 'id' && self.class.primary_key
          @attributes_cache.delete(attr_name)
          column = column_for_attribute(attr_name)

          @attributes[attr_name] = type_cast_attribute_for_write(column, value)
        end
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
