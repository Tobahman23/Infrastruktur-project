
#Powershell Skript

$terraformPath = "./terraform/main.tf" #Terraform filens path





function TerraformInitialize {
    try {
        Write-Host "How many pairs of Vms do you want to create?"
    }
    catch {
        Write-Warning "Something went wrong."
    }
}



function NamingVm {

    $content = Get-Content -Path $terraformPath -Raw
    $vmOne = "(resource\s+""virtualbox_vm""\s+""batocera""\s*\{[\s\S]*?name\s*=\s*"")[^""]*(""[\s\S]*?\})" #Regex mönster för resurserna med namnen batocera och tinycore
    $vmTwo = "(resource\s+""virtualbox_vm""\s+""tinycore""\s*\{[\s\S]*?name\s*=\s*"")[^""]*(""[\s\S]*?\})"

    try {
        if ($content -match $vmOne -and $content -match $vmTwo) { #Kollar om Raw filen har matchande rader med vmOne och vmTwo regexen

            $newVmOne = Read-Host "Name the first VM: "
            Start-Sleep -Seconds 1
            $vmOneUpdt = $content -replace $VmOne, ('${1}' + $newVmOne + '${2}') #Byter ut Gamla namnet med input
            [System.IO.File]::WriteAllText($terraformPath, $vmOneUpdt, [System.Text.Encoding]::UTF8) #Skriver in nya namnet i terraform filen
            Write-Host "The name of the VM has changed to '$newVmOne'"
            Start-Sleep -Seconds 1

            $content = Get-Content -Path $terraformPath -Raw #Uppdaterar Content variabeln

            TerraformInitialize

        } else {
            Write-Warning "The Regex does not match the file, make sure the virtualbox_vm resources have the correct name in the terraform file."
            break
        }
    }
    catch {
        Write-Warning "Something went wrong, the name of the file has not changed."
        break
    }
}
NamingVm
