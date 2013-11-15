require 'openstack'
require 'yaml'
require 'erb'

module Paperclip
  module Storage
    module Swift
      def self.extended(base)
        base.instance_eval do
          @swift_credentials = parse_credentials(@options[:swift_credentials] || {})
          @swift_options = @options[:swift_options] || {}
          environment = defined?(Rails) ? Rails.env : @swift_options[:environment].to_s
          @swift_credentials = (@swift_credentials[environment] || @swift_credentials).symbolize_keys
          swift_client
        end
      end

      def exists?(style)
        swift_client.object_exists?(path(style))
      end

      def flush_writes
        @queued_for_write.each do |style, file|
          log("saving #{path(style)}")
          swift_client.create_object(path(style), {:content_type => instance_read(:content_type)}, file)
        end
        after_flush_writes
        @queued_for_write = {}
      end

      def flush_deletes
        # do not delete what should be overwritten
        skip = @queued_for_write.keys.map {|i| path(i)}
        (@queued_for_delete - skip).each do |path|
          log("deleting #{path}")
          swift_client.delete_object(path)
        end
        @queued_for_delete = []
      end

      def copy_to_local_file(style, destination_path)
        local_file = File.open(destination_path, 'wb')
        local_file.write(swift_client.object(path(style)).data)
        local_file.close
      end

      private

      def swift_client
        @swift_client ||= begin
                            assert_required_keys
                            os = OpenStack::Connection.create(@swift_credentials)
                            os.container(@swift_options[:container])
                          end
      end

      def assert_required_keys
        @swift_options.fetch(:container)
        [:username, :api_key, :authtenant, :auth_url].each do |key|
          @swift_credentials.fetch(key)
        end
      end

      def parse_credentials(credentials)
        result =
          case credentials
          when File
            YAML.load(ERB.new(File.read(credentials.path)).result)
          when String, Pathname
            YAML.load(ERB.new(File.read(credentials)).result)
          when Hash
            credentials
          else
            raise ArgumentError, ":swift_credentials are not a path, file, nor a hash"
          end

        result[:service_type] = 'object-store'
        result.stringify_keys
      end

      class FileExists < ArgumentError
      end
    end
  end
end
