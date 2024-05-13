output "public_dns" {
  value = "${aws_elastic_beanstalk_environment.entorno-env.cname}"
}
