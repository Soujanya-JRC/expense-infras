variable "common_tags" {
    default =     {
       project = "expense"
        environment = "dev"
        Terraform = true 
    }
    
}

variable "project_name" {
    default = "expense"
}

variable "environment" {
    default = "dev"
}