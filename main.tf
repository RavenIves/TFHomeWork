provider "aws" {
  access_key = var.v-access-key
  secret_key = var.v-secret-key
  region     = "eu-central-1"
}


resource "aws_vpc" "main-vpc" {
  cidr_block = "10.10.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true
  tags = {
      Name = "HomeWork-VPC"
  }
}

resource "aws_internet_gateway" "main-igw" {
    vpc_id = aws_vpc.main-vpc.id 
    tags = {
        Name = "MAIN-IGW"
    }
}

resource "aws_route_table" "main-prt" {
    vpc_id = aws_vpc.main-vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.main-igw.id
    }
    tags = {
        Name = "MAIN-PUBLIC_RT"
    }
}

resource "aws_subnet" "main-snet" {
    count = var.v-count
    vpc_id = aws_vpc.main-vpc.id
    cidr_block = var.main-cidr[count.index]
    map_public_ip_on_launch = true
    availability_zone = data.aws_availability_zones.main-avz.names[count.index]
    tags = {
        Name = "MAIN-SUB-NET"
    }
}

resource "aws_route_table_association" "main-prt-assoc" {
    count = var.v-count
    subnet_id = aws_subnet.main-snet.*.id[count.index]
    route_table_id = aws_route_table.main-prt.id
}

resource "aws_security_group" "main-pub-sg" {
    name = "main-pub-sg"
    description = "Main Public SG"
    vpc_id = aws_vpc.main-vpc.id
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}
resource "aws_instance" "StanHomeWork-server" {
    count = var.v-count
    ami = var.v-ami-image
    instance_type = var.v-instance-type
    key_name = var.v-instance-key
    vpc_security_group_ids = [aws_security_group.main-pub-sg.id]
    subnet_id = element(aws_subnet.main-snet.*.id, count.index)
    tags = {
        Name = "StanHomeWork-server-${count.index + 1}"
    }


provisioner "file" {
        source      = "./installdocker.sh"
        destination = "/tmp/installdocker.sh"
        connection {
            type = "ssh"
            user = "softuni"
            private_key = file("/home/ravenives/projects/SoftUni/softuni.pem")
            host = self.public_ip
        }
    }
    provisioner "remote-exec" {
        inline = [
        "chmod +x /tmp/installdocker.sh",
        "/tmp/installdocker.sh"
        ]
        connection {
            type = "ssh"
            user = "softuni"
            private_key = file("/home/ravenives/projects/SoftUni/softuni.pem")
            host = self.public_ip
        }
    }
}


