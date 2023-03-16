resource "aws_cloudfront_origin_access_identity" "origin_access_identity"{
    comment = "Create origin access identity"
}
locals{
    s3_origin_id = "myS3Origin"
}
resource "aws_cloudfront_distribution" "s3_distribution" {
  origin{
     domain_name = "${aws_s3_bucket.image-bucket.bucket_regional_domain_name}"
     origin_id = "${local.s3_origin_id}"

     s3_origin_config{
        origin_access_identity = "${aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_eccess_identity_path}"
     }
     enable = true
     is_ipv6_enable = true 
     comment = "CDN distribution"

     default_cache_behavior {
        allowed_methods = ["DELETE","GET","HEAD","OPTIONS","PATCH","POST","PUT"]
        cache_methods = ["GET","HEAD"]
        target_origin_id = "${local.s3_origin_id}"
        
        forwarded_values{
            query_string = false 

            cookies {
                forward = "none"
            }
        
        viewer_protocol_policy = "allow-all"
        min_ttl = 0
        default_ttl = 3600
        max_ttl = 86400
     }
     ordered_cache_behavior {
        path_pattern = "/content/immutable/*"
        allowed_methods = ["GET","HEAD","OPTIONS"]
        cache_methods = ["GET","HEAD","OPTIONS"]
        target_origin_id = "${local.s3_origin_id}"

        forwarded_values {
            query_string = false 
            headers = ["Origin"]

            cookies {
                forward = "none"
            }
        }

        min_ttl = 0
        default_ttl = 86400
        max_ttl = 31536000
        compress = true 
        viewer_protocol_policy = "redirect-to-https"
     }

     ordered_cache_behavior {
        path_pattern = "/content/*"
        allowed_methods = ["GET","HEAD","OPTIONS"]
        cache_methods = ["GET","HEAD"]
        target_origin_id = "${local.s3_origin_id}"

        forwarded_values {
            query_string = false
        }
            cookies {
               forward = "none"
             }
          }
          min_ttl = 0
          default_ttl = 86400
          max_ttl = 31536000
          compress = true 
          viewer_protocol_policy = "redirect-to-https"
        }
        price_class = "PriceClass_200"

        restrictions {
            geo_restriction {
                restriction_type = "whitelist"
                locations = ["US" , "IN"]
            }
        }

        tags = {
            Enviroment = "production"
        }

        viewer_certificate {
            cloudfront_default_certifice = true 
        }
     provisioner "remote-exec" {

        connection {
          type        = "ssh"
          user        = "ec2-user"
          private_key = file("/root/key_pair/kops.pem")
        host        = aws_instance.OS1.public_ip
     }

    
      inline = [
        "sudo su <<END",
     "echo \"<img src='http://${aws_cloudfront_distribution.s3_distribution.domain_name}/${aws_s3_object.image-upload.key}' height='550' width='550'>\" >> /var/www/html/index.html",
        "END", 
      ]
     }
   
