require 'aws-sdk'
require 'pathname'

module Serialcaster
  class Fetcher
    attr_reader :bucket_name, :prefix, :credentials, :region

    def self.list(bucket_name, opts = {})
      client = Aws::S3::Client.new(opts)
      bucket = Aws::S3::Resource.new(client: client).bucket(bucket_name)
      candidates = client.list_objects(bucket: bucket_name, delimiter: '/')
        .common_prefixes.map { |res| Pathname.new(res.prefix).cleanpath }
      candidates.select { |prefix|
        bucket.object(prefix.join('programme.json').to_s).exists?
      }.map(&:to_s)
    end

    def initialize(attrs = {})
      @bucket_name = attrs.fetch(:bucket)
      @prefix = attrs.fetch(:prefix)
      @credentials = attrs[:credentials]
      @region = attrs[:region]
    end

    def metadata_io
      bucket.object(metadata_key).get.body
    end

    def file_list
      prefix_plus_sep = "#{prefix}/"
      bucket.objects(prefix: prefix).reject { |obj_summary|
        obj_summary.key == metadata_key
      }.reject { |obj_summary|
        obj_summary.key == prefix_plus_sep
      }.map { |obj_summary|
        [obj_summary.key[prefix_plus_sep.length..-1], obj_summary.content_length]
      }
    end

    def url_for_file(key)
      bucket.object(key).presigned_url(:get, expires_in: 604800)
    end

    private

    def prefix_path
      @prefix_path ||= Pathname.new(prefix)
    end

    def metadata_key
      @metadata_key ||= prefix_path.join("programme.json").to_s
    end

    def client_attrs
      attrs = {}
      attrs[:region] = region if region
      attrs[:credentials] = credentials if credentials
      attrs
    end

    def client
      @client ||= Aws::S3::Client.new(client_attrs)
    end

    def s3
      @s3 ||= Aws::S3::Resource.new(client: client)
    end

    def bucket
      s3.bucket(bucket_name)
    end
  end
end
