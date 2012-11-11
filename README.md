S3itch - Sharing Skitch (and Tweetbot!) uploads on S3
======

As Skitch will soon shut down their own hosting and [switch to
Evernote](http://blog.evernote.com/2012/03/19/skitch-for-mac-gets-sharing-through-evernote/),
the only reasonable thing to do is to use WebDAV instead and put files on S3.

**Note** that this app does not work with Skitch 2.0, which removed any sharing
options other than Evernote. It works with Skitch 1.0.x only, the latest version
of which (v1.0.12) you can [still
download](http://www.macupdate.com/download/39932/skitch.zip), AppStore-free.

Installation
============

The app assumes you're storing files in a bucket that has a CNAME attached to
it, e.g. s3itch.mydomain.com, and that you're setting this CNAME as base URL in
Skitch. Skitch sends a HEAD request to the base URL (your S3 bucket) after
uploading to check if the file was properly stored. The CNAME isn't, however, required
and can be disabled.

It's made for deployment on Heroku:

* `git clone git://github.com/roidrage/s3itch.git`
* `cd s3itch`
* `heroku create --stack cedar`
* `git push heroku master`
* Set environment variables `AWS_REGION` (e.g. eu-west-1), `AWS_ACCESS_KEY_ID`,
  `AWS_SECRET_ACCESS_KEY`, `S3_BUCKET`, `HTTP_USER` and `HTTP_PASS` for the Heroku app
* If you wish to NOT use a CNAME, also set `NO_CNAME` to `true`
* Configure Skitch with the bucket and the URL of the Heroku app. Also configure the
  username and password if set.: ![Skitch Configuration](http://s3itch.paperplanes.de/Preferences-20120401-174030.png)

  By the way, this picture was uploaded using this bridge and is hosted on S3.
  Did that just blow your mind?

If you are not using a CNAME, set the base URL above like so:

`http://<bucketname>.s3.amazonaws.com`

Using
=====

Skitch
------
Take screenshot, annotate whimsically, upload, done.

Skitch generates a new name for every upload that includes the timestamp and has
the full URL to the file ready for you to copy to the clipboard. Unfortunately
the WebDAV export doesn't copy that automatically, but after sharing, the "Share"
button turns into a "Copy" button.

Done!

Tweetbot
--------
Tweetbot for OSX (and iOS) has support for a "custom" endpoint for sharing photos and videos on Twitter. S3itch exposes a custom endpoint under `/tweetbot` for folks to use.
When you drag an image into a tweet in Tweetbot, s3itch will upload the image into your bucket named `tweetbot/<base62 of timestamp>.<file_extension>`. Note that the image WILL be public.

Here's a screenshot of the configuration screen in Tweetbot:
![Tweetbot Configuration](https://s3itch.s3.amazonaws.com/tweetbot%2F1tqjKx.jpg)

By the way, that image was tweeted from Tweetbot using s3itch. Here's the proof (uploaded by s3itch and Skitch):
![Tweetbot proof](http://s3itch.s3.amazonaws.com/Screen_Shot_2012-10-22_at_11.17.24_AM-20121022-111803.jpg)

If I had any mind left, it would be double-blown.
