require 'bundler'
Bundler.setup

require 'sinatra'
require 'fog'
require 'mime/types'
require 'uri'

class S3itchApp < Sinatra::Base

  configure do
    if ENV['HTTP_USER'] && ENV['HTTP_PASS']
      use Rack::Auth::Basic, "Restricted Area" do |username, password|
        [username, password] == [ENV['HTTP_USER'], ENV['HTTP_PASS']]
      end
    end
  end
  # When Skitch uploads via WebDAV, it uses
  # the file name as the URL and includes the
  # image in the body.
  put '/:name' do
    retries = 0
    begin
      # Skitch does not encode question marks, so we have to recombine the
      # name here if necessary
      name = if request.query_string && !request.query_string.empty?
        "#{params[:name]}?#{request.query_string}"
      else
        params[:name]
      end
      content_type = if MIME::Types.type_for(name).any?
        MIME::Types.type_for(name).first.content_type
      else
        "application/octet-stream"
      end
      file = bucket.files.create({
        key: name,
        public: true,
        body: request.body.read,
        content_type: content_type,
        metadata: { "Cache-Control" => 'public, max-age=315360000'}
      })
      puts "Uploaded file #{name} to S3"
      redirect "http://#{ENV['S3_BUCKET']}/#{URI.escape(name)}", 201
    rescue => e
      puts "Error uploading file #{name} to S3: #{e.message}"
      if e.message =~ /Broken pipe/ && retries < 5
        retries += 1
        retry
      end

      500
    end
  end

  delete '/:name' do
    file = bucket.files.get(params[:name])
    file.destroy
  end

  def bucket
    s3 = Fog::Storage.new(provider: 'AWS', aws_access_key_id: ENV['AWS_ACCESS_KEY_ID'], aws_secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'], region: ENV['AWS_REGION'])
    s3.directories.get(ENV['S3_BUCKET'])
  end
end
