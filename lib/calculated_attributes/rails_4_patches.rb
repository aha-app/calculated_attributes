module ActiveRecord
  module AttributeMethods
    module ClassMethods
      # Generates all the attribute related methods for columns in the database
      # accessors, mutators and query methods.
      def define_attribute_methods
        return false if @attribute_methods_generated
        # Use a mutex; we don't want two threads simultaneously trying to define
        # attribute methods.
        generated_attribute_methods.synchronize do
          return false if @attribute_methods_generated
          superclass.define_attribute_methods unless self == base_class
          columns_to_define =
            if defined?(calculated) && calculated.instance_variable_get('@calculations')
              calculated_keys = calculated.instance_variable_get('@calculations').keys
              column_names.reject { |c| calculated_keys.include? c.intern }
            else
              column_names
            end
          super(columns_to_define)
          @attribute_methods_generated = true
        end
        true
      end
    end
  end
end
