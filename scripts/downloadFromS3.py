#!/usr/bin/env python
import sys
import os.path
from boto.s3.connection import S3Connection
import boto

if __name__ == "__main__":
  if len(sys.argv) < 4:
    print >> sys.stderr, "Usage: %s <bucket> <bucketdir> <filename1> <filename2> ... <filenameN>" % (sys.argv[0])
    sys.exit(2)

  #Can use IAM role, environment variables (see https://github.com/boto/boto), or specify credentials here.
  #accessKey = "" # change to your access key
  #secretKey = "" # change to your secret access key
  bucketName = sys.argv[1]
  print "Connecting to S3"
  try:
    accessKey
    secretKey
    s3conn = S3Connection(accessKey,secretKey)
  except NameError:
    s3conn = S3Connection()

  bucket = s3conn.get_bucket(bucketName)

  bucketdir = sys.argv[2]
  if bucketdir.startswith("/"):
    bucketdir = bucketdir[1:]
  if not bucketdir.endswith("/"):
    bucketdir += "/"

  for arg in sys.argv[3:]:
    print "Downloading %s from bucket %s:%s" % (arg,bucketName,bucketdir)
    fname = os.path.basename(arg)
    for key in bucket.list(bucketdir+fname):
      key.get_contents_to_filename(arg)
  print "Done."
