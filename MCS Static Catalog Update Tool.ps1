```powershell
Add-Type -AssemblyName presentationframework
Add-PSSnapin citrix*
Import-Module VMware.VimAutomation.Core

[xml] $GUI = @"
<Window WindowStartupLocation="CenterScreen"
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
        xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
        xmlns:local="clr-namespace:MachineCatalogUpdateTool"
        
    Title="Machine Catalog Update Tool" Height="390" Width="565.779" Background="#C9D6DF" ResizeMode="CanMinimize">
    <Grid>
    <Label x:Name="CtxServerName" Content="Enter Citrix Server Name:" HorizontalAlignment="Left" Margin="24,38,0,0" VerticalAlignment="Top" Width="233" FontWeight="Bold" FontSize="16"/>
    <TextBox x:Name="CtxServerNameTxtBx" HorizontalAlignment="Left" Height="23" Margin="262,38,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="256" FontSize="14"/>
    <Label x:Name="MachineCtlgName" Content="Enter Machine Catalog Name:" HorizontalAlignment="Left" Margin="24,79,0,0" VerticalAlignment="Top" FontWeight="Bold" FontSize="16"/>
    <TextBox x:Name="MachineCtlgTxtbxName" HorizontalAlignment="Left" Height="23" Margin="262,85,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="255" FontSize="14"/>
    <!--<Label x:Name="CrtSnpshot" Content="Create Snapshot ? " HorizontalAlignment="Left" Margin="24,237,0,0" VerticalAlignment="Top" Width="233" FontWeight="Bold" FontSize="16"/>-->
    <!--<CheckBox x:Name="CrtSnpshotChxBx" HorizontalAlignment="Left" Margin="262,246,0,0" VerticalAlignment="Top"/>-->
    <TextBox x:Name="GetSnpshotTxtBx" HorizontalAlignment="Left" Height="24" Margin="262,193,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="256" FontSize="14" IsReadOnly="True"/>
    <Button x:Name="UpdateCatalogBtn" Content="Update Catalog" HorizontalAlignment="Left" Margin="100,292,0,0" VerticalAlignment="Top" Width="112" FontSize="14"/>
    <Button x:Name="ExitBtn" Content="Exit" HorizontalAlignment="Left" Margin="261,292,0,0" VerticalAlignment="Top" Width="75" FontSize="14"/>
    <Button x:Name="Getsnapshotbtn" Content="Get Existing Snapshot Details:" HorizontalAlignment="Left" Margin="24,193,0,0" VerticalAlignment="Top" Width="215" Height="24" FontWeight="Bold" FontSize="14"/>
    <Label x:Name="vcenterName" Content="Enter vCenter Server Name:" HorizontalAlignment="Left" Margin="24,129,0,0" VerticalAlignment="Top" Width="233" FontWeight="Bold" FontSize="16"/>
    <TextBox x:Name="vcenterservernametxtbx" HorizontalAlignment="Left" Height="23" Margin="262,137,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="255" FontSize="14"/>
    
    </Grid>
</Window>
"@
$obj = (New-Object system.xml.xmlnodereader $GUI)
$initializeGUI = [windows.markup.xamlreader]::Load($obj)

#Cancel Button
$Exit = $initializeGUI.FindName("ExitBtn")
$Exit.Add_Click({ $initializeGUI.Close()})

#Get snapshot details
$Getsnapshotbtn = $initializeGUI.FindName("Getsnapshotbtn")
$Getsnapshotbtn.Add_Click({

    #citrix server name
    $CtxServerNameTxtBx = $initializeGUI.FindName("CtxServerNameTxtBx")
    $ctxserver = $CtxServerNameTxtBx.Text

    #machine catalog name
    $MachineCtlgTxtbxName = $initializeGUI.FindName("MachineCtlgTxtbxName")
    $machinecatalogname = $MachineCtlgTxtbxName.Text

    #vcenter name
    $vcenterservernametxtbx = $initializeGUI.FindName("vcenterservernametxtbx")
    $vcentername = $vcenterservernametxtbx.Text

    #snapshot text box
    $GetSnpshotTxtBx = $initializeGUI.FindName("GetSnpshotTxtBx")

    if ((!$ctxserver) -or (!$vcentername)){
        $GetSnpshotTxtBx.Text = "Please fill all the details and try again."
    } else {
        #Displays current snapshot details from citrix.
        $provname = (Get-ProvScheme -ProvisioningSchemeName $machinecatalogname  -AdminAddress $ctxserver).MasterImageVM
        $vmname = $provname.split("\")[4]
        $GetSnpshotTxtBx.Text = $vmname
    }
})

#update catalog
$UpdateCatalogBtn = $initializeGUI.FindName("UpdateCatalogBtn")
$UpdateCatalogBtn.Add_Click({

     #citrix server name
     $CtxServerNameTxtBx = $initializeGUI.FindName("CtxServerNameTxtBx")
     $ctxserver = $CtxServerNameTxtBx.Text
 
     #machine catalog name
     $MachineCtlgTxtbxName = $initializeGUI.FindName("MachineCtlgTxtbxName")
     $machinecatalogname = $MachineCtlgTxtbxName.Text
 
     #vcenter name
     $vcenterservernametxtbx = $initializeGUI.FindName("vcenterservernametxtbx")
     $vcentername = $vcenterservernametxtbx.Text
 
     $provname = (Get-ProvScheme -ProvisioningSchemeName $machinecatalogname  -AdminAddress $ctxserver).MasterImageVM
     $vmname = $provname.split("\")[3]
     $trimmedvmname = $vmname.Split(".")[0]
     $masterimagepath = $provname.Substring(0, $provname.lastIndexOf('\'))
     
     $msgBoxInput =  [System.Windows.MessageBox]::Show('This will remove all existing snapshots on ' +$trimmedvmname +' and create new snapshot and publish in citrix. Would you like to proceed?','Snapshot delete prompt','YesNo','Question')
     if ($msgBoxInput -eq "Yes"){
        Connect-VIServer $vcentername
         if (Get-Snapshot -VM $trimmedvmname) {
         Get-Snapshot -VM $trimmedvmname | Remove-Snapshot -Confirm:$false
         } 
        $date = Get-Date -UFormat %d-%m-%y
        New-Snapshot -VM $trimmedvmname -Name "Citrix_XD_snapshot_$date"
        $newimagename = $masterimagepath+ "\" + 'Citrix_XD_snapshot_'+$date+".snapshot"
        Publish-ProvMasterVMImage -ProvisioningSchemeName $machinecatalogname -MasterImageVM $newimagename -AdminAddress $ctxserver
        [System.Windows.MessageBox]::Show('Updating machine catalog. Please wait..','Update','Ok','Information')
        if ((Get-ProvTask -AdminAddress $ctxserver | Select-Object -Last 1).taskstate -eq "Finished") {
            [System.Windows.MessageBox]::Show('Published new snapshot to '+ $machinecatalogname +'. Provision new machines now. ','Success','Ok','Information')
        } else {
            [System.Windows.MessageBox]::Show('Provisioning failed. Please check vcenter and actions tab in citrix studio for a possible cause.','Failed','Ok','Error')
        }
    
     } else {
        [System.Windows.MessageBox]::Show('Execution stopped. Please try again.. ','Exit','Ok','Error')
    }
})

#Hide Powershell console
Add-Type -Name Window -Namespace Console -MemberDefinition '
[DllImport("Kernel32.dll")]
public static extern IntPtr GetConsoleWindow();

[DllImport("user32.dll")]
public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);
'
$consolePtr = [Console.Window]::GetConsoleWindow()
[Console.Window]::ShowWindow($consolePtr, 0)

$initializeGUI.showdialog() | out-null
```
