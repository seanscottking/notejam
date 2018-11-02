output "s3_bucket_id_lb_logs" {
  value = "${aws_s3_bucket.main.id}"
}
