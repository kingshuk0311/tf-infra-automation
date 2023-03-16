resource "aws_ebs_volume" "snapshot" {
  volume_id = "${aws_ebs_volume.document-storage.id}"

  tags = {
    Name = "kingshuk.ebs.snapshot"
  }
}
