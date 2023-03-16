resource "aws_ebs_volume" "document-storage"{
    availability_zone = aws_instance.OS1.availability_zone
    type = "gp2"
    size = 1

    tags = {
        Name = "myebs1"
    }
}


resource "aws_volume_attachment" "ebs_att" {
     device_name = "/dev/sdd"
     volume_id = "${aws_ebs_volume.document-storage.id}"
     instance_id = "${aws_instance.OS1.id}"
     force_detach = true
}
resource "null_resource" "mount-ebs" {
    depends_on = [
        aws_volume_attachment.ebs_att,
    ]
provisioner "remote-exec" {

        connection {
           type        = "ssh"
           user        = "ec2-user"
           port = 22
           private_key = file("/root/key_pair/kops.pem")
           host        = aws_instance.OS1.public_ip
        }
    
        inline = [
          "sudo mkfs.ext4 /dev/xvdf",
           "sudo mount /dev/xvdf /var/www/html",
           "sudo rm -rf /var/www/html/*",
           "sudo git clone https://github.com/kingshuk0311/terraform-code.git /var/www/html/"
        ]
      }
}
