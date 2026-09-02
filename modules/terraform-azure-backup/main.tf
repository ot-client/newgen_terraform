resource "azurerm_recovery_services_vault" "vault" {
  name                         = var.vault_name
  location                     = var.location
  resource_group_name          = var.resource_group_name
  sku                          = var.vault_sku
  storage_mode_type            = var.storage_mode_type
  cross_region_restore_enabled = var.cross_region_restore_enabled
  tags                         = var.tags
}

locals {
  selected_backup_policy_name = coalesce(
    var.backup_policy_name,
    var.backup_policy_selection == "prod" ? var.prod_policy_name : var.vm_policy_name
  )

  selected_backup_policy_id = local.selected_backup_policy_name == var.vm_policy_name ? azurerm_backup_policy_vm.vm_policy.id : (
    local.selected_backup_policy_name == var.prod_policy_name ? azurerm_backup_policy_vm.prod_policy[0].id : null
  )
}

# Backup Policy for VMs
resource "azurerm_backup_policy_vm" "vm_policy" {
  name                           = var.vm_policy_name
  resource_group_name            = var.resource_group_name
  recovery_vault_name            = azurerm_recovery_services_vault.vault.name
  timezone                       = var.timezone
  policy_type                    = var.policy_type
  consistency_type               = var.consistency_type
  instant_restore_retention_days = var.instant_restore_retention_days

  backup {
    frequency     = var.backup_frequency
    time          = var.backup_time
    hour_interval = var.backup_hour_interval
    hour_duration = var.backup_hour_duration
    weekdays      = var.backup_weekdays
  }

  dynamic "instant_restore_resource_group" {
    for_each = var.instant_restore_resource_group_prefix == null ? [] : [1]

    content {
      prefix = var.instant_restore_resource_group_prefix
      suffix = var.instant_restore_resource_group_suffix
    }
  }

  retention_daily {
    count = var.retention_daily_count
  }

  dynamic "retention_weekly" {
    for_each = var.retention_weekly_count == null ? [] : [1]

    content {
      count    = var.retention_weekly_count
      weekdays = var.retention_weekly_weekdays
    }
  }

  dynamic "retention_monthly" {
    for_each = var.retention_monthly_count == null ? [] : [1]

    content {
      count             = var.retention_monthly_count
      weekdays          = length(var.retention_monthly_weeks) > 0 ? var.retention_monthly_weekdays : null
      weeks             = length(var.retention_monthly_weeks) > 0 ? var.retention_monthly_weeks : null
      days              = length(var.retention_monthly_weeks) == 0 ? var.retention_monthly_days : null
      include_last_days = length(var.retention_monthly_weeks) == 0 ? var.retention_monthly_include_last_days : null
    }
  }

  dynamic "retention_yearly" {
    for_each = var.retention_yearly_count == null ? [] : [1]

    content {
      count             = var.retention_yearly_count
      months            = var.retention_yearly_months
      weekdays          = length(var.retention_yearly_weeks) > 0 ? var.retention_yearly_weekdays : null
      weeks             = length(var.retention_yearly_weeks) > 0 ? var.retention_yearly_weeks : null
      days              = length(var.retention_yearly_weeks) == 0 ? var.retention_yearly_days : null
      include_last_days = length(var.retention_yearly_weeks) == 0 ? var.retention_yearly_include_last_days : null
    }
  }

  dynamic "tiering_policy" {
    for_each = var.tiering_policy_archived_restore_point_mode == null ? [] : [1]

    content {
      archived_restore_point {
        mode          = var.tiering_policy_archived_restore_point_mode
        duration      = var.tiering_policy_archived_restore_point_duration
        duration_type = var.tiering_policy_archived_restore_point_duration_type
      }
    }
  }
}

# Protect VMs - map of vm_name => vm_id passed from wrapper tfvars
resource "azurerm_backup_protected_vm" "vm" {
  for_each            = var.vm_ids
  resource_group_name = var.resource_group_name
  recovery_vault_name = azurerm_recovery_services_vault.vault.name
  source_vm_id        = each.value
  backup_policy_id    = local.selected_backup_policy_id
}

