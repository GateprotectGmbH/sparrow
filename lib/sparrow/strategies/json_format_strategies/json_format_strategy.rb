module Sparrow
  module Strategies
    ##
    # Superclass for all JSON format strategies.
    # Contains no own instance logic, but keeps track of the registration
    # of all JSON format strategies with its Singleton class methods.
    # @abstract Not exactly a abstract class but contains no own logic but
    #   singleton class methods
    class JsonFormatStrategy
      ##
      # Empty constructor. Does nothing.
      def initialize(*_args)
      end

      ##
      # Register a new JSON Format strategy
      # @param [Object] args the arguments for the new strategy
      # @return [Array] args the updated registered JSON Format strategies
      #   available
      def self.register_json_format(*args)
        init(args)
        @@json_format_strategies << self.new(args)
      end

      ##
      # Start a JSON conversion by its given string
      # @param [Object] body a JSON object representation.
      #  can be any type a JSON format strategy is registered,
      #  i.e. an Array, a String or a RackBody
      # @return [String] the formatted JSON
      def self.convert(body)
        strategy = json_format_strategies.detect do |strategy_candidate|
          strategy_candidate.match?(body)
        end
        strategy.convert(body)
      end

      def self.init(*args)
        @@json_format_strategies ||= Array.new(args)
      end
      private_class_method :init

      def self.json_format_strategies
        init
        default = Sparrow::Strategies::DefaultJsonFormatStrategy.instance
        @@json_format_strategies.reject(&:blank?) + [default]
      end
      private_class_method :json_format_strategies
    end
  end
end
