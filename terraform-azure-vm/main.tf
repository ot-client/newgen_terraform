resource "azurerm_network_interface" "nic" {
  name                = "${var.vm_name}-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = var.public_ip_id
  }

  tags = var.tags
}

resource "azurerm_network_interface_security_group_association" "nic_nsg" {
  count                     = var.nsg_id != null ? 1 : 0
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = var.nsg_id
}

resource "azurerm_linux_virtual_machine" "vm" {
  count                           = var.os_type == "linux" ? 1 : 0
  name                            = var.vm_name
  resource_group_name             = var.resource_group_name
  location                        = var.location
  size                            = var.size
  admin_username                  = var.admin_username
  admin_password                  = var.admin_password
  disable_password_authentication = false
  network_interface_ids           = [azurerm_network_interface.nic.id]
  zone                            = var.zone
  patch_mode                      = var.patch_mode
  patch_assessment_mode           = var.patch_assessment_mode

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = var.os_disk_storage_account_type
    disk_size_gb         = var.os_disk_size_gb
  }

  source_image_reference {
    publisher = var.image_publisher
    offer     = var.image_offer
    sku       = var.image_sku
    version   = var.image_version
  }

  dynamic "plan" {
    for_each = var.plan_name != null ? [1] : []
    content {
      name      = var.plan_name
      product   = var.plan_product
      publisher = var.plan_publisher
    }
  }

  tags = var.tags
}

resource "azurerm_windows_virtual_machine" "vm" {
  count                 = var.os_type == "windows" ? 1 : 0
  name                  = var.vm_name
  resource_group_name   = var.resource_group_name
  location              = var.location
  size                  = var.size
  admin_username        = var.admin_username
  admin_password        = var.admin_password
  network_interface_ids = [azurerm_network_interface.nic.id]
  zone                  = var.zone
  patch_mode            = var.patch_mode
  patch_assessment_mode = var.patch_assessment_mode

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = var.os_disk_storage_account_type
    disk_size_gb         = var.os_disk_size_gb
  }

  source_image_reference {
    publisher = var.image_publisher
    offer     = var.image_offer
    sku       = var.image_sku
    version   = var.image_version
  }

  dynamic "plan" {
    for_each = var.plan_name != null ? [1] : []
    content {
      name      = var.plan_name
      product   = var.plan_product
      publisher = var.plan_publisher
    }
  }

  tags = var.tags
}

resource "azurerm_managed_disk" "data_disk" {
  for_each             = var.data_disks
  name                 = "${var.vm_name}-disk-${each.key}"
  location             = var.location
  resource_group_name  = var.resource_group_name
  storage_account_type = each.value.storage_account_type
  create_option        = "Empty"
  disk_size_gb         = each.value.size_gb

  tags = var.tags
}

resource "azurerm_virtual_machine_data_disk_attachment" "attachment" {
  for_each           = var.data_disks
  managed_disk_id    = azurerm_managed_disk.data_disk[each.key].id
  virtual_machine_id = element(concat(azurerm_linux_virtual_machine.vm.*.id, azurerm_windows_virtual_machine.vm.*.id), 0)
  lun                = each.value.lun
  caching            = "ReadWrite"
}
