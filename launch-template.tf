data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

resource "aws_launch_template" "web_server" {
  name_prefix   = "web-server-"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"

  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_profile.name
  }

  user_data = base64encode(<<EOF
#!/bin/bash
apt update -y
apt install -y apache2 stress
systemctl start apache2
systemctl enable apache2
echo "<h1>It works! From $(hostname)</h1>" > /var/www/html/index.html
EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = { Name = "web-server-instance" }
  }

  lifecycle {
    create_before_destroy = true
  }
}
#     target_value = 20.0