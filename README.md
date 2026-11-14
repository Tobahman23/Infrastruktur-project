# Infrastruktur Projekt - Skapande av Virtuell maskin

## Förutsättningar/Miljö

- batocera.box och ubuntu.box eller andra boxes med matchande namn installerade (Behövs Vagrant för att skapa box filer men de kan laddas ner separat) **OBS! Dessa filer följer inte med i Github Repot eller inlämningen för att de är för stora filer**
- Terraform.exe installerat och path inlagd i miljövariabler
- Virtualbox installerat och dess mapp inlagd i miljövariabler
- Installerat terraform provider för virtualbox (Använde Golang för detta), **Viktigt för att terraform ska funka i projektet**

## Steg för att få en miljö där skriptet och terraform funkar

0. Ladda ner och installera Virtualbox och Terraform. **Lägg in deras Path i miljövariabler.**

1. Klona detta repo: <https://github.com/terra-farm/terraform-provider-virtualbox>

2. Ladda ner Go(lang)

3. I det kopierade repot, kör kommandot: `go build -o terraform-provider-virtualbox.exe`

4. Kopiera exe filen till `%APPDATA%\terraform.d\plugins\terra-farm.com\virtualbox\0.2.2\windows_amd64\`

5. Kopiera detta repo (Infrastruktur-project)

6. Ladda ner batocera.box eller skapa egen box med samma namn och placera i terraform mappen på detta projekt. (Länken finns i README på Studentportalen)

7. Ladda ner denna box: <https://portal.cloud.hashicorp.com/vagrant/discover/ubuntu/trusty64> och döp om den till ubuntu.box, placera även denna i terraform mappen på detta projekt.

8. Kör vmcreation.ps1 från powershell eller terraform mappen

## Mål med projektet

Mening med mitt projekt är att skapa ett smidigt och simpelt sätt att konfiguera flera virtuella maskiner samtidigt via ett script.

Terraform filen har för tillfället 2 olika boxar(ihoppackade vm) med olika linuxbaserade os system. Detta går dock att ändra enkelt sålänge man har tillgång till flera boxar.

## Verktyg som användes

Detta projekt har använt följande program, verktyg och språk under projektets gång:

- **Terraform**, resources, outputs etc.
- **Powershell**, ps1 skript.
- **Terra-farm** (Terraform provider för Virtualbox), plugin för Terraform som användes för att starta virtuella maskiner i Virtualbox.
- **Virtualbox**, användes för virtualisering av vm.
- **Go(programmeringsspråk)**, användes kort för installation av terra-farm.
- **Vagrant**, användes för konvertering av vdi till box.

## Resultat

Dessa verktyg och skriptet jag skrev resulterade som tänkt, i ett skript som enkelt skapar 2 vm typer med val av namn.

Utöver detta kan den ena vm typen klonas upp till 4 gånger (satt bara en rimlig gräns, skulle gå att göra mycket fler egentligen).

När de två vm typerena är skapade och kanske klonats så startas en vm upp för ett visuellt resultat.

## Reflektion

Om jag gjort om detta projekt hade jag definitivt letat efter ett annat verktyg än terra-farm för att få Virtualbox och Terraform att samarbeta.
Verktyget hade väldigt minimalistiska inställningar vilket gjorde att jag inte kunde sätta in 3d acceleration på mina vm.

Detta gjorde att jag var tvungen att leta efter andra sätt att göra detta vilket resulterade i att jag var tvungen att stänga av terraforms apply fas innan den var klar och sedan köra apply igen bara för att få outputs.

Något som var riktigt enkelt dock var användingen av VBoxManage, som hanterar virtualbox. Det fanns ett kommando för det mesta man ville göra vilket gjorde att jag kunde lösa de flesta problem som uppstod med skapandet av virtuella maskiner.

### Github länk - <https://github.com/Tobahman23/Infrastruktur-project>
