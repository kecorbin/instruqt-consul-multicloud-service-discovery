resource "aws_security_group" "consul_ssh" {
  name        = "consul-ssh"
  description = "Allow ssh traffic"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "consul_lb" {
  name        = "consul-lb"
  description = "Allow lb traffic"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc

  ingress {
    from_port       = 8500
    to_port         = 8500
    protocol        = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 8501
    to_port         = 8501
    protocol        = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "consul_servers" {
  
  name        = "consul-servers"
  description = "Allow Consul traffic"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc

  ingress {
    from_port   = 8300
    to_port     = 8300
    protocol    = "tcp"
    cidr_blocks = ["10.1.0.0/16"]
  }

  ingress {
    from_port   = 8300
    to_port     = 8300
    protocol    = "udp"
    cidr_blocks = ["10.1.0.0/16"]
  }

  ingress {
    from_port   = 8301
    to_port     = 8301
    protocol    = "tcp"
    cidr_blocks = ["10.1.0.0/16"]
  }

  ingress {
    from_port   = 8301
    to_port     = 8301
    protocol    = "udp"
    cidr_blocks = ["10.1.0.0/16"]
  }

  egress {
    from_port   = 8300
    to_port     = 8300
    protocol    = "tcp"
    cidr_blocks = ["10.1.0.0/16"]
  }

  egress {
    from_port   = 8300
    to_port     = 8300
    protocol    = "udp"
    cidr_blocks = ["10.1.0.0/16"]
  }

  egress {
    from_port   = 8301
    to_port     = 8301
    protocol    = "tcp"
    cidr_blocks = ["10.1.0.0/16"]
  }

  egress {
    from_port   = 8301
    to_port     = 8301
    protocol    = "udp"
    cidr_blocks = ["10.1.0.0/16"]
  }
}
