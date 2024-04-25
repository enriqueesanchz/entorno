output "env_cname" {
  value = "http://${aws_elastic_beanstalk_environment.entorno-env.cname}"
}
