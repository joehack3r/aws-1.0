#!/usr/bin/env bash

#export AWS_ACCESS_KEY=""
#export AWS_SECRET_KEY=""
export EC2_HOME=/opt/aws/apitools/ec2
export JAVA_HOME=/usr/lib/jvm/jre
export PATH=$PATH:$EC2_HOME/bin:$JAVA_HOME/bin


#Page for requesting increase to limits: http://aws.amazon.com/contact-us/

##Default Limits
#EBS Volumes
EbsVolumeCountLimit=5000
EbsSnapshotCountLimit=10000
#Size Limit in in GiB
EbsStandardStorageSizeLimit=20000
EbsProvisionedIopsStorageSizeLimit=20000
EbsProvisionedIopsIopsLimit=10000
#EC2 Instances
Ec2OnDemandInstanceCountLimit=20
Ec2SpotInstanceCountLimit=100
#EC2 Reserved Instances
Ec2ReservedInstancesLimit=20
#Elastic IPs
Ec2ElasticIpLimit=5
#Elastic Load Balancers (ELBs)
ElbLimit=10


#For the limits we want monitored, do the following:
#Get current usage
#Convert to percentage
#Echo raw usage and percentage to stdout, and statsd


EbsVolumeCountUsed=`ec2-describe-volumes --headers | grep "VOLUME" | wc -l`
if [ $PIPESTATUS[0] != 0 ];
then
  echo "the ec2-describe-volumes command failed with an error";
else
  EbsVolumeCountPercentUsed=`echo 100 \* $EbsVolumeCountUsed / $EbsVolumeCountLimit | bc`
  echo "EBS Volume Count Used:"                                 $EbsVolumeCountUsed
  echo "EBS Volume Count Percentage Used:"                      $EbsVolumeCountPercentUsed
  statsd-client "ebs.volumecount.used:$EbsVolumeCountUsed|g"
  statsd-client "ebs.volumecount.used.percentage:$EbsVolumeCountPercentUsed|g"
fi

EbsSnapshotCountUsed=`ec2-describe-snapshots --headers | grep "SNAPSHOT" | wc -l`
if [ $PIPESTATUS[0] != 0 ];
then
  echo "the ec2-describe-snapshots command failed with an error";
else
  EbsSnapshotCountPercentUsed=`echo 100 \* $EbsSnapshotCountUsed / $EbsSnapshotCountLimit | bc`
  echo "EBS Snapshot Count Used:"                               $EbsSnapshotCountUsed
  echo "EBS Snapshot Count Percentage Used:"                    $EbsSnapshotCountPercentUsed
  statsd-client "ebs.snapshotcount.used:$EbsSnapshotCountUsed|g"
  statsd-client "ebs.snapshotcound.used.percentage:$EbsSnapshotCountPercentUsed|g"
fi

EbsStandardStorageSizeUsed=`ec2-describe-volumes --headers | grep "VOLUME.*standard" | awk -F"\t" '{print $3}' | awk '{sum+=$1} END {print sum}'`
if [ $PIPESTATUS[0] != 0 ];
then
  echo "the ec2-describe-volumes command failed with an error";
else
  EbsStandardStorageSizePercentUsed=`echo 100 \* $EbsStandardStorageSizeUsed / $EbsStandardStorageSizeLimit | bc`
  echo "EBS Standard Storage Size Used:"                        $EbsStandardStorageSizeUsed
  echo "EBS Standard Storage Percentage Size Used:"             $EbsStandardStorageSizePercentUsed
  statsd-client "ebs.standardstoragesize.used:$EbsStandardStorageSizeUsed|g"
  statsd-client "ebs.standardstoragesize.used.percentage:$EbsStandardStorageSizePercentUsed|g"
fi

Ec2OnDemandInstanceCountUsed=`ec2-describe-instances --headers | grep "INSTANCE" | awk -F"\t" '{print $22;}' | grep -v spot | wc -l`
if [ $PIPESTATUS[0] != 0 ];
then
  echo "the ec2-describe-instances command failed with an error";
else
  Ec2OnDemandInstanceCountPercentUsed=`echo 100 \* $Ec2OnDemandInstanceCountUsed / $Ec2OnDemandInstanceCountLimit | bc`
  echo "EC2 OnDemand Instance Count Used:"                      $Ec2OnDemandInstanceCountUsed
  echo "EC2 OnDemand Instance Count Percentage Used:"           $Ec2OnDemandInstanceCountPercentUsed
  statsd-client "ec2.ondemandinstancecount.used:$Ec2OnDemandInstanceCountUsed|g"
  statsd-client "ec2.ondemandinstancecount.used.percentage:$Ec2OnDemandInstanceCountPercentUsed|g"
fi

Ec2SpotInstanceCountUsed=`ec2-describe-instances --headers | grep "INSTANCE" | awk -F"\t" '{print $22;}' | grep spot | wc -l`
if [ $PIPESTATUS[0] != 0 ];
then
  echo "the ec2-describe-instances command failed with an error";
else
  Ec2SpotInstanceCountPercentUsed=`echo 100 \* $Ec2SpotInstanceCountUsed / $Ec2SpotInstanceCountLimit | bc`
  echo "EC2 Spot Instance Count Used:"                          $Ec2SpotInstanceCountUsed
  echo "EC2 Spot Instance Count Percentage Used:"               $Ec2SpotInstanceCountPercentUsed
  statsd-client "ec2.spotinstancecount.used:$Ec2SpotInstanceCountUsed|g"
  statsd-client "ec2.spotinstancecount.used.percentage:$Ec2SpotInstanceCountPercentUsed|g"
fi

Ec2ElasticIpUsed=`ec2-describe-addresses --headers | grep "ADDRESS" | awk -F"\t" '{print $2;}' | wc -l`
if [ $PIPESTATUS[0] != 0 ];
then
  echo "the ec2-describe-addresses command failed with an error";
else
  Ec2ElasticIpPercentUsed=`echo 100 \* $Ec2ElasticIpUsed / $Ec2ElasticIpLimit | bc`
  echo "EC2 Elastic IP Used:"                                   $Ec2ElasticIpUsed
  echo "EC2 Elastic IP Percentage Used:"                        $Ec2ElasticIpPercentUsed
  statsd-client "ec2.elasticip.used.percentage:$Ec2ElasticIpPercentUsed|g"
  statsd-client "ec2.elasticip.used:$Ec2ElasticIpUsed|g"
fi
