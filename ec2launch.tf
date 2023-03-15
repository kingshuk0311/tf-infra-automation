provider "aws"{
  region= "us-east-1"
  access_key= "AKIA2BTWJXSRI2Q7IX6H"
  secret_key= "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"
}
resource "aws_instance" "OS1" {
  ami           = var.ami
  instance_type = var.instance_type
  key_name = "kops"
  vpc_security_group_ids = [aws_security_group.firewall.id]

 provisioner "remote-exec" {

    connection {
       type        = "ssh"
       user        = "ec2-user"
       private_key = file("/root/key_pair/kops.pem")
       host        = aws_instance.OS1.public_ip
    }

    inline = [
      "sudo yum install httpd -y",
       "sudo systemctl start httpd",
       "sudo systemctl enable httpd",
       "sudo yum install git -y"
    ]
  }
}


