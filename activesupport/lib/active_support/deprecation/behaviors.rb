require "active_support/notifications"

module ActiveSupport
  module Deprecation
    class << self
      # Whether to print a backtrace along with the warning.
      attr_accessor :debug

      # Returns the set behavior or if one isn't set, defaults to +:stderr+
      def behavior
        @behavior ||= [DEFAULT_BEHAVIORS[:stderr]]
      end

      # Sets the behavior to the specified value. Can be a single value or an array.
      #
      # Examples
      #
      #   ActiveSupport::Deprecation.behavior = :stderr
      #   ActiveSupport::Deprecation.behavior = [:stderr, :log]
      def behavior=(behavior)
        @behavior = Array(behavior).map { |b| DEFAULT_BEHAVIORS[b] || b }
      end
    end

    # Default warning behaviors per Rails.env.
    DEFAULT_BEHAVIORS = {
      :stderr => Proc.new { |message, callstack|
         $stderr.puts(message)
         $stderr.puts callstack.join("\n  ") if debug
       },
      :log => Proc.new { |message, callstack|
         logger =
           if defined?(Rails) && Rails.logger
             Rails.logger
           else
             require 'active_support/logger'
             ActiveSupport::Logger.new($stderr)
           end
         logger.warn message
         logger.debug callstack.join("\n  ") if debug
       },
       :notify => Proc.new { |message, callstack|
          ActiveSupport::Notifications.instrument("deprecation.rails",
            :message => message, :callstack => callstack)
       }
    }
  end
end
