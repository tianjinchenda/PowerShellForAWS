
$uname="tianji***@**.com"
$pwd=ConvertTo-SecureString  "Password" -AsPlainText -Force;
$cred=New-Object System.Management.Automation.PSCredential($uname,$pwd);

$DeadLine = aws ec2 describe-reserved-instances | findstr End
$Shadow=aws ec2 describe-reserved-instances | findstr End
write-output "*******预留实例可用时长检测程序*********"
for($i=0;$i -lt $DeadLine.Length; $i++)
{
  $Shadow[$i]=$DeadLine.GetValue($i).Substring(20,10)
}

for($x=0;$x -le $Shadow.Length-1;$x++)
{
  $SingleObject=$Shadow[$x]
  $time = (New-TimeSpan  $SingleObject).TotalDays
  $time =  [Math]::Abs($time)
  If($time -lt 20)
  {send-mailmessage -to tianji***@**.com -from tianji***@**.com -subject "ReserverInstanceUsingUp" -smtpserver smtp.sina.com -Credential $cred
Write-output “发现时长将用尽的预留实例， 发送报警中…”
  }
  else{ write-output "检测通过"}
}

write-output "扫描结束，该窗口将会在10秒后自动关闭…"
write-output "*******预留实例可用时长检测程序*********"

sleep(10)
exit

