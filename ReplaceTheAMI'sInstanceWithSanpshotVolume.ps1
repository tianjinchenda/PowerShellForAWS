write-output "********ToolForReplaceRootVolumeWithSnapshot*********"
write-output ""
Write-Output "******************************************************
The tools's main purpose is to create a new instance by using the Standard AMI and then stop the instance, detach the ebs volume, and delete it.Then using the snapshot which provided by the user to create a new volume and attach it to the instance. Then start the instance and report the instance's ID
*******************************************************"
Write-Output "Please Press enter to continue..."
$Choose=Read-Host
Write-Output "Firstly, We will try to create a EBS volume base on the SnapshotID"
Write-Output "Please input the snapshot ID which you provided"
$SnapshotID=Read-Host
Write-Output "Please input the Availability Zone which you provided"
$AZ=Read-Host
Write-output "Creating EBS volument ....."
$EBS_Result=aws ec2 create-volume  --availability-zone $AZ --snapshot-id $SnapshotID --volume-type gp2
Write-output "The EBS voulmn which you create is list below."
echo $EBS_Result
$EBSObject=echo $EBS_Result | ConvertFrom-Json
$NewVolumnID=$EBSObject.VolumeID
echo $NewVolumnID


Write-Output "Secondaly, We will try to create a instance base on the AMI which you specify"
Write-Output "Please Input the AMI ID which you want to use." 
$AMIID=Read-Host
Write-Output "Please input the key-name that you want to use."
$KeyName=Read-Host
Write-Output "Please input the Security Group that you want" 
$SecurityGroup=Read-host
Write-Output "Please input the subnetID that you want" 
$SubNet=Read-host
Write-Output "The syste will going to create a instance by using the info that you provided"
$InstanceID=aws ec2 run-instances --image-id $AMIID --count 1 --instance-type t2.micro --key-name $KeyName --security-group-ids $SecurityGroup --subnet-id $SubNet --placement "AvailabilityZone=$AZ"
Write-Output "The EC2's information was listed below"
echo $InstanceID
$Instance=echo $InstanceID | ConvertFrom-Json
$id=$Instance.Instances.InstanceId
echo $id


$DecribeResult=aws ec2 describe-instances --instance-ids $id
$oldEBSID=(echo $DecribeResult | ConvertFrom-Json).Reservations.Instances.BlockDeviceMappings.Ebs.VolumeId
Write-Output "The Old EBS volume's ID is list below"
echo $oldEBSID


Write-Output "Going to stop the instance, However, We should waiting for 1 minutes to let the instance start finished."
sleep(60)
$stop_result=aws ec2 stop-instances --instance-ids $id
echo $stop_result
Write-Output "In order to make sure the instance is sleeped. stop 80s for easy"
sleep(80)

Write-Output "Trying to detach the volume"
$detachResult=aws ec2 detach-volume --volume-id $oldEBSID
echo $detachResult
Write-Output "Inorder to make sure the detach is finished. stop 10s for easy"
sleep(10)

Write-Output "Trying to attach the new volume"
aws ec2 attach-volume --volume-id $NewVolumnID --instance-id $id --device /dev/sda1
Write-Output "Trying to start the instance"
aws ec2 start-instances --instance-ids $id



Write-Output "Trying to delete the old volume"
aws ec2 delete-volume --volume-id $oldEBSID

Write-Output "Now you can trying to contact the below instanceID"
echo $id
$end=read-host