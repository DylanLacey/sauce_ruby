require "ffi"

module Sauce
  module Connect
    class Tunnel
      include POSIXLibrary

      attr_reader :tunnel

      STRING_METHODS = [
          :tunnel_host,
          :proxy_host,
          :log_file,
          :cert_file,
          :key_file,
          :username,
          :access_key
      ]

      INTEGER_METHODS = [
          :tunnel_port,
          :proxy_port,
          :max_log_size,
          :local_port
      ]

      def initialize
        @tunnel = sc_new
      rescue StandardError => e
      end

      def is_server=(value)
        native_value = value ? 1 : -1
        pointer_to_value =  FFI::MemoryPointer.new :int, 1
        pointer_to_value.write_array_of_int [native_value]
        sc_set @tunnel, PARAMETERS[:is_server], pointer_to_value
      end

      def log_level=(value)
        set_integer_parameter :log_level, LOG_LEVELS[value]
      end

      def set_integer_parameter(parameter, value)
        FFI::MemoryPointer.new :int do |p|
          p.write_array_of_int [value]
          sc_set @tunnel, PARAMETERS[parameter] , p
        end
      end

      def set_string_parameter(parameter, value)
        FFI::MemoryPointer.from_string(value) do |p|
          sc_set @tunnel, PARAMETERS[parameter], p
        end
      end

      def method_missing(method, *args)
        if method.to_s.end_with? "="
          stripped_method = method.to_s.chop.to_sym
          if STRING_METHODS.include? stripped_method
            set_string_parameter(stripped_method, args[0])
          elsif INTEGER_METHODS.include? stripped_method
            set_integer_parameter(stripped_method, args[0])
          else
            super
          end
        else
          super
        end
      end
    end
  end
end