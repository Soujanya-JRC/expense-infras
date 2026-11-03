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
    default = "Z04127001IEXUBYYQQPEH"
}

variable "domain_name"{
    default = "rcham.online"
}