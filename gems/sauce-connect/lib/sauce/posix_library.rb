require "sauce/library_tools"

module Sauce
  module Connect
    module POSIXLibrary
      extend FFI::Library

      ffi_lib find_library

      PARAMETERS = {
        :is_server  => 0x01,     # int
        :tunnel_host  => 0x02,      # char
        :tunnel_port  => 0x03,      # int
        :proxy_host  => 0x04,      # char
        :proxy_port =>  0x05,      # int
        :log_file => 0x06,       # char
        :log_level => 0x07,      # int
        :max_log_size => 0x08,   # int
        :cert_file => 0x09,      # char
        :key_file => 0x0a,       # char
        :local_port => 0x0b,    # int
        :username => 0x0c,          # char
        :access_key => 0x0d       # char
      }

      LOG_LEVELS = {
          :error => 0,
          :info => 1,
          :debug => 2
      }

      STATUSES ={
          0x01 => :running,
          0x02 => :exiting
      }

      # Get the configuration
      attach_function :sc_new, [], :pointer

      # Everyone loves an accessor
      attach_function :sc_set, [:pointer, :int, :pointer], :int
      attach_function :sc_get, [:pointer, :int, :pointer, :size_t], :int

      # Make sure everything's super ready to be all tunnely
      attach_function :sc_init, [:pointer], :int

      # Start the main event loop
      attach_function :sc_run, [:pointer], :int

      # Cleanly stop the event loop
      attach_function :sc_stop, [:pointer], :int

      # The current status of Sauce Connect
      attach_function :sc_status, [:pointer], :int
    end
  end
end
