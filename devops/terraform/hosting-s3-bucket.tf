# ███████ ██████      ██   ██  ██████  ███████ ████████ 
# ██           ██     ██   ██ ██    ██ ██         ██    
# ███████  █████      ███████ ██    ██ ███████    ██    
#      ██      ██     ██   ██ ██    ██      ██    ██    
# ███████ ██████      ██   ██  ██████  ███████    ██    

resource "aws_s3_bucket" "website_bucket" {
  bucket = "csalpi-tf-bucket-website"
  acl    = "public-read"

  website {
    index_document = "index.html"
    error_document = "error.html"
  }

  cors_rule {
    allowed_methods = ["GET"]
    allowed_origins = ["*"]
    max_age_seconds = 3000
  }
}


# ██    ██ ██████  ██       ██████   █████  ██████  
# ██    ██ ██   ██ ██      ██    ██ ██   ██ ██   ██ 
# ██    ██ ██████  ██      ██    ██ ███████ ██   ██ 
# ██    ██ ██      ██      ██    ██ ██   ██ ██   ██ 
#  ██████  ██      ███████  ██████  ██   ██ ██████  

resource "aws_s3_bucket_object" "file_upload_index" {
  bucket       = aws_s3_bucket.website_bucket.id
  key          = "index.html"
  source       = "application/website/index.html"
  acl          = "public-read"
  content_type = "text/html"
  # etag         = filemd5("application/website/index.html")

  depends_on = [null_resource.insert_lambdalink]
}

resource "aws_s3_bucket_object" "file_upload_error" {
  bucket       = aws_s3_bucket.website_bucket.id
  key          = "error.html"
  source       = "application/website/error.html"
  acl          = "public-read"
  content_type = "text/html"
  etag         = filemd5("application/website/error.html")
}

# # permissions bugged
# resource "aws_s3_bucket_object" "images" {
#   for_each = fileset("application/website/img/", "*")
#   bucket   = aws_s3_bucket.website_bucket.id
#   key      = each.value
#   source   = "application/website/img/${each.value}"
#   acl      = "public-read"
#   etag     = filemd5("application/website/img/${each.value}")
# }

### sync a folder of files
resource "null_resource" "sync_images" {
  provisioner "local-exec" {
    command = "aws s3 sync application/website/img s3://${aws_s3_bucket.website_bucket.id}/img --acl public-read"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "aws s3 rm --recursive s3://csalpi-tf-bucket-website/img"
  }
}