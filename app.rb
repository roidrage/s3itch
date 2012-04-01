require 'bundler'
Bundler.setup

require 'sinatra'
require 'fog'
require 'mime/types'

class S3itchApp < Sinatra::Base
  put '/:name' do
    retries = 0
    s3 = Fog::Storage.new(provider: 'AWS', aws_access_key_id: ENV['AWS_ACCESS_KEY_ID'], aws_secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'], region: 'eu-west-1')
    begin
      directory = s3.directories.get(ENV['S3_BUCKET'])
      content_type = MIME::Types.type_for(params[:name]).first.content_type
      file = directory.files.create(key: params[:name], public: true, body: request.body, content_type: content_type)
      puts "Uploaded file #{params[:name]} to S3"
      redirect "http://#{ENV['S3_BUCKET']}/#{params[:name]}", 201
    rescue => e
      puts "Error uploading file #{params[:name]} to S3: #{e.message}"
      if e.message =~ /Broken pipe/
        retry
      end

      500
    end
  end
end
