# Variable for aws_elastic_beanstalk_application
eb_app_name = "entorno"

# Variables for aws_elastic_beanstalk_application_version
eb_app_version_name = "entorno-1"
application         = "entorno" # must be the same value as the EB application name

# Variables for aws_elastic_beanstalk_environment
eb_env_name = "entorno-env"
platform    = "64bit Amazon Linux 2023 v4.0.1 running Docker"

# Variable for aws_S3_bucket
bucket_prefix = "entorno-s3"

# Variables for aws_s3_object
key_file    = "compose.yaml" # TODO: cambiar a directorio anterior
source_file = "compose.yaml"

# Variable for aws_iam_role
role_name = "beanstalk_role"

# Variable for aws_iam_role_policy_attachment
policy = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWebTier"

# Variable for aws_iam_instance_profile
profile_name = "beanstalk_iam_instance_profile"
