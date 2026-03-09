Import-Module "VMware.PowerCLI"  
Connect-VIServer -Server vcenter.boe.es -user remote@vsphere.local -Password xxxxx

$vm=$args[0]

Start-VM $vm 
