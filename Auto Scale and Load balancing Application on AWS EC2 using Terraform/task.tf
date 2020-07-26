/*
  To run this file you need to provide have the credential file and provide its path in shared_credentials_file

  You need to provide the default subnet id in 
    1.All Subnets aws_subnets
    2.Route table aws_route_table
    3.Security group aws_security_group
  
  A valid cidr blocks may be required for all subnets as well depending upon your default vpc cidr.

*/


provider "aws" {
	region                  = "us-east-1"
  shared_credentials_file = "/Users/AAAA/Downloads/YOUR_CREDENTIALS.txt"

}

resource "aws_subnet" "ps-1" {
  vpc_id     = "YOUR-VPC-ID"
  cidr_block = "172.31.160.0/20"
  availability_zone_id="use1-az4"
  map_public_ip_on_launch=true

  tags = {
    Name = "ter_public_subnet_1"
  }
}
resource "aws_subnet" "ps-2" {
  vpc_id     = "YOUR-VPC-ID"
  cidr_block = "172.31.176.0/20"
  availability_zone_id="use1-az6"
  map_public_ip_on_launch=true

  tags = {
    Name = "ter_public_subnet_2"
  }
}
resource "aws_subnet" "prs-1" {
  vpc_id     = "YOUR-VPC-ID"
  cidr_block = "172.31.192.0/20"
  availability_zone_id="use1-az4"

  tags = {
    Name = "ter_private_subnet_1"
  }
}
resource "aws_subnet" "prs-2" {
  vpc_id     = "YOUR-VPC-ID"
  cidr_block = "172.31.208.0/20"
  availability_zone_id="use1-az6"

  tags = {
    Name = "ter_private_subnet_2"
  }
}


resource "aws_security_group" "terraform-sg" {
  name        = "ter_security_grp"
  description = "my-security-group"
  vpc_id      = "YOUR-VPC-ID"

  ingress {

    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {

    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ter_security_grp"
  }
}

resource "aws_key_pair" "my-key" {
  key_name   = "ter-key-p"
  public_key = "${file("terraform_ec2_key.pub")}"

}
resource "aws_launch_template" "l-temp" {
  name = "ter-launch-template"
  image_id = "ami-0323c3dd2da7fb37d"
  instance_type = "t2.micro"
  key_name = "${aws_key_pair.my-key.key_name}"
    vpc_security_group_ids = ["${aws_security_group.terraform-sg.id}"]

  user_data = "${filebase64("userdata.sh")}"
        


}


resource "aws_security_group" "ter-nat-s1" {
  name        = "ter_nat_security_grp"
  description = "my-security-group"
  vpc_id      = "YOUR-VPC-ID"

  ingress {

    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {

    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ter_nat_security_grp"
  }
}


resource "aws_instance" "ter-nat-s2" {
  ami           = "ami-00a9d4a05375b2763"
  instance_type = "t2.micro"
  subnet_id = "${aws_subnet.ps-1.id}"
  associate_public_ip_address = true
  security_groups=["${aws_security_group.ter-nat-s1.id}"]
  tags = {
    Name = "ter-nat-server"
  }
}



resource "aws_route_table" "private_route" {
  vpc_id = "YOUR-VPC-ID"
  route {
      cidr_block = "0.0.0.0/0"
      instance_id = "${aws_instance.ter-nat-s2.id}"
  }


  tags = {
    Name = "ter_private_route"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = "${aws_subnet.prs-1.id}"
  route_table_id = "${aws_route_table.private_route.id}"
}
resource "aws_route_table_association" "b" {
  subnet_id      = "${aws_subnet.prs-2.id}"
  route_table_id = "${aws_route_table.private_route.id}"
}




resource "aws_autoscaling_group" "auto_ASG" {
  name                      = "Terraform Automation"
  max_size                  = 3
  min_size                  = 2
  health_check_grace_period = 300
  health_check_type         = "EC2"
  desired_capacity          = 2
  force_delete              = true
  launch_template {
    id      = "${aws_launch_template.l-temp.id}"
    version = "$Latest"
  }
  vpc_zone_identifier       = ["${aws_subnet.ps-1.id}","${aws_subnet.ps-2.id}"]
  
  tag {
    key                 = "Name"
    value               = "Terraform Instance"
    propagate_at_launch = true
  }
}
resource "aws_security_group" "ter-lb-sg1" {
  name        = "ter_load_balncer_sg"
  vpc_id      = "YOUR-VPC-ID"

  ingress {

    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ter_load_balancer_security_grp"
  }
}

resource "aws_lb" "ter-lb" {
  name               = "ter-load-balancer"
  internal           = false
  security_groups    = ["${aws_security_group.ter-lb-sg1.id}"]
  subnets            = ["${aws_subnet.ps-1.id}","${aws_subnet.ps-2.id}"]

}
resource "aws_lb_target_group" "ter-lb-target-group" {
  name     = "tf-example-lb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "YOUR-VPC-ID"
}
resource "aws_autoscaling_attachment" "asg_attachment_bar" {
  autoscaling_group_name = "${aws_autoscaling_group.auto_ASG.id}"
  alb_target_group_arn   = "${aws_lb_target_group.ter-lb-target-group.arn}"
}
resource "aws_lb_listener" "front_end" {
  load_balancer_arn = "${aws_lb.ter-lb.arn}"
  port              = "80"
  
  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.ter-lb-target-group.arn}"
  }
}