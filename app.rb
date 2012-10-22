require 'bundler'
Bundler.setup

require 'sinatra'
require 'fog'
require 'mime/types'

SIXTYTWO = ('0'..'9').to_a + ('a'..'z').to_a + ('A'..'Z').to_a

class S3itchApp < Sinatra::Base

  configure do
    if ENV['HTTP_USER'] && ENV['HTTP_PASS']
      use Rack::Auth::Basic, "Restricted Area" do |username, password|
        [username, password] == [ENV['HTTP_USER'], ENV['HTTP_PASS']]
      end
    end
  end

  # A custom tweetbot endpoint
  # Configure in tweetbot as:
  # http://user:pass@hostname/tweetbot/
  # for images and (untested) videos
  post '/tweetbot/*' do
    retries = 0
    begin
      r = b62ts
      media = params["media"]
      filename = "#{r}#{File.extname(media[:filename])}"
      content_type = media[:type]
      file = bucket.files.create({
        key: "tweetbot/#{filename}",
        public: true,
        body: open(media[:tempfile]),
        content_type: content_type,
        metadata: { "Cache-Control" => 'public, max-age=315360000'}
      })
      puts "Uploaded file #{file.key} to S3"
      return "<mediaurl>http://#{ENV['S3_BUCKET']}/#{file.key}</mediaurl>"
    rescue => e
      puts "Error uploading file #{media[:name]} to S3: #{e.message}"
      if e.message =~ /Broken pipe/ && retries < 5
        retries += 1
        retry
      end

      500
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
      content_type = MIME::Types.type_for(name).first.content_type
      file = bucket.files.create({
        key: params[:name],
        public: true,
        body: request.body.read,
        content_type: content_type,
        metadata: { "Cache-Control" => 'public, max-age=315360000'}
      })
      puts "Uploaded file #{params[:name]} to S3"
      redirect "#{file.public_url}", 201
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
    file = bucket.files.get(params[:name])
    file.destroy
  end

  def bucket
    s3 = Fog::Storage.new(provider: 'AWS', aws_access_key_id: ENV['AWS_ACCESS_KEY_ID'], aws_secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'], region: ENV['AWS_REGION'])
    s3.directories.get(ENV['S3_BUCKET'])
  end

  def b62ts
    t = Time.now.to_i
    s = ''
    while t > 0
      s << SIXTYTWO[(t.modulo(62))]
      t /= 62
    end
    s.reverse
  end
end
