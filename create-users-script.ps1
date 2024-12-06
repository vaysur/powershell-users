# Import the Active Directory module
Import-Module ActiveDirectory

# CSV bestand inlezen
$csvPath = "C:\pad\naar\bestand.csv"  # Geef hier het volledige pad naar je CSV-bestand op
$users = Import-Csv -Path $csvPath

# Loop door elke gebruiker in het CSV-bestand
foreach ($user in $users) {
    $FirstName = $user.Voornaam
    $LastName = $user.Achternaam
    $Department = $user.Afdeling
    $Title = $user.Functie
    $PhoneNumber = $user.Telefoonnummer
    $Address = $user.Adres
    $PostalCode = $user.Postcode
    $City = $user.Plaatsnaam

    # Zoek de juiste OU op basis van de afdeling (afdeling kan ook anders worden toegewezen als dat nodig is)
    $OU = Get-ADOrganizationalUnit -Filter {Name -eq $Department} | Select-Object -First 1

    if ($OU) {
        $OUName = $OU.Name
        $OUPath = $OU.DistinguishedName

        # Gebruikersnaam maken (bijvoorbeeld voornaam.achternaam)
        $UserName = ($FirstName.Substring(0,1) + $LastName).ToLower()

        # Gebruiker aanmaken in de juiste OU
        New-ADUser -SamAccountName $UserName `
                   -UserPrincipalName "$UserName@domain.local" `
                   -Name "$FirstName $LastName" `
                   -GivenName $FirstName `
                   -Surname $LastName `
                   -Department $Department `
                   -Title $Title `
                   -OfficePhone $PhoneNumber `
                   -StreetAddress $Address `
                   -PostalCode $PostalCode `
                   -City $City `
                   -AccountPassword (ConvertTo-SecureString "DefaultPassword123" -AsPlainText -Force) `
                   -Enabled $true `
                   -Path $OUPath

        Write-Output "Created user $FirstName $LastName in OU $OUName"

    } else {
        Write-Warning "OU for department '$Department' not found. Skipping user $FirstName $LastName."
    }
}
