resource "aws_iam_instance_profile" "frontend" {
  name = "frontend_instance_profile"
  role = "${aws_iam_role.demo.name}"
}

resource "aws_launch_configuration" "frontend" {
  name_prefix                 = "frontend-"
  image_id                    = "${data.aws_ami.ubuntu.id}"
  instance_type               = "t2.micro"
  associate_public_ip_address = true

  security_groups = ["${aws_security_group.frontend.id}"]
  key_name        = "instruqt"
  user_data       = "${file("../scripts/frontend.sh")}"

  iam_instance_profile = "${aws_iam_instance_profile.frontend.name}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "frontend" {
  name                 = "frontend-asg"
  launch_configuration = "${aws_launch_configuration.frontend.name}"
  desired_capacity     = 1
  min_size             = 1
  max_size             = 3
  vpc_zone_identifier  = [data.terraform_remote_state.vpc.outputs.public_subnets[0]]

  lifecycle {
    create_before_destroy = true
  }

  tags = [
    {
      key                 = "Name"
      value               = "hahsicups-frontend"
      propagate_at_launch = true
    },
    {
      key                 = "Env"
      value               = "consul"
      propagate_at_launch = true
    },
  ]

}

resource "aws_security_group" "frontend" {
  name   = "${var.prefix}-frontend"
  vpc_id = data.terraform_remote_state.vpc.outputs.vpc

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8443
    to_port     = 8443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
