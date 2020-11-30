
# Mail variables
$MailFrom = "EMAIL_FROM"
$MailTo = "EMAIL_TO"

$SmtpServer = "outlook.office365.com"
$SmtpPort = 587

$Subject = "SUBJECT TEXT"
$Body = "BODY TEXT"

# Send email
Send-MailMessage -From $MailFrom -to $MailTo -Subject $Subject `
-Body $Body -SmtpServer $SmtpServer -port $SmtpPort `
-Credential $Login -UseSsl -Attachment $FilePath
