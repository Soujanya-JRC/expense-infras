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

variable "zone_id"{
    default = "Z0598316EEFVEZ3ZXDA3"
}

variable "domain_name"{
    default = "rcham.online"
}