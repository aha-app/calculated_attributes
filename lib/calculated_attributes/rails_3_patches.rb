module ActiveRecord
  module AttributeMethods
    module ClassMethods
      # Generates all the attribute related methods for columns in the database
      # accessors, mutators and query methods.
      def define_attribute_methods
        unless defined?(@attribute_methods_mutex)
          msg = 'It looks like something (probably a gem/plugin) is overriding the ' \
                'ActiveRecord::Base.inherited method. It is important that this hook executes so ' \
                'that your models are set up correctly. A workaround has been added to stop this ' \
                'causing an error in 3.2, but future versions will simply not work if the hook is ' \
                'overridden. If you are using Kaminari, please upgrade as it is known to have had ' \
                "this problem.\n\n"
          msg << 'The following may help track down the problem:'

          meth = method(:inherited)
          if meth.respond_to?(:source_location)
            msg << " #{meth.source_location.inspect}"
          else
            msg << " #{meth.inspect}"
          end
          msg << "\n\n"

          ActiveSupport::Deprecation.warn(msg)

          @attribute_methods_mutex = Mutex.new
        end

        # Use a mutex; we don't want two thread simaltaneously trying to define
        # attribute methods.
        @attribute_methods_mutex.synchronize do
          return if attribute_methods_generated?
          superclass.define_attribute_methods unless self == base_class
          columns_to_define =
            if defined?(calculated) && calculated.instance_variable_get('@calculations')
              calculated_keys = calculated.instance_variable_get('@calculations').keys
              column_names.reject { |c| calculated_keys.include? c.intern }
            else
              column_names
            end
          super(columns_to_define)
          columns_to_define.each { |name| define_external_attribute_method(name) }
          @attribute_methods_generated = true
        end
      end
    end
  end
end
