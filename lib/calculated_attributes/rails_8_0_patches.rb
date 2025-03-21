module ActiveRecord
  module AttributeMethods
    module ClassMethods
      # Generates all the attribute related methods for columns in the database
      # accessors, mutators and query methods.
      def define_attribute_methods # :nodoc:
        return false if @attribute_methods_generated
        # Use a mutex; we don't want two threads simultaneously trying to define
        # attribute methods.
        GeneratedAttributeMethods::LOCK.synchronize do
          return false if @attribute_methods_generated
          superclass.define_attribute_methods unless base_class?
          columns_to_define =
            if defined?(calculated) && calculated.instance_variable_get('@calculations')
              calculated_keys = calculated.instance_variable_get('@calculations').keys
              attribute_names.reject { |c| calculated_keys.include? c.intern }
            else
              attribute_names
            end
          super(columns_to_define)
          @attribute_methods_generated = true
          @attribute_methods_generated = true
        end
      end
    end
  end

  module Associations
    class JoinDependency
      attr_writer :calculated_columns

      def instantiate(result_set, strict_loading_value, &block)
        primary_key = aliases.column_alias(join_root, join_root.primary_key)

        seen = Hash.new { |i, object_id|
          i[object_id] = Hash.new { |j, child_class|
            j[child_class] = {}
          }
        }

        model_cache = Hash.new { |h, klass| h[klass] = {} }
        parents = model_cache[join_root]
        column_aliases = aliases.column_aliases join_root

        message_bus = ActiveSupport::Notifications.instrumenter

        payload = {
          record_count: result_set.length,
          class_name: join_root.base_klass.name
        }

        message_bus.instrument("instantiation.active_record", payload) do
          result_set.each { |row_hash|
            parent_key = primary_key ? row_hash[primary_key] : row_hash
            parent = parents[parent_key] ||= join_root.instantiate(row_hash, column_aliases, &block)
            @calculated_columns.each { |column| parent[column.right] = model[column.right] } if @calculated_columns
            construct(parent, join_root, row_hash, seen, model_cache, strict_loading_value)
          }
        end

        parents.values
      end
    end
  end
end
