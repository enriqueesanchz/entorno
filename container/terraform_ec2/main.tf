terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.46"
    }
  }

  required_version = ">= 1.2.0"
}

resource "tls_private_key" "rsa-4096" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = var.key_name
  public_key = tls_private_key.rsa-4096.public_key_openssh

  provisioner "local-exec" { #Guarda la clave privada generada
    command  = <<EOT
    echo '${tls_private_key.rsa-4096.private_key_pem}' > ./priv_key/${self.key_name}.pem
    chmod 400 ./priv_key/${self.key_name}.pem
    EOT
  }

  provisioner "local-exec" {
    when = destroy
    
    command = "rm -f ./priv_key/mi_clave.pem"
      
    on_failure = continue  #destruye la instancia ec2 aunque el comando anterior devuelva un error
  }
}


provider "aws" {
  profile = "default"
  region  = "eu-west-3"
}

resource "aws_security_group" "entorno-sec" {
  name = var.security_group_name

  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    from_port        = 6901
    to_port          = 6901
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    from_port        = 6901
    to_port          = 6901
    protocol         = "udp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_ebs_volume" "my-volume" {
  availability_zone = "eu-west-3c"
  size              = 1
}

resource "aws_volume_attachment" "my-volume" {
  device_name = "/dev/xvdh"
  volume_id   = aws_ebs_volume.my-volume.id
  instance_id = aws_instance.app_server.id
  force_detach = true

  provisioner "remote-exec" {
    connection {
      type     = "ssh"
      user     = "ec2-user"
      private_key = file("./priv_key/${aws_instance.app_server.key_name}.pem")
      host     = "${aws_instance.app_server.public_ip}"
    }
    inline = [
      "sudo chmod +x ./format.sh && sudo ./format.sh",
      "sudo docker-compose up -d"
    ]
  }
}

resource "aws_instance" "app_server" {
  ami           = "ami-007961579c9b9485b"
  instance_type = "t2.micro"
  associate_public_ip_address = true
  key_name = aws_key_pair.generated_key.key_name
  vpc_security_group_ids = [var.security_group_name]
  depends_on = [aws_ebs_volume.my-volume]
  
  # Necesario para ejecutar los scripts de preparacion del entorno
  connection {
    type     = "ssh"
    user     = "ec2-user"
    private_key = file("./priv_key/${self.key_name}.pem")
    host     = self.public_dns
  }

  provisioner "file" {
    source      = "../compose.yaml"
    destination = "./compose.yaml"
  }

  provisioner "file" {
    source      = "./scripts/format.sh"
    destination = "./format.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo amazon-linux-extras install docker -y",
      "sudo service docker start",
      "sudo curl -L https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) -o /usr/bin/docker-compose",
      "sudo chmod +x /usr/bin/docker-compose",
      "echo tigervncpasswd=${var.tigervncpasswd} >> .env",
      "echo vpn_user=${var.vpn_user} >> .env",
      "echo vpn_password=${var.vpn_password} >> .env",
      "sudo docker pull enriqueesanchz/entorno"
    ]
  }
}

