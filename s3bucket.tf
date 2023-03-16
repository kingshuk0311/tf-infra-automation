resource "aws_s3_bucket" "image_bucket"{
    bucket = "webserver-images321"
    acl = "public-read"
provisioner "local-exec"{
    command = "git clone https://github.com/kingshuk0311/terraform-code.git"
}

provisioner "local-exec"{
 when = destroy
 command = "echo Yes | rmdir /s automation" 
}
}
resource "aws_s3_bucket_object" "image_upload"{
    content_type = "image/jpeg"
    bucket = "${aws_s3_bucket.image_bucket.id}
    key = "webphoto.jpeg"
    source = "automation/img2.jpeg"
    acl = "public-read"
}

