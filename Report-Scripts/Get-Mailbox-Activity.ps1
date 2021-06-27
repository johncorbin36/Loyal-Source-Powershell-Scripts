param([String]$FilePath="C:\temp\Mailbox-Activity.csv")

Connect-ExchangeOnline

foreach ($MB in Get-Mailbox -ResultSize unlimited) {
    $Stats = Get-MailboxStatistics -Identity $MB.Identity
    Add-Content -Path $FilePath -Value "$($Stats.DisplayName), $($Stats.MailboxTypeDetail), $($Stats.LastUserActionTime), $($Stats.Identity)"
}

Disconnect-ExchangeOnline -Confirm:$false
