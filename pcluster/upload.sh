#!/bin/bash


# Run this file to copy all required assets into $s3_bucket and make cfn.yaml reference those assets

# Output cfn.yaml : Can be used on a new clean account by a different user.

s3_bucket=8192-stesachs #covid19hpc-bucket-stesachs #covid19hpc-quickstart-161153343288

# Edit cfn.yaml to include correct bucket
edit_cfn()
{
    awk -v s3=${s3_bucket} '1;/Description: S3 bucket for asset/{ print "    Default: \"" s3 "\""}' cfn.yaml > cfn-changed.yaml
    mv cfn-changed.yaml cfn.yaml

}

upload()
{
    # Report id, local path and s3_key for each asset
    eval "$(python3 report_s3.py ${s3_bucket})"

    for ((i=0; i<${#asset_id[@]}; i++))
    do
	echo "${asset_id[$i]} ${asset_key[$i]}"
	# Edit cfn.yaml to include correct keys
	awk -v key=${asset_key[$i]}  '1;/Description: S3 key for asset version "'${asset_id[$i]}'"/{ print "    Default: \"" key "||\""}' cfn.yaml > cfn-changed.yaml
	mv cfn-changed.yaml cfn.yaml

    done
}

cdk synthesize > cfn.yaml
edit_cfn
upload

echo "Use cfn.yaml for CloudFormation"
