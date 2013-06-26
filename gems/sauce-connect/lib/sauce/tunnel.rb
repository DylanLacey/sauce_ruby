require "ffi"

module Sauce
  module Connect
    class Tunnel
      include POSIXLibrary

      attr_reader :tunnel, :running

      MAX_STRING = 500

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

      VALUE_MAPPED_METHODS = [
          :is_server,
          :log_level
      ]

      def initialize(params = {})
        @tunnel = sc_new
        @running = false
        all_params = STRING_METHODS + INTEGER_METHODS + VALUE_MAPPED_METHODS
        params.select {|k, v| all_params.include? k}.each do |k,v|
          method = "#{k.to_s}=".to_sym
          self.send(method, v)
        end
      rescue StandardError => e
      end

      def start
        STDERR.puts "Beginning"
        initialization = sc_init tunnel

        STDERR.puts "Init"
        unless initialization == 0
          raise StandardError "Sauce Connect was unable to initialize"
        end
        STDERR.puts "passed the exec"

        tunnel_started = sc_run tunnel

        STDERR.puts "tunnel_started"

        unless tunnel_started == 0
          STDERR.puts "staring exception"
          raise StandardError "Sauce Connect was unable to start"
        else
          STDERR.puts "Managed to start"
          @running = true
        end

        STDERR.puts "Begun"
      end

      def status
        sc_status tunnel
      end

      def stop
        unless @running
          sc_stop tunnel
        end
      end

      def is_server=(value)
        native_value = value ? 1 : -1
        pointer_to_value =  FFI::MemoryPointer.new :int, 1
        pointer_to_value.write_array_of_int [native_value]
        sc_set tunnel, PARAMETERS[:is_server], pointer_to_value
      end

      def log_level=(value)
        set_integer_parameter :log_level, LOG_LEVELS[value]
      end

      def log_level
        unparsed_level = get_integer_parameter :log_level
        return LOG_LEVELS.select {|k,v| v == unparsed_level}.first[0]
      end

      def get_integer_parameter(parameter)
        FFI::MemoryPointer.new(:int, 1) do |ptr|
          fetch_success = sc_get tunnel, PARAMETERS[parameter], ptr, ptr.type_size

          unless fetch_success == 0
            raise StandardError "Unable to get #{parameter} from Sauce Connect tunnel #{tunnel.object_id}"
          end

          return ptr.get_int(0)
        end
      end

      def get_string_parameter(parameter)
        FFI::MemoryPointer.new(:string, MAX_STRING) do |ptr|
          fetch_success = sc_get tunnel, PARAMETERS[parameter], ptr, MAX_STRING

          unless fetch_success == 0
            raise StandardError "Unable to get #{parameter} from Sauce Connect tunnel #{tunnel.object_id}"
          end

          return ptr.get_string(0)
        end
      end

      def set_integer_parameter(parameter, value)
        param = FFI::MemoryPointer.new(:int, 1)
        param.write_array_of_int([value])
        sc_set tunnel, PARAMETERS[parameter], param
      end

      def set_string_parameter(parameter, value)
        param = FFI::MemoryPointer.from_string(value)
        sc_set tunnel, PARAMETERS[parameter], param
      end

      def method_missing(method, *args)
        if method.to_s.end_with? "="
          return_value = attempt_missing_setter(method, args)
        else
          return_value = attempt_missing_getter(method)
        end

        return return_value unless return_value.nil?
        super
      end

      private

      def attempt_missing_getter(method)
        if STRING_METHODS.include? method
          get_string_parameter method
        elsif INTEGER_METHODS.include? method
          get_integer_parameter method
        end
      end

      def attempt_missing_setter(method, args)
        stripped_method = method.to_s.chop.to_sym
        if STRING_METHODS.include? stripped_method
          set_string_parameter(stripped_method, args[0])
        elsif INTEGER_METHODS.include? stripped_method
          set_integer_parameter(stripped_method, args[0])
        end
      end
    end
  end
end