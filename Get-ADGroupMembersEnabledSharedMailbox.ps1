Import-Module ExchangeOnlineManagement

$login = Read-Host 'Exchange login'
$ADGroup = Read-Host 'AD Group to pull members from'

Connect-ExchangeOnline -UserPrincipalName $login
$members = Get-ADGroupMember $ADGroup
foreach($member in $members) {
    $memberdetails = Get-ADUser -Filter {samaccountname -like $member.SamAccountName} | select Name, @{Name='Alias'; Expression='SamAccountName'}, Enabled
    if ($memberdetails.Enabled -eq "True") {
        $mailboxtype = Get-Mailbox -Identity $memberdetails.Name -ErrorAction SilentlyContinue | Select -ExpandProperty IsShared
        if ($null -eq $mailboxtype) {
            $memberdetails | Add-Member -NotePropertyName MailboxType -NotePropertyValue "Exchange license not found"

        }
        else {
            $memberdetails | Add-Member -NotePropertyName MailboxType -NotePropertyValue $mailboxtype
        }
        
        
        $memberdetails
    }
}
Disconnect-ExchangeOnline
