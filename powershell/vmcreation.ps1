
#Powershell Skript

$terraformPath = "../terraform/main.tf" #Terraform filens path
$systemPath = "./terraform/main.tf" #Terraform filens path för system



function CloneVM { #Funktion som först klonar angiven mängd och sen startar en bas vm
    param (
        [string]$vm = "temp"
    )
    try {

        Write-Host "Here are the specs for the VM by the name of $vm..." #Skriver ut stats på vm
        Start-Sleep -Seconds 1
        terraform apply -auto-approve -WindowStyle Hidden 2>$null #En andra apply endast för att uppdatera outputs
        
        Start-Sleep -Seconds 2

        $cpus = Terraform output -raw cpus_batocera 
        $memory = Terraform output -raw memory_batocera
        Write-Host "Cpus: $cpus, Memory: $memory" #Loggar outputs


        Start-Sleep -Seconds 5 
        Write-Host "Would you like to clone the vm in question, and if so how many times?" #Frågar efter mängd vm som ska klonas
        Write-Host "0. No Cloning"
        Write-Host "1. 1 Clone"
        Write-Host "2. 2 Clones"
        Write-Host "3. 3 Clones"
        Write-Host "4. 4 Clones"
        $answer = Read-Host " "


        if ([int]$answer -match '^\d$' -and [int]$answer -lt 5 -and [int]$answer -ge 0) { #Kollar om angiven mängd är mellan 0-4, annars körs funktionen om från början
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
        Write-Error "Something went wrong. $_" #Om errors eller exceptions skulle uppstå
        return
    }
}

function TerraformInitialize { #Funktion som initierar terraform, sätter på 3d acceleration och sedan kallar på klon funktionen ovan
    param(
        [string]$name = "temp",
        [string]$nameTwo = "temp",
        [int]$memory = 4096,
        [int]$cpus = 4,
        [int]$memoryTwo = 2048,
        [int]$cpusTwo = 2
    )
    try {

        $vmCreated = $false

        Set-Location ..\terraform #Sätter konsolens location till terraform mappen
        terraform init
        terraform plan

        $tfProcess = Start-Process -FilePath "terraform" -ArgumentList "apply", "-auto-approve" -NoNewWindow -PassThru
        Start-Sleep -Seconds 2 #Startar terraform apply men ser till att andra kommandon kan köras samtidigt för att undvika fel


        while (-not $vmCreated) { #Loopen väntar på att vm vid rätt namn ska ha rätt konfiguration
            $vminfo = VBoxManage showvminfo $name --machinereadable 2>$null
            $vmtwoinfo = VBoxManage showvminfo $nameTwo --machinereadable 2>$null
            if ($vminfo -match "memory=$memory" -and $vminfo -match "cpus=$cpus" -and $vmtwoinfo -match "memory=$memoryTwo" -and $vmtwoinfo -match "cpus=$cpusTwo") {
                $vmCreated = $true
            } else {
                Start-Sleep -Seconds 1
            }
        }

        Write-Host "..."
        taskkill /PID $tfProcess.Id /T /F | Out-Null #Stänger ned terraform utan logg
        Start-Sleep -Seconds 5
        VBoxManage controlvm $name poweroff 2>$null #Stänger av vm, potentiella errors skickas till null
        VBoxManage controlvm $nameTwo poweroff 2>$null
        Start-Sleep -Seconds 2
        VBoxManage modifyvm $name --graphicscontroller vmsvga --vram 128 --accelerate3d on #Modifierar vm för att sätta på vm acceleration, vissa vm som denna kan inte startas rätt utan detta påslaget
        Write-Host "Vm called $name has been created in Virtualbox."
        Write-Host "Vm called $nameTwo has been created in Virtualbox."
        Start-Sleep -Seconds 1
        CloneVM -vm $name #Kallar på klon funktionen, endast för batocera vm
    }
    catch {
        Write-Error "Something went wrong. $_" #Om errors eller exceptions skulle uppstå
        return
    }
}



function NamingVm { #Funktionen sätter namn i main.tf filen och kallar sedan på initialiserings funktionen ovan

    $content = Get-Content -Path $terraformPath -Raw #Hämtar text format på main.tf filen
    $vmOne = "(resource\s+""virtualbox_vm""\s+""batocera""\s*\{[\s\S]*?name\s*=\s*"")[^""]*(""[\s\S]*?\})" #Regex mönster för resurserna med namnen batocera
    $vmTwo = "(resource\s+""virtualbox_vm""\s+""ubuntu""\s*\{[\s\S]*?name\s*=\s*"")[^""]*(""[\s\S]*?\})" #Regex mönster för resurserna med namnen ubuntu

    try {
        if ($content -match $vmOne -and $content -match $vmTwo) { #Kollar om Raw filen har matchande rader med regex mönstrena

            $newVmOne = Read-Host "Give a name to the batocera VM: "
            $newVmTwo = Read-Host "Give a name to the ubuntu VM: "
            $vmUpdt = $content -replace $vmOne, ('${1}' + $newVmOne + '${2}') #Byter ut Gamla namnen på vm med input
            $vmUpdt = $vmUpdt -replace $vmTwo, ('${1}' + $newVmTwo + '${2}')
            [System.IO.File]::WriteAllText($systemPath, $vmUpdt, [System.Text.Encoding]::UTF8) #Skriver in nya namnen i terraform filen
            Write-Host "The name of the batocera VM has changed to '$newVmOne' and the name of the ubuntu vm has changed to '$newVmTwo'"
            Start-Sleep -Seconds 1

            TerraformInitialize -name $newVmOne -nameTwo $newVmTwo
        
        } else {
            Write-Warning "The Regex does not match the file, make sure the virtualbox_vm resources have the correct name in the terraform file, and that console is localized in powershell or terraform." #Dubbelkollar om regex matchar filen, detta kan även hända om skriptet körs utanför powershell eller terraform mappen
            return
        }
    }
    catch {
        Write-Error "Something went wrong, the name of the file has not changed. Error: $_" #Om errors eller exceptions skulle uppstå
        return
    }
}
NamingVm
