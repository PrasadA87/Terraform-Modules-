
variable "cidr_block" {
     # default = "10.0.0.0/16"
}

variable "subnet-pub" {
     type = list
     default = ["10.0.1.0/24","10.0.2.0/24"]
}

 
variable "subnet-priv" {
     type = list
     default = ["10.0.11.0/24","10.0.12.0/24"]
}


variable "az" {
     type = list
     description = "list of az's"
     default = ["ap-south-1a", "ap-south-1b"]
}


variable "name" {
     type = "string"
     default = "sample"
}

variable "environment" {
     type = "string"
     default = "test"
}

