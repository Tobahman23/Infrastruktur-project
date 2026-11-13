
#Powershell Skript

$terraformPath = "../terraform/main.tf" #Terraform filens path
$systemPath = "./terraform/main.tf" #Terraform filens path för system



function CloneVM {
    param (
        [string]$vm = "temp"
    )
    try {
        Write-Host "Here are the specs for the VM by the name of $vm..."
        Start-Sleep -Seconds 1
        VboxManage showvminfo $vm --machinereadable
        Start-Sleep -Seconds 5
        Write-Host "Would you like to clone the vm in question, and if so how many times?"
        Write-Host "0. No Cloning"
        Write-Host "1. 1 Clone"
        Write-Host "2. 2 Clones"
        Write-Host "3. 3 Clones"
        Write-Host "4. 4 Clones"
        $answer = Read-Host " "
        if ([int]$answer -match '^\d$' -and [int]$answer -lt 5 -and [int]$answer -ge 0) {
            $answer = [int]$answer
            for ($i = 1; $i -le $answer; $i++) {
                $tempName = $vm + [string]$i
                VBoxManage clonevm $vm --name $tempName --register
            }
            Write-Host "Cloning phase done..."
            Start-Sleep -Seconds 1
            Write-Host "Starting the base vm..."
            Start-Sleep -Seconds 2
            VBoxManage startvm $vm --type gui
        } else {
            Write-Warning "$amswer is not a number between 0 and 4. This script only allows up to 4 clones by design."
            Start-Sleep -Seconds 1
            CloneVM -vm $vm
        }
    }
    catch {
        Write-Error "Something went wrong. $_"
        return
    }
}

function TerraformInitialize {
    param(
        [string]$name = "temp",
        [int]$memory = 4096,
        [int]$cpus = 4
    )
    try {
        $vmCreated = $false
        Set-Location ..\terraform
        terraform init
        terraform plan
        #terraform apply
        $tfProcess = Start-Process -FilePath "terraform" -ArgumentList "apply", "-auto-approve" -NoNewWindow -PassThru
        Start-Sleep -Seconds 2
        while (-not $vmCreated) {
            $vminfo = VBoxManage showvminfo $name --machinereadable 2>$null
            if ($vminfo -match "memory=$memory" -and $vminfo -match "cpus=$cpus") {
                $vmCreated = $true
            } else {
                Start-Sleep -Seconds 1
            }
        }
        Write-Host "..."
        taskkill /PID $tfProcess.Id /T /F | Out-Null
        Start-Sleep -Seconds 5
        VBoxManage controlvm $name poweroff 2>$null
        Start-Sleep -Seconds 2
        VBoxManage modifyvm $name --graphicscontroller vmsvga --vram 128 --accelerate3d on
        Write-Host "Vm called $name has been created in Virtualbox."
        Start-Sleep -Seconds 1
        CloneVM -vm $name
    }
    catch {
        Write-Error "Something went wrong. $_"
        return
    }
}



function NamingVm {

    $content = Get-Content -Path $terraformPath -Raw
    $vmOne = "(resource\s+""virtualbox_vm""\s+""batocera""\s*\{[\s\S]*?name\s*=\s*"")[^""]*(""[\s\S]*?\})" #Regex mönster för resurserna med namnen batocera

    try {
        if ($content -match $vmOne) { #Kollar om Raw filen har matchande rader med vmOne

            $newVmOne = Read-Host "Give a name to the VM: "
            $vmOneUpdt = $content -replace $vmOne, ('${1}' + $newVmOne + '${2}') #Byter ut Gamla namnet med input
            [System.IO.File]::WriteAllText($systemPath, $vmOneUpdt, [System.Text.Encoding]::UTF8) #Skriver in nya namnet i terraform filen
            Write-Host "The name of the VM has changed to '$newVmOne'"
            Start-Sleep -Seconds 1

            TerraformInitialize -name $newVmOne
        
        } else {
            Write-Warning "The Regex does not match the file, make sure the virtualbox_vm resources have the correct name in the terraform file."
            return
        }
    }
    catch {
        Write-Error "Something went wrong, the name of the file has not changed. Error: $_"
        return
    }
}
NamingVm
