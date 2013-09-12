#!/usr/bin/env python
import sys
import os.path
from boto.s3.connection import S3Connection
import boto
from datetime import datetime

if __name__ == "__main__":
  if len(sys.argv) < 4:
    print >> sys.stderr, "Usage: %s <bucket> <bucketdir> <filename1> <filename2> ... <filenameN>" % (sys.argv[0])
    sys.exit(2)

  #Can use IAM role, environment variables (see https://github.com/boto/boto), or specify credentials here.
  # accessKey = "" # change to your access key
  # secretKey = "" # change to your secret access key
  bucketName = sys.argv[1]
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

  versionIdList=[]
  for arg in sys.argv[3:]:
    fname = os.path.basename(arg)

    if bucketdir.__len__() == 1:
      lastModified=datetime.strptime('1970-01-01T00:00:00Z', '%Y-%m-%dT%H:%M:%SZ')
      for key in bucket.list_versions(fname):
        if datetime.strptime(key.last_modified, '%Y-%m-%dT%H:%M:%S.000Z')>=lastModified:
          versionId=key.version_id
          lastModified=datetime.strptime(key.last_modified, '%Y-%m-%dT%H:%M:%S.000Z')
      #print key.name
      #print lastModified
      print arg + "=" + versionId
      versionIdList.append(arg + "=" + versionId)
    else:
      lastModified=datetime.strptime('1970-01-01T00:00:00Z', '%Y-%m-%dT%H:%M:%SZ')
      for key in bucket.list_versions(bucketdir+fname):
        if datetime.strptime(key.last_modified, '%Y-%m-%dT%H:%M:%S.000Z')>=lastModified:
          versionId=key.version_id
          lastModified=datetime.strptime(key.last_modified, '%Y-%m-%dT%H:%M:%S.000Z')
      #print key.name
      #print lastModified
      #print arg + "=" + versionId
      versionIdList.append(arg + "=" + versionId)
  print ';'.join(versionIdList)
