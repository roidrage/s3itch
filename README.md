S3itch - Sharing Skitch uploads on S3
======

As Skitch will soon shut down their own hosting and [switch to
Evernote](http://blog.evernote.com/2012/03/19/skitch-for-mac-gets-sharing-through-evernote/),
the only reasonable thing to do is to use WebDAV instead and put files on S3.

Installation
============

The app assumes you're storing files in a bucket that has a CNAME attached to
it, e.g. s3itch.mydomain.com, and that you're setting this CNAME as base URL in
Skitch. Skitch sends a HEAD request to the base URL (your S3 bucket) after
uploading to check if the file was properly stored. 

It's made for deployment on Heroku:

* `git clone git://github.com:mattmatt/s3itch.git`
* `heroku create --stack cedar`
* `git push heroku master`
* Set environment variables `AWS_REGION` (e.g. eu-west-1), `AWS_ACCESS_KEY_ID`,
  `AWS_SECRET_ACCESS_KEY` and `S3_BUCKET` for the Heroku app
* Configure Skitch with the bucket and the URL of the Heroku app: ![Skitch
  Configuration](http://s3itch.paperplanes.de/Preferences-20120401-174030.png)

  By the way, this picture was uploaded using this bridge and is hosted on S3.
  Did that just blow your mind?

Done!
