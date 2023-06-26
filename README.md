# myTerraform-Sandbox
(__be careful with the information you will find here, it's just a sandbox__)

# Links
Tutorials (official) : https://developer.hashicorp.com/terraform/tutorials 

Documentation (official) : https://registry.terraform.io/namespaces/hashicorp 

Certification (official) : https://www.hashicorp.com/certification/terraform-associate 

# Useful theory
- HashiCorp Terraform is an IaC tool that lets you define both cloud and on-prem resources in human-readable configuration files that you can version, reuse, and share.
- You can then use a consistent workflow to provision and manage all of your infrastructure throughout its lifecycle. Terraform can manage low-level components like compute, storage, and networking resources, as well as high-level components like DNS entries and SaaS features.
- With IaC, we are not (or less) prone to human error and we can scale up (and down) the infrastructure easily. Associate with versioning, we can see an incremental history of who changed what.
- Terraform uses the API of its providers to create and manage the resources.
- There is a lot of providers for services or platforms in Terraform.
- The state file (tfstate ?) is the real configuration of your infratructure. Terraform use this file to determine the changes to make to the infrastructure after the "plan".
- The Terraform config file is in  declarative format, it means that the file is the end state, the dependency and the order of execution are managed by Terraform.
- A "module" is a reusable and configurable collections of infrastructure provided to save time and offer a standardized configuration.
- Terraform can manage IaaS (AWS, Azure, GCP, ... and also on-premise VMware, ...), PaaS (K8S, Heroku, ...) and SaaS (GitHub, Fastly, ...).

# To-Do
- Use Terraform Cloud. (one state ? centralized vars ? vcs ?)
- Why Terraform ?
- Terraform or Ansible ?
- Provisioner ?
- Sentinel policies ?
- Backend ?

# Terraform Cloud

To be able to use AWS provider in TF cloud, the credentials must be stored in variables env in the TF cloud GUI : AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY. (Dont forget to mark them as SENSITIVE). A project, in TF cloud, is composed of one or more workspaces. It helps to organize workspaces in a large organization. It's also possible to approve manually in the UI after a terraform apply. A new run can be launched via UI after updating for example a variable. Manage variable corectly give us the possibility to update an entire configuration without updating de tf file, only the variable in TF cloud.

CLI can be used to trigger but VCS also. For example, Github can be used to be triggered by a push (apply) or by a pull request (plan only). For VCS, the cloud block must be deleted.

## Variable sets
Variable sets are defined in TF cloud and can be used by all workspaces. They are mostly used for credentials (ex: AWS Credentials). They can be "sensitive" or not, for environment or Terraform (HCL format, or simply the value of the key). "TF_LOG" can also be werwritted, for example. "Terraform" variables refers to "input variables".

```hcl
variable "instance_count" {
  description = "Number of instances to provision."
  type        = number
  default     = 2
}
```
```hcl
module "ec2_instances" {
  source = "./modules/aws-instance"
  instance_count = var.instance_count
 # ...
}
```

```hcl
variable "myVar" {} # to be able to use "myVar" defined in TF cloud. (unique solution ?)
```

Variables can be overritted in CLI, before execution, else, the default value will be used.

Order for variable priority :
1. Command line argument variables (RUN-SPECIFIC)
2. Local env variable with prefixed with TF_VAR_ (RUN-SPECIFIC)
3. Workspace specific variable (WORKSPACE-SPECIFIC)
4. Workspace-scoped variable sets (WORKSPACE-SCOPED)
5. Project-scoped variable sets (PROJECT-SCOPED)
6. Global variable sets (GLOBAL)
7. *.auto.tfvars
8. terraform.tfvars

*.auto.tfvars files are in a format like this :

```
myVar1 = "myValue1"
myVar2 = "myValue2"
```

To change a variable in CLI, we can use :

```hcl
terraform apply -var="myKey=myNewValue"
```


More info : https://developer.hashicorp.com/terraform/cloud-docs/workspaces/variables#scope

## Structure (idea ?)

variables.tf : defines the input variables that are referenced in main.tf, which make the configuration customizable. You will define these variables in the Terraform Cloud UI later on in this tutorial.

outputs.tf : defines the information about your infrastructure that Terraform Cloud will display to you when it makes changes.

terraform.tf : defines version constraints for Terraform and the AWS provider and the cloud block for the Terraform Cloud integration.


## Basic commands
```
terraform -help # to show commands list
terraform -help <cmd> # to show infos for a command
terraform init # to prepapre the working directory (also to begin to use the TF cloud or after an update of the TF config block)
terraform validate # to validate the syntax (doesnt if the code is correct or not)
terraform plan # to prepapre the configuration by showing the changes
terraform refresh # to update the state to match remote systems
terraform state list # to see a list of ressources actually managed by Terraform
terraform fmt # to format the code
terraform show # to see the curent state
terraform login # to connect to TF cloud (first step to use terraform cloud)
```
### Apply
```
terraform apply # to create/update the infrastructure
terraform apply -target="<provider>_<ressource_type>.<name>" # to create/update a resource of the infrastructure (the linked resources will be also created/updated)
terraform apply -var "myVarName=<var_value>" # to specify another variable value
```
### Destroy
```
terraform destroy # to destroy the previously created infrastructure (it destroys the configuration stored in the tfstate, it destroys the entire configuration managed by terraform)
terraform destroy -target="<provider>_<ressource_type>.<name>" # to destroy a specific resource (the linked resources will be also deleted)
```

## List of files
- file.tf : the file describing the configuration
- file.tfstate : the current configuration managed by terraform
- file.tfstate.backup : the previous file.tfstate

## Required concepts
### CIDR (Classless Inter-Domain Routing)
To describe an ip block.
10.0.0.0/24 means that 24 bits (3\*8) bits are used to identify the network and 8 bits are used to identify some addresses in the network (10.0.0.0 to 10.0.0.255)

## Syntax for adding an external provider (not from TF)
```hcl
terraform {
  required_providers {
    <name of the provider> = {
      source  = "<source>"
      version = "..."
    }
  }
}
```

```hcl
terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.1"
    }
  }
}

provider "docker" {
  host    = "npipe:////.//pipe//docker_engine"
}
```

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

## Destroy 

```
terraform plan -destroy -out=destroy.tfplan
terraform apply destroy.tfplan
```

### Sentinel
A policy set contains policies. A policy is a rule that can be set to :
- Hard-mandatory : It's the strongest enforcement level. The policy must have a "true" value to pass.
- Soft-mandatory : It's an enforcement level that lets the owner or a user with override priviliege to bypass the rule.
- Advisory : It's a notification.

A policy set is attached to a workspace.

VCS can be used, or the UI (maybe the CLI also ? to verify !).

A policy set is defined in an *.hcl file, and the policy is defined in a <policy_name_in_sentinel_file>.sentinel file.

sentinel.hcl
```
policy "myPolicy" {
    enforcement_level = "soft-mandatory"
}
# ...
```
myPolicy.sentinel
```
import "tfplan"
import "version"

versionCheck = rule {
  version.new(tfplan.terraform_version).greater_than("1.1.0")
}
```
