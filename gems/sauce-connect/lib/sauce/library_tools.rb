require "ffi"

module Sauce
  module Connect
    module POSIXLibrary

      def find_library
        paths = [
            File.join("#{File.dirname(__FILE__)}", "../", "../", "support"),
            File.join("usr","lib"),
            File.join("~"),
            FFI::Platform::LIBPREFIX,
        ] + ENV["PATH"].split(":")

        librarytized_paths = paths.map do |path|
          file_path = File.join path, "libsauceconnect"
          map_extentions file_path
        end

        libconnect_path = librarytized_paths.find do |path|
          STDERR.puts "Checking path: #{path}"
          File.exists? path
        end

        if libconnect_path
          STDERR.puts "Found #{libconnect_path}"
          return libconnect_path
        else
          stringed_paths = paths.join "\n"
          raise LoadError, "libsauceconnect wasn't found in any of the following paths: \n#{stringed_paths}"
        end
      end

      module_function :find_library

      ## Shamelessly inspired by LibFFI -- Here until LibFFI's finding is patched
      def self.map_extentions lib
        r = FFI::Platform::IS_GNU ? "\\.so($|\\.[1234567890]+)" : "\\.#{FFI::Platform::LIBSUFFIX}$"
        lib += ".#{FFI::Platform::LIBSUFFIX}" unless lib =~ /#{r}/
      end
    end
  end
end