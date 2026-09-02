# =====================================================
# VNet-Segmentierung via Azure CLI
# Web- und DB-Tier mit NSG-basierter Trennung
# =====================================================

# ---------- Variablen ----------
$RG      = "rg-lab-cli"
$LOC     = "switzerlandnorth"
$VNET    = "vnet-lab-cli"
$SNETWEB = "snet-web"
$SNETDB  = "snet-db"
$NSGWEB  = "nsg-web-cli"
$NSGDB   = "nsg-db-cli"

# ---------- Resource Group ----------
Write-Host "Erstelle Resource Group..." -ForegroundColor Cyan
az group create --name $RG --location $LOC

# ---------- VNet mit Web-Subnetz ----------
Write-Host "Erstelle VNet und Web-Subnetz..." -ForegroundColor Cyan
az network vnet create `
  --resource-group $RG `
  --name $VNET `
  --address-prefix 10.1.0.0/16 `
  --subnet-name $SNETWEB `
  --subnet-prefixes 10.1.1.0/24

# ---------- DB-Subnetz ----------
Write-Host "Erstelle DB-Subnetz..." -ForegroundColor Cyan
az network vnet subnet create `
  --resource-group $RG `
  --vnet-name $VNET `
  --name $SNETDB `
  --address-prefixes 10.1.2.0/24

# ---------- NSGs ----------
Write-Host "Erstelle Network Security Groups..." -ForegroundColor Cyan
az network nsg create --resource-group $RG --name $NSGWEB
az network nsg create --resource-group $RG --name $NSGDB

# ---------- Regel: Web-Tier aus dem Internet erreichbar ----------
Write-Host "Erstelle Regel Allow-HTTP-HTTPS..." -ForegroundColor Cyan
az network nsg rule create `
  --resource-group $RG --nsg-name $NSGWEB `
  --name Allow-HTTP-HTTPS --priority 100 `
  --source-address-prefixes '*' `
  --destination-address-prefixes '*' `
  --destination-port-ranges 80 443 `
  --protocol Tcp --access Allow --direction Inbound

# ---------- Regel: SQL nur aus dem Web-Subnetz ----------
Write-Host "Erstelle Regel Allow-SQL-from-Web..." -ForegroundColor Cyan
az network nsg rule create `
  --resource-group $RG --nsg-name $NSGDB `
  --name Allow-SQL-from-Web --priority 100 `
  --source-address-prefixes 10.1.1.0/24 `
  --destination-address-prefixes 10.1.2.0/24 `
  --destination-port-ranges 1433 `
  --protocol Tcp --access Allow --direction Inbound

# ---------- Regel: Health Probes der Plattform zulassen ----------
Write-Host "Erstelle Regel Allow-AzureLoadBalancer..." -ForegroundColor Cyan
az network nsg rule create `
  --resource-group $RG --nsg-name $NSGDB `
  --name Allow-AzureLoadBalancer --priority 150 `
  --source-address-prefixes AzureLoadBalancer `
  --destination-address-prefixes '*' `
  --destination-port-ranges '*' `
  --protocol '*' --access Allow --direction Inbound

# ---------- Regel: uebrigen VNet-Verkehr blockieren ----------
Write-Host "Erstelle Regel Deny-VNet-Inbound..." -ForegroundColor Cyan
az network nsg rule create `
  --resource-group $RG --nsg-name $NSGDB `
  --name Deny-VNet-Inbound --priority 200 `
  --source-address-prefixes VirtualNetwork `
  --destination-address-prefixes '*' `
  --destination-port-ranges '*' `
  --protocol '*' --access Deny --direction Inbound

# ---------- NSGs den Subnetzen zuordnen ----------
Write-Host "Ordne NSGs den Subnetzen zu..." -ForegroundColor Cyan
az network vnet subnet update `
  --resource-group $RG --vnet-name $VNET `
  --name $SNETWEB --network-security-group $NSGWEB

az network vnet subnet update `
  --resource-group $RG --vnet-name $VNET `
  --name $SNETDB --network-security-group $NSGDB

# ---------- Kontrolle ----------
Write-Host "`nRegeln in $NSGDB :" -ForegroundColor Green
az network nsg rule list --resource-group $RG --nsg-name $NSGDB -o table

Write-Host "`nFertig." -ForegroundColor Green
