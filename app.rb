require 'bundler'
Bundler.setup

require 'sinatra'
require 'fog'
require 'mime/types'

class S3itchApp < Sinatra::Base
  # When Skitch uploads via WebDAV, it uses
  # the file name as the URL and includes the
  # image in the body.
  put '/:name' do
    retries = 0
    begin
      content_type = MIME::Types.type_for(params[:name]).first.content_type
      file = bucket.files.create(key: params[:name], public: true, body: request.body.read, content_type: content_type)
      puts "Uploaded file #{params[:name]} to S3"
      redirect "http://#{ENV['S3_BUCKET']}/#{params[:name]}", 201
    rescue => e
      puts "Error uploading file #{params[:name]} to S3: #{e.message}"
      if e.message =~ /Broken pipe/ && retries < 5
        retries += 1
        retry
      end

      500
    end
  end

  delete '/:name' do
    file = bucket.files.find(params[:name])
    file.destroy
  end

  def bucket
    s3 = Fog::Storage.new(provider: 'AWS', aws_access_key_id: ENV['AWS_ACCESS_KEY_ID'], aws_secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'], region: ENV['AWS_REGION'])
    s3.directories.get(ENV['S3_BUCKET'])
  end
end
