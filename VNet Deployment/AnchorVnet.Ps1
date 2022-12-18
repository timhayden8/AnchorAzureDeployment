#Imports CSV as a variable
$Vnetcsv = import-csv $psscriptroot\vnet.CSV
#Connects to Azure Account
Connect-AzAccount
#Creates Research Group and assigns to variable
$ResourceGroupName = New-AzResourcegroup -Name (RG += $vnetcsv.CompanyName) -location "USWest3"
#Creates NSG
Write-host "Creating network security group"
$NetworkSG = New-AzNetworkSecurityGroup -ResourceGroupName $ResourceGroupName -Location "WestUS3" -Name (NSG- $vnetcsv.companyname)
#Creates subnet and VNET
Write-host "Creating virtual network"
$SubnetConfig = New-AzVirtualNetworkSubnetConfig -Name "LAN-SN" -AddressPrefix ($vnetcsv.subnetrange[0]) -NetworkSecurityGroupId $NetworkSG.Id
$VirtualNetwork = New-AzVirtualNetwork -ResourceGroupName $ResourceGroupName -Location "WestUS3" -Name (VNET+$Vnetcsv.companyname) -AddressPrefix ($vnetcsv.vnetrange[0]) -Subnet $SubnetConfig
#Creates Public IP Addresses
$PublicIPVNG = New-AzPublicIpAddress -ResourceGroupName $ResourceGroupName -Location "WestUS3" -AllocationMethod "Static" -Name VNG-PIP
$PublicIPVNGW = New-AzPublicIpAddress -ResourceGroupName $ResourceGroupName -Location "WestUS3" -AllocationMethod "Static" -Name NGW-PIP
#Create NAT Gateway
New-AzNatGateway -ResourcegroupName $ResourceGroupName -Name (NGW-+$Vnetcsv.companyname) -IdleTimeoutInMinutes 4 -sku "Basic" -Location "WestUS3" -PublicIPAddress $PublicIPVNGW
#Creates Virtual Network Gateway, Local Netowrk Gateway, Gateway Subnet, and VPN Connection
$GWSubnet = Add-AzVirtualNetworkSubnetConfig -Name 'GatewaySubnet' -AddressPrefix $Vnetcsv.GatewaySubnet -VirtualNetwork $VirtualNetwork
$virtualnetwork | Set-AzVirtualNetwork
$VNGIPConfig = New-AzVirtualNetworkGatewayIpConfig -Name (VNG+$Vnetcsv.companyname) -SubnetId $gwsubnet.Id -PublicIpAddressId $PublicIPVNG.Id
New-AzVirtualNetworkGateway -name (VNG-+$Vnetcsv.companyname) -resourcegroupname $resourcegroupname -location "WestUS3" -IPConfigurations $VNGIPConfig -GatewayType VPN -VPNTYpe RouteBased -GatewaySku VPNGw1
$VNG = get-azvirtualnetworkgateway -name (VNG-+$vnetcsv.companyname)
New-AZLocalNetworkGateway -name (LNG-$VNetcsv.OnPremLocation) -ResourceGroupName $ResourceGroupName -Location "WestUS3" -GatewayIPAddress $Vnet.OnPremIP -AddressPrefix $vnet.OnPremSubnet
$LNG = get-azlocalnetworkgateway -name (NG-$Vnetcsv.onpremlocation)
New-AzVirtualNetworkGatewayConnection -name (VPN_TO_$vnetcsv.onpremlocation) -ResourceGroupname $resourcegroupname -location "WestUS3" -VirtualNetworkGateway1 $Vng -LocalNetworkGateway2 $LNG -ConnectionType IPsec -SharedKey $vnetcsv.SharedKey