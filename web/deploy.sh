# TODO: replace with docker instance... 
s3cmd sync ./ s3://$S3BUCKET --delete-removed -P --rexclude=.git* --rexclude=captures*
