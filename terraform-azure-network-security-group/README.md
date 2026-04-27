# Azure Network Security Group Module with Flow Logs

This module creates Azure Network Security Groups (NSGs) with optional NSG Flow Logs support.

## Features

- Create NSGs with custom rules
- Associate NSGs with subnets
- Enable NSG Flow Logs to Storage Account
- Enable Traffic Analytics with Log Analytics Workspace
- Configurable retention and analytics intervals

## NSG Flow Logs

NSG Flow Logs capture information about IP traffic flowing through NSGs. They provide:

- Security monitoring and threat detection
- Network troubleshooting
- Compliance and audit requirements
- Traffic pattern analysis
- Cost optimization insights

### Flow Log Destinations

1. **Storage Account** - Long-term retention, cost-effective storage
2. **Log Analytics Workspace** - Real-time analytics, querying with KQL, alerting

## Usage

### Basic NSG without Flow Logs

```hcl
module "nsg" {
  source = "path/to/module"

  resource_group_name     = "my-rg"
  resource_group_location = "Central India"
  subnets                 = {
    "aks" = "/subscriptions/.../subnets/aks-subnet"
  }
  nsg_rules = {
    "aks" = {
      rules = {
        "allow-https" = {
          name                       = "Allow-HTTPS"
          priority                   = 100
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "443"
          source_address_prefix      = "*"
          destination_address_prefix = "*"
        }
      }
    }
  }
  tags = {
    Environment = "dev"
  }
}
```

### NSG with Flow Logs (Storage Account Only)

```hcl
module "nsg" {
  source = "path/to/module"

  resource_group_name     = "my-rg"
  resource_group_location = "Central India"
  subnets                 = local.subnets
  nsg_rules               = local.nsg_rules
  tags                    = local.tags

  # Enable Flow Logs to Storage Account
  enable_flow_logs            = true
  flow_log_storage_account_id = "/subscriptions/.../storageAccounts/mystorageaccount"
  flow_log_retention_days     = 30
}
```

### NSG with Flow Logs (Storage + Traffic Analytics)

```hcl
module "nsg" {
  source = "path/to/module"

  resource_group_name     = "my-rg"
  resource_group_location = "Central India"
  subnets                 = local.subnets
  nsg_rules               = local.nsg_rules
  tags                    = local.tags

  # Enable Flow Logs with Traffic Analytics
  enable_flow_logs                    = true
  flow_log_storage_account_id         = "/subscriptions/.../storageAccounts/mystorageaccount"
  flow_log_workspace_id               = "/subscriptions/.../workspaces/myworkspace"
  flow_log_retention_days             = 30
  flow_log_traffic_analytics_interval = 60  # 10 or 60 minutes
  network_watcher_name                = "NetworkWatcher_centralindia"
  network_watcher_resource_group      = "NetworkWatcherRG"
}
```

## Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| resource_group_name | Resource group name | string | - | yes |
| resource_group_location | Azure region | string | - | yes |
| subnets | Map of subnet IDs | map(string) | - | yes |
| nsg_rules | NSG rules configuration | any | - | yes |
| tags | Tags to apply | map(string) | {} | no |
| enable_flow_logs | Enable NSG Flow Logs | bool | false | no |
| flow_log_storage_account_id | Storage Account ID for flow logs | string | null | no |
| flow_log_workspace_id | Log Analytics Workspace ID | string | null | no |
| flow_log_retention_days | Retention days in storage | number | 7 | no |
| flow_log_traffic_analytics_interval | Analytics interval (10 or 60 min) | number | 60 | no |
| network_watcher_name | Network Watcher name | string | null | no |
| network_watcher_resource_group | Network Watcher RG | string | NetworkWatcherRG | no |

## Outputs

| Name | Description |
|------|-------------|
| nsg_ids | Map of NSG IDs |
| nsg_names | Map of NSG names |
| flow_log_ids | Map of Flow Log IDs |

## Flow Log Data

Flow logs capture:
- Source and destination IP addresses
- Source and destination ports
- Protocol (TCP/UDP/ICMP)
- Traffic direction (Inbound/Outbound)
- Allow/Deny decision
- Bytes and packets transferred
- Timestamp

## Querying Flow Logs

### Using Azure CLI

```bash
# List flow logs
az network watcher flow-log list --location centralindia

# Show specific flow log
az network watcher flow-log show --location centralindia --name aks-flow-log
```

### Using KQL in Log Analytics

```kql
// Top talkers by bytes
AzureNetworkAnalytics_CL
| where SubType_s == "FlowLog"
| summarize TotalBytes = sum(FlowCount_d) by SrcIP_s, DestIP_s
| top 10 by TotalBytes desc

// Denied connections
AzureNetworkAnalytics_CL
| where SubType_s == "FlowLog" and FlowStatus_s == "D"
| project TimeGenerated, SrcIP_s, DestIP_s, DestPort_d, L7Protocol_s

// Traffic by NSG
AzureNetworkAnalytics_CL
| where SubType_s == "FlowLog"
| summarize Count = count() by NSGList_s, FlowDirection_s
```

## Cost Considerations

- **Storage Account**: ~$0.02 per GB/month
- **Log Analytics**: ~$2.30 per GB ingested
- **Traffic Analytics**: Included with Log Analytics

Typical flow log size: 1-5 GB per NSG per month (varies by traffic volume)

## Prerequisites

1. Network Watcher must be enabled in the region
2. Storage Account must exist
3. Log Analytics Workspace must exist (for Traffic Analytics)
4. Proper permissions on Storage Account and Workspace

## Notes

- Flow logs are created per NSG
- Version 2 flow logs are used (more detailed)
- Traffic Analytics requires Log Analytics Workspace
- Network Watcher is automatically created in NetworkWatcherRG
- Flow logs don't impact network performance

## References

- [NSG Flow Logs Overview](https://learn.microsoft.com/en-us/azure/network-watcher/network-watcher-nsg-flow-logging-overview)
- [Traffic Analytics](https://learn.microsoft.com/en-us/azure/network-watcher/traffic-analytics)
- [Flow Log Schema](https://learn.microsoft.com/en-us/azure/network-watcher/network-watcher-nsg-flow-logging-overview#log-format)
