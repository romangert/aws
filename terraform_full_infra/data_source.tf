
data "aws_availability_zones" "availity_zones" {}

output "availibility_zones" {
  value = data.aws_availability_zones.availity_zones.id
}

data "aws_ami" "amzn2" {
  
  most_recent      = true
  #name_regex       = "^myami-\\d{3}"
  owners           = ["amazon"]
  #architecture = "x86_64"
  #name="amzn2-ami-hvm-*-x86_64-gp2"

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

output "ami" {
  value = data.aws_ami.amzn2.id
}

