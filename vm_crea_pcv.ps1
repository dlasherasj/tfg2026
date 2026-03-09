Import-Module "VMware.PowerCLI"  
Connect-VIServer -Server vcenter.boe.es -user remote@vsphere.local -Password Boereboot.1

$vm=$args[0]

New-VM -Name $vm -Template 'w11ent-T1' -OSCustomizationSpec 'w11_dhcp' -VMHost 'vfarmm05.boe.es' -Datastore 'purem_pcvs' -Location 'VDI'


Get-VM $vm | Get-NetworkAdapter | select -Exp  MacAddress
