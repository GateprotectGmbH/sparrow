require 'active_support/core_ext/object/blank'
require 'sparrow/strategies/form_hash'
require 'sparrow/strategies/raw_input'
require 'sparrow/strategies/ignore'

module Sparrow
  class Middleware
    attr_reader :app, :body, :status, :headers

    def initialize(app)
      @app = app
    end

    def call(env)
      @last_env                = env
      @status, @headers, @body = @app.call(convert(env))
    end

    def convert(env)
      env
    end

    private

    def strategy
      if is_processable?
        Rails.logger.debug 'Choosing strategy RawInput' if defined? Rails
        Strategies::RawInput
      else
        Rails.logger.debug 'Choosing strategy Ignore' if defined? Rails
        Strategies::Ignore
      end
    end

    def is_processable?
      accepted_content_type? && accepted_accept_header? && includes_route?
    end

    def includes_route?
      path = request.path || last_env['PATH_INFO']
      RouteParser.new.allow?(path)
    end

    def accepted_content_type?
      content_type_equals?(content_type) || content_type_matches?(content_type)
    end

    def accepted_accept_header?
      allowed_accepts = Sparrow.configuration.allowed_accepts
      accept_header = last_env['ACCEPT'] || last_env['Accept']

      allowed_accepts.include?(nil) || accept_type_matches?(allowed_accepts, accept_header)
    end

    def last_env
      @last_env || {}
    end

    def request
      request_class = if defined?(Rails) then
                        ActionDispatch::Request
                      else
                        Rack::Request
                      end

      request_class.new(last_env)
    end

    def content_type_equals?(type)
      Sparrow.configuration.allowed_content_types.include?(type)
    end

    def content_type_matches?(type)
      matches = Sparrow.configuration.allowed_content_types.map do |acceptable_content_type|
        (acceptable_content_type && type.to_s.starts_with?(acceptable_content_type.to_s))
      end

      matches.any?
    end

    def accept_type_matches?(accepted_headers, type)
      accepted_headers.detect do |accept|
        type.include?(accept)
      end
    end
  end
end

