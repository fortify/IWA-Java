#!/bin/bash
# Integrate Fortify ScanCentral Dynamic AppSec Testing (DAST) into your AWS Codestar pipeline
FCLI_DEFAULT_SSC_USER=$(aws ssm get-parameters --region us-east-1 --names /fortify/ssc_user --query Parameters[0].Value)
FCLI_DEFAULT_SSC_PASSWORD=$(aws ssm get-parameters --region us-east-1 --names /fortify/ssc_password --query Parameters[0].Value)
FCLI_DEFAULT_SSC_CI_TOKEN=$(aws ssm get-parameters --region us-east-1 --names /fortify/ci_token --query Parameters[0].Value)
FCLI_DEFAULT_SSC_URL=$(aws ssm get-parameters --region us-east-1 --names /fortify/ssc_url --query Parameters[0].Value)
SSC_APP_VERSION_ID=$(aws ssm get-parameters --region us-east-1 --names /fortify/ssc_app_versionid --query Parameters[0].Value)

export FCLI_DEFAULT_SSC_USER=$FCLI_DEFAULT_SSC_USER
export FCLI_DEFAULT_SSC_PASSWORD=$FCLI_DEFAULT_SSC_PASSWORD
export FCLI_DEFAULT_SSC_CI_TOKEN=$FCLI_DEFAULT_SSC_CI_TOKEN
export FCLI_DEFAULT_SSC_URL=$FCLI_DEFAULT_SSC_URL
export SSC_APP_VERSION_ID=$SSC_APP_VERSION_ID

# Local variables (modify as needed)
SC_DAST_CICD_IDENTIFIER='1545cd48-20d2-494b-b0c6-77c26933a814'
SC_DAST_SCAN_NAME='AWS_SCAN'
fcli_version='v1.1.0'
fcli_sha='5553766f0f771abdf27f4c6b6d38a34825a64aaa5d72cfd03c68d7e2f43a49a0'

# Local variables (DO NOT MODIFY)
fortify_tools_dir="/root/.fortify/tools"	
fcli_home=$fortify_tools_dir/fcli
fcli_install='fcli-linux.tgz'

# *** Execution ***

# Download Fortify CLI 
wget "https://github.com/fortify-ps/fcli/releases/download/$fcli_version/fcli-linux.tgz"
e=$?        # return code last command
if [ "${e}" -ne "0" ]; then
	echo "ERROR: Failed to download Fortify CLI - exit code ${e}"
	exit 100
fi
# Verify integrity
sha256sum -c <(echo "$fcli_sha $fcli_install")
e=$?        # return code last command
if [ "${e}" -ne "0" ]; then
	echo "ERROR: Fortify CLI hash does not match - exit code ${e}"
	exit 100
fi
mkdir -p $fcli_home/bin
tar -xvzf "$fcli_install" -C $fcli_home/bin
export PATH=$fcli_home/bin:${PATH}

echo Setting connection with Fortify Platform
# USE --INSECURE WHEN YOUR SSL CERTIFICATES ARE SELF GENERATED/UNTRUSTED
fcli ssc session login
fcli sc-dast session login

fcli sc-dast scan start $SC_DAST_SCAN_NAME --settings $SC_DAST_CICD_IDENTIFIER

echo Terminating connection with Fortify Platform
fcli sc-dast session logout
fcli ssc session logout