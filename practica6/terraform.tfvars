virginia_cidr = "10.10.0.0/16"
# public_subnet  = "10.10.0.0/24"
# private_subnet = "10.10.1.0/24"
subnets = ["10.10.0.0/24", "10.10.1.0/24"]

tags = {
  "env"         = "dev"
  "owner"       = "Rios"
  "Cloud"       = "AWS"
  "IAC"         = "Terraform"
  "IAC_Version" = "1.9.8"
}

sg_ingress_cidr = "0.0.0.0/0"

ec2_specs = {
  "ami"           = "ami-012967cc5a8c9f891"
  "instance_type" = "t2.micro"
}
