variable "vm_name" {
  description = "The name of the virtual machine"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "location" {
  description = "The Azure region"
  type        = string
}

variable "size" {
  description = "The size of the virtual machine"
  type        = string
  default     = "Standard_D2as_v5"
}

variable "admin_username" {
  description = "Admin username for the VM"
  type        = string
}

variable "admin_password" {
  description = "Admin password for the VM"
  type        = string
  sensitive   = true
}

variable "subnet_id" {
  description = "The ID of the subnet where the VM will be placed"
  type        = string
}

variable "public_ip_id" {
  description = "The ID of the public IP (optional)"
  type        = string
  default     = null
}

variable "os_disk_storage_account_type" {
  description = "Storage account type for the OS disk"
  type        = string
  default     = "Premium_LRS"
}

variable "os_disk_size_gb" {
  description = "Size of the OS disk in GB"
  type        = number
  default     = 128
}

variable "data_disks" {
  description = "Map of data disks to attach"
  type = map(object({
    size_gb              = number
    storage_account_type = string
    lun                  = number
  }))
  default = {}
}

variable "image_publisher" {
  description = "Image publisher"
  type        = string
}

variable "image_offer" {
  description = "Image offer"
  type        = string
}

variable "image_sku" {
  description = "Image SKU"
  type        = string
}

variable "image_version" {
  description = "Image version"
  type        = string
  default     = "latest"
}

variable "os_type" {
  description = "Type of OS: linux or windows"
  type        = string
  default     = "linux"
}

variable "tags" {
  description = "A mapping of tags to assign to the resource"
  type        = map(string)
  default     = {}
}

variable "nsg_id" {
  description = "The ID of the network security group (optional)"
  type        = string
  default     = null
}

variable "plan_name" {
  description = "Plan name for marketplace images"
  type        = string
  default     = null
}

variable "plan_product" {
  description = "Plan product for marketplace images"
  type        = string
  default     = null
}

variable "plan_publisher" {
  description = "Plan publisher for marketplace images"
  type        = string
  default     = null
}

variable "patch_mode" {
  description = "Specifies the mode of in-patching to this Virtual Machine. Possible values are ImageDefault, Manual, AutomaticByPlatform and AutomaticByOS."
  type        = string
  default     = null
}

variable "patch_assessment_mode" {
  description = "Specifies the mode of VM Guest Patching Assessment for the Virtual Machine. Possible values are ImageDefault and AutomaticByPlatform."
  type        = string
  default     = null
}

variable "zone" {
  description = "The Availability Zone in which this Virtual Machine should be located."
  type        = string
  default     = null
}
