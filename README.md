# myTerraform-Sandbox
(__be careful with the information you will find here, it's just a sandbox__)

# Links
Tutorials (official) : https://developer.hashicorp.com/terraform/tutorials 

Documentation (official) : https://registry.terraform.io/namespaces/hashicorp 

Certification (official) : https://www.hashicorp.com/certification/terraform-associate 

## Basic commands
```
terraform -help # to show commands list
terraform -help <cmd> # to show infos for a command
terraform init # to prepapre the working directory
terraform validate # to validate the syntax (doesnt if the code is correct or not)
terraform plan # to prepapre the configuration by showing the changes
terraform apply # to create/update the infrastructure
terraform destroy # to destroy the previously created infrastructure (I think it destroys the configuration stored in .tfstate.backup file, to verify ! And about the manualy changes made after the creation via apply command ? To verify !)
```

## Required concepts
### CIDR (Classless Inter-Domain Routing)
To describe an ip block.
10.0.0.0/24 means that 24 bits (3\*8) bits are used to identify the network and 8 bits are used to identify some addresses in the network (10.0.0.0 to 10.0.0.255)


## Syntax for a resource
```hcl
resource "<provider>_<resource_type>" "name" {
  key = "value"
}
```

```hcl
resource "aws_instance" "myServer1" {
  ami = "ami-007855ac798b5175e"
  instance_type = "t2.micro"
  # ...
}
```

## Tips
### Terminal commands inside an instance
Terminal command can be injected via "user_data".
Dont forget to begin by "<<-EOF" and finish by "EOF".
Also, dont forget to add "#!/bin/bash" to interpret the commands.
Sometimes, some commands needs a confirmation, we can auto-confirm by adding "-y" at the end of the command, as we do in a Linux terminal.
```hcl
resource "aws_instance" "myInstance_tf" {
  ami = "ami-053b0d53c279acc90"
  # ...
  user_data = <<-EOF
  #!/bin/bash
  sudo apt update -y
  sudo touch /home/ubuntu/test
  sudo apt install apache2 -y
  sudo systemctl start apache2.service
  sudo systemctl enable apache2.service
  EOF
  network_interface {
    network_interface_id = aws_network_interface.myNetInterface_tf.id
    device_index = 0
  }
  # ...
}
```

## Debugging
"TF_LOG" is an environment variable that can be set to one of these log levels : TRACE, DEBUG, INFO, WARN, ERROR.
```ps
$env:TF_LOG="ERROR" # by default
$env:TF_LOG="TRACE" # to see all logs
```
```bash
export TF_LOG="ERROR" # by default
export TF_LOG="TRACE" # to see all logs
```
To write the logs in a file :
```ps
$env:TF_LOG_PATH="path" # it disables the logs view in the terminal
$env:TF_LOG_PATH="" # to show the logs in the terminal only, as before
```
```bash
export TF_LOG_PATH="path" # it disables the logs view in the terminal
export TF_LOG_PATH="" # to show the logs in the terminal only, as before
```

## How-to
### Connect to AWS
1. Create a User and a User Group in AWS.
2. Store the ACCESS KEY ID and the SECRET ACCESS KEY.
3.  
```
aws configure # and follow the instructions to store the credentials
```
After that, the credentials will be stored in a folder (in Windows : C:\Users\\*\\.aws) and AWS can be used by adding the provider block in the TF file.

```hcl
provider "aws" {
  region = "us-east-1"
}
```
More info : https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html 

