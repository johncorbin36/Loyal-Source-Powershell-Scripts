# Set params
param([String]$WelcomeSheetFolder="C:\Welcome-Sheets\")

# Set login credentials
$UserLogin = 'EMAIL'
$PasswordLogin = 'PASSWORD'
$PasswordSecure = ConvertTo-SecureString -String $PasswordLogin -AsPlainText -Force
$Login = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $UserLogin, $PasswordSecure

# Set static email body outside of loop
$Body = @"

BODY OF EMAIL

"@

# Loop for each employee in list
Import-Csv "C:\temp\New-Hires.csv" | ForEach-Object {

    # Set date variables
    $CurrentDate = Get-Date
    $DateArray = $_.StartDate.Split("/")

    # Check if date matches (MM/DD/YYY)
    if (($DateArray[0] -eq $CurrentDate.Month) -and ($DateArray[1] -eq $CurrentDate.Day) -and ($DateArray[2] -eq $CurrentDate.Year)) {

        # Get employee information
        $EmployeeName = $_.Name

        # Mail variables
        $MailFrom = "EMAIL"
        $MailTo = $_.Email

        $SmtpServer = "outlook.office365.com"
        $SmtpPort = 587

        $Subject = "Welcome $EmployeeName" 

        $WelcomeSheet = "${WelcomeSheetFolder}Welcome ${EmployeeName}.docx"

        # Send email
        Send-MailMessage -From $MailFrom -to $MailTo -Subject $Subject `
        -Body $Body -SmtpServer $SmtpServer -port $SmtpPort `
        -Credential $Login -UseSsl -Attachment $WelcomeSheet

        Write-Host "New hire email sent for $EmployeeName"

    } else {

        Write-Host "New hire email NOT sent for $EmployeeName"

    }

}
