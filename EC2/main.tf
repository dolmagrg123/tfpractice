#Local variables are only used within the scope of the currentconfiguration file where they are defined.
#They are not passed between modules or configurations.
locals {
  tag_name = "tf_web_server_01"
}

# Create an EC2 instance in AWS. This resource block defines the configuration of the instance.
resource "aws_instance" "jenkins_server01" {
  ami               = "ami-0866a3c8686eaeeba"                # The Amazon Machine Image (AMI) ID used to launch the EC2 instance.
                                        # Replace this with a valid AMI ID
  instance_type     = var.instance_type                # Specify the desired EC2 instance size.
  # Attach an existing security group to the instance.
  # Security groups control the inbound and outbound traffic to your EC2 instance.
  # vpc_security_group_ids = ["sg-00869f3e37b9c7c8f"]         # Replace with the security group ID, e.g., "sg-01297adb7229b5f08".
  vpc_security_group_ids =[aws_security_group.web_ssh.id]
  key_name          = "2024"                # The key pair name for SSH access to the instance.
  user_data         = "${file("jenkins.sh")}"
  subnet_id = var.public_subnet_id

  # Tagging the resource with a Name label. Tags help in identifying and organizing resources in AWS.
  tags = {
    "Name" : "tf_jenkins_server01"
  }
}

resource "aws_instance" "web_server01" {
  ami               = "ami-0866a3c8686eaeeba"                # The Amazon Machine Image (AMI) ID used to launch the EC2 instance.
                                        # Replace this with a valid AMI ID
  instance_type     = var.instance_type                # Specify the desired EC2 instance size.
  # Attach an existing security group to the instance.
  # Security groups control the inbound and outbound traffic to your EC2 instance.
  # vpc_security_group_ids = ["sg-00869f3e37b9c7c8f"]         # Replace with the security group ID, e.g., "sg-01297adb7229b5f08".
  vpc_security_group_ids =[aws_security_group.web_ssh.id]
  key_name          = "2024"                # The key pair name for SSH access to the instance.
  subnet_id = var.public_subnet_id

  # Tagging the resource with a Name label. Tags help in identifying and organizing resources in AWS.
  tags = {
    "Name" : local.tag_name
  }
}

# EC2 in private Subnet
resource "aws_instance" "app_server01" {
  ami               = "ami-0866a3c8686eaeeba"                # The Amazon Machine Image (AMI) ID used to launch the EC2 instance.
                                        # Replace this with a valid AMI ID
  instance_type     = var.instance_type                # Specify the desired EC2 instance size.
  # Attach an existing security group to the instance.
  # Security groups control the inbound and outbound traffic to your EC2 instance.
  # vpc_security_group_ids = ["sg-00869f3e37b9c7c8f"]         # Replace with the security group ID, e.g., "sg-01297adb7229b5f08".
  vpc_security_group_ids =[aws_security_group.web_ssh.id]
  key_name          = "2024"                # The key pair name for SSH access to the instance.
  # user_data         = "${file("jenkins.sh")}"
  subnet_id = var.private_subnet_id

  # Tagging the resource with a Name label. Tags help in identifying and organizing resources in AWS.
  tags = {
    "Name" : "tf_app_server01"    
  }
}

# Create a security group named "tf_made_sg" that allows SSH and HTTP traffic.
# This security group will be associated with the EC2 instance created above.
resource "aws_security_group" "web_ssh" {#name that terraform recognizes
  name        = "tf_made_sg"
  vpc_id      = var.vpc_id
  description = "open ssh traffic"
  # Ingress rules: Define inbound traffic that is allowed.Allow SSH traffic and HTTP traffic on port 8080 from any IP address (use with caution)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
   ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Egress rules: Define outbound traffic that is allowed. The below configuration allows all outbound traffic from the instance.

   egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Tags for the security group
  tags = {
    "Name"      : "tf_made_sg"                          # Name tag for the security group
    "Terraform" : "true"                                # Custom tag to indicate this SG was created with Terraform
  }
}

# Output block to display the public IP address of the created EC2 instance.
# Outputs are displayed at the end of the 'terraform apply' command and can be accessed using `terraform output`.
# They are useful for sharing information about your infrastructure that you may need later (e.g., IP addresses, DNS names).
output "instance_ip" {
  value = aws_instance.web_server01.public_ip # Display the public IP address of the EC2 instance after creation.
}





