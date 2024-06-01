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
    from_port        = 5901
    to_port          = 5901
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    from_port        = 5901
    to_port          = 5901
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

resource "aws_instance" "app_server" {
  ami           = "ami-087da76081e7685da"
  instance_type = "t2.micro"
  associate_public_ip_address = true
  key_name = aws_key_pair.generated_key.key_name
  vpc_security_group_ids = [var.security_group_name]
  
  # Necesario para ejecutar los scripts de preparacion del entorno
  connection {
    type     = "ssh"
    user     = "admin"
    private_key = file("./priv_key/${self.key_name}.pem")
    host     = self.public_dns
  }

  provisioner "file" {
    source      = "../packages"
    destination = "/tmp/packages"
  }

  provisioner "file" {
    source      = "../config"
    destination = "/tmp/config"
  }

  provisioner "file" {
    source      = "../static"
    destination = "/tmp/static"
  }

  provisioner "file" {
    source      = "../provision.sh"
    destination = "/tmp/provision.sh"
  }

  provisioner "file" {
    source      = "./init.sh"
    destination = "/tmp/init.sh"
  }

  # Solo se puede copiar a directorios no protegidos con el provisioner file
  provisioner "remote-exec" {
    inline = [
      "sudo apt update && sudo apt-get install -y tigervnc-standalone-server",
      "sudo groupadd sigma -g 1001",
      "sudo /usr/sbin/useradd sigma -u 1001 -g 1001 -s /bin/bash",
      "sudo cp -r /tmp/packages / && rm -rf /tmp/packages",
      "sudo cp -r /tmp/config / && rm -rf /tmp/config",
      "sudo cp -r /tmp/static/* / && rm -rf /tmp/static",
      "sudo mkdir /scripts",
      "sudo mv /tmp/provision.sh /scripts",
      "sudo mv /tmp/init.sh /scripts",
      "sudo chmod +x /scripts/provision.sh && sudo /scripts/provision.sh",
      "sudo mkdir -p /home/sigma/.vnc",
      "sudo echo ${var.tigervncpasswd} | sudo vncpasswd -f > /tmp/passwd",
      "sudo mv /tmp/passwd /home/sigma/.vnc/", 
      "sudo chmod 600 /home/sigma/.vnc/passwd",
      "sudo chmod +x /scripts/init.sh && sudo /scripts/init.sh"
    ]
  }
}


