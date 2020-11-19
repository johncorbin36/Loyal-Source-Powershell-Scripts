
# Mail variables
$MailFrom = "EMAIL_FROM"
$MailTo = "EMAIL_TO"

$SmtpServer = "outlook.office365.com"
$SmtpPort = 587

$Subject = "Monthly Report of Licensed Inactive Users"
$Body = "Attached is the monthly licensed inactive users report."
$Attachment = "${FilePath}"

# Send email
Send-MailMessage -From $MailFrom -to $MailTo -Subject $Subject `
-Body $Body -SmtpServer $SmtpServer -port $SmtpPort `
-Credential $Login -UseSsl -Attachment $Attachment
