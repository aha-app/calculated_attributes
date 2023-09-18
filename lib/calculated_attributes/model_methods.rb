module CalculatedAttributes
  def calculated(*args, &block)
    @config ||= CalculatedAttributes::Config.new
    if block
      @config.calculated(args.first, options: args[1], &block)
    elsif args.size == 2
      @config.calculated(args.first, args.last)
    elsif args.size == 3
      @config.calculated(args.first, args.last, options: args[1])
    end
    @config
  end

  class CalculatedAttributes
    class Callable
      def initialize(lambda, options = {})
        @lambda = lambda
        @options = options
      end

      attr_reader :options

      def call(*args)
        @lambda.call(*args)
      end
    end

    class Config
      def calculated(title = nil, lambda = nil, options: {}, &block)
        lambda = block if block_given? && !lambda

        @calculations ||= {}
        @calculations[title] ||= Callable.new(lambda, options) if title && lambda
        @calculations
      end
    end
  end
end
ActiveRecord::Base.extend CalculatedAttributes

module ActiveRecord
  class Base
    def calculated(*args)
      if self.class.respond_to? :scoped
        self.class.scoped.calculated(*args).find(id)
      else
        self.class.all.calculated(*args).find(id)
      end
    end

    def method_missing(sym, *args)
      no_sym_in_attr =
        if @attributes.respond_to? :include?
          !@attributes.include?(sym.to_s)
        else
          !@attributes.key?(sym.to_s)
        end
      if no_sym_in_attr && (self.class.calculated.calculated[sym] || self.class.base_class.calculated.calculated[sym])
        Rails.logger.warn("Using calculated value without including it in the relation: #{sym}") if defined? Rails
        class_with_attr =
          if self.class.calculated.calculated[sym]
            self.class
          else
            self.class.base_class
          end
        if class_with_attr.respond_to? :scoped
          class_with_attr.scoped.calculated(sym => args).find(id).send(sym)
        else
          class_with_attr.all.calculated(sym => args).find(id).send(sym)
        end
      else
        super
      end
    end

    def respond_to_missing?(method, include_private = false)
      no_sym_in_attr =
        if @attributes.respond_to? :include?
          !@attributes.include?(method.to_s)
        elsif @attributes.respond_to? :key?
          !@attributes.key?(method.to_s)
        else
          true
        end
      super || (no_sym_in_attr && (self.class.calculated.calculated[method] || self.class.base_class.calculated.calculated[method]))
    end
  end
end

module ActiveRecord
  class Relation
    def calculated(*args)
      projections = arel.projections
      args = args.flat_map do |arg|
        case arg
        when Symbol then [[arg, []]]
        when Hash then arg.to_a
        end
      end

      callables = []
      args.each do |attribute, arguments|
        callable = klass.calculated.calculated[attribute] || klass.base_class.calculated.calculated[attribute]
        sql = callable.call(*arguments)
        sql = klass.send(:sanitize_sql, *sql) if sql.is_a?(Array)
        new_projection =
          if sql.is_a?(String)
            Arel.sql("(#{sql})").as(attribute.to_s)
          elsif sql.respond_to? :to_sql
            Arel.sql("(#{sql.to_sql})").as(attribute.to_s)
          else
            sql.as(attribute.to_s)
          end
        new_projection.calculated_attr!
        projections.push new_projection
        callables.push(callable)
      end
      callables.inject(self) do |self1, callable|
        (callable.options[:requires_scopes] || []).inject(self1) do |self2, scope|
          self2.send(scope)
        end
      end.select(projections)
    end
  end
end
