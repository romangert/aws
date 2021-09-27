resource "aws_security_group" "lb" {
  name        = "lb"
  description = "Load balancer traffic"
  vpc_id      = aws_vpc.mlm.id

  tags = {
    Name  = "mlm - lb"
    Owner = "Roman"
  }

  dynamic "ingress" {
    for_each = [80]
    content {
      description      = "security group ${ingress.value}"
      from_port        = ingress.value
      to_port          = ingress.value
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    }
  }

  egress = [
    {
      description      = "output all"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    }
  ]
}

resource "aws_security_group" "web" {
  name        = "web_server"
  description = "Allow connect inbound traffic"
  vpc_id      = aws_vpc.mlm.id

  tags = {
    Name = "mlm - http, https, ssh"
  }

  dynamic "ingress" {
    for_each = [80, 443, 22]
    content {
      description      = "security group ${ingress.value}"
      from_port        = ingress.value
      to_port          = ingress.value
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    }
  }

  egress = [
    {
      description      = "output all"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    }
  ]
}

resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.mlm.id
  cidr_block              = cidrsubnet(aws_vpc.mlm.cidr_block, 4, 1)
  availability_zone_id    = data.aws_availability_zones.availity_zones.zone_ids[0]
  map_public_ip_on_launch = true
  tags = {
    Name = "mlm-public_a"
  }
}

resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.mlm.id
  cidr_block              = cidrsubnet(aws_vpc.mlm.cidr_block, 4, 9)
  availability_zone_id    = data.aws_availability_zones.availity_zones.zone_ids[1]
  map_public_ip_on_launch = true
  tags = {
    Name = "mlm-public_b"
  }
}

resource "aws_subnet" "private_a" {
  vpc_id                  = aws_vpc.mlm.id
  cidr_block              = cidrsubnet(aws_vpc.mlm.cidr_block, 4, 2)
  availability_zone_id    = data.aws_availability_zones.availity_zones.zone_ids[0]
  map_public_ip_on_launch = false
  tags = {
    Name = "mlm-private_a"
  }
}

resource "aws_subnet" "private_b" {
  vpc_id                  = aws_vpc.mlm.id
  cidr_block              = cidrsubnet(aws_vpc.mlm.cidr_block, 4, 10)
  availability_zone_id    = data.aws_availability_zones.availity_zones.zone_ids[1]
  map_public_ip_on_launch = false
  tags = {
    Name = "mlm-private_b"
  }
}

resource "aws_subnet" "db_a" {
  vpc_id                  = aws_vpc.mlm.id
  cidr_block              = cidrsubnet(aws_vpc.mlm.cidr_block, 4, 4)
  availability_zone_id    = data.aws_availability_zones.availity_zones.zone_ids[0]
  map_public_ip_on_launch = false
  tags = {
    Name = "mlm-db_a"
  }
}

resource "aws_subnet" "db_b" {
  vpc_id                  = aws_vpc.mlm.id
  cidr_block              = cidrsubnet(aws_vpc.mlm.cidr_block, 4, 12)
  availability_zone_id    = data.aws_availability_zones.availity_zones.zone_ids[1]
  map_public_ip_on_launch = false
  tags = {
    Name = "mlm-db_b"
  }
}

resource "aws_route_table" "web" {
  vpc_id = aws_vpc.mlm.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.web.id
  }


  tags = {
    Name = "mlm"
  }
}

# resource "aws_main_route_table_association" "web" {
#   vpc_id         = aws_vpc.mlm.id
#   route_table_id = aws_route_table.web.id
# }

resource "aws_vpc" "mlm" {
  cidr_block         = "10.0.0.0/16"
  instance_tenancy   = "default"
  enable_dns_support = true


  tags = {
    Name = "mlm"
  }
}

resource "aws_internet_gateway" "web" {
  vpc_id = aws_vpc.mlm.id

  tags = {
    Name = "main"
  }
}