# -----------------------------------------------------------------------
# PROD BACKUP POLICY
# -----------------------------------------------------------------------
resource "azurerm_backup_policy_vm" "prod_policy" {
  count               = var.prod_policy_name != null ? 1 : 0
  name                = var.prod_policy_name
  resource_group_name = var.resource_group_name
  recovery_vault_name = azurerm_recovery_services_vault.vault.name
  timezone            = var.prod_timezone

  backup {
    frequency = "Daily"
    time      = var.prod_backup_time
  }

  retention_daily {
    count = var.prod_retention_daily_count
  }

  dynamic "retention_weekly" {
    for_each = var.prod_retention_weekly_count == null ? [] : [1]
    content {
      count    = var.prod_retention_weekly_count
      weekdays = var.prod_retention_weekly_weekdays
    }
  }

  dynamic "retention_monthly" {
    for_each = var.prod_retention_monthly_count == null ? [] : [1]
    content {
      count             = var.prod_retention_monthly_count
      weekdays          = length(var.prod_retention_monthly_weeks) > 0 ? var.prod_retention_monthly_weekdays : null
      weeks             = length(var.prod_retention_monthly_weeks) > 0 ? var.prod_retention_monthly_weeks : null
      days              = length(var.prod_retention_monthly_weeks) == 0 ? var.prod_retention_monthly_days : null
      include_last_days = length(var.prod_retention_monthly_weeks) == 0 ? var.prod_retention_monthly_include_last_days : null
    }
  }

  dynamic "retention_yearly" {
    for_each = var.prod_retention_yearly_count == null ? [] : [1]
    content {
      count             = var.prod_retention_yearly_count
      months            = var.prod_retention_yearly_months
      weekdays          = length(var.prod_retention_yearly_weeks) > 0 ? var.prod_retention_yearly_weekdays : null
      weeks             = length(var.prod_retention_yearly_weeks) > 0 ? var.prod_retention_yearly_weeks : null
      days              = length(var.prod_retention_yearly_weeks) == 0 ? var.prod_retention_yearly_days : null
      include_last_days = length(var.prod_retention_yearly_weeks) == 0 ? var.prod_retention_yearly_include_last_days : null
    }
  }
}

# -----------------------------------------------------------------------
# AZURE SITE RECOVERY
# Uses the primary vault (same RG) — no separate DR vault required.
# -----------------------------------------------------------------------
resource "azurerm_site_recovery_fabric" "primary" {
  count               = var.enable_site_recovery ? 1 : 0
  name                = "primary-fabric"
  resource_group_name = var.resource_group_name
  recovery_vault_name = azurerm_recovery_services_vault.vault.name
  location            = var.location
}

resource "azurerm_site_recovery_fabric" "secondary" {
  count               = var.enable_site_recovery ? 1 : 0
  name                = "secondary-fabric"
  resource_group_name = var.resource_group_name
  recovery_vault_name = azurerm_recovery_services_vault.vault.name
  location            = var.target_location
}

resource "azurerm_site_recovery_replication_policy" "policy" {
  count                                                = var.enable_site_recovery ? 1 : 0
  name                                                 = var.replication_policy_name
  resource_group_name                                  = var.resource_group_name
  recovery_vault_name                                  = azurerm_recovery_services_vault.vault.name
  recovery_point_retention_in_minutes                  = var.recovery_point_retention_in_minutes
  application_consistent_snapshot_frequency_in_minutes = var.application_consistent_snapshot_frequency_in_minutes
}

resource "azurerm_monitor_diagnostic_setting" "backup" {
  name               = "${var.vault_name}-diag"
  target_resource_id = azurerm_recovery_services_vault.vault.id
  storage_account_id = var.diag_storage_account_id

  enabled_log {
    category = "AzureBackupReport"
  }

  enabled_log {
    category = "CoreAzureBackup"
  }

  enabled_log {
    category = "AddonAzureBackupJobs"
  }

  enabled_log {
    category = "AddonAzureBackupAlerts"
  }

  enabled_log {
    category = "AddonAzureBackupPolicy"
  }

  enabled_log {
    category = "AddonAzureBackupStorage"
  }

  enabled_log {
    category = "AddonAzureBackupProtectedInstance"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}
