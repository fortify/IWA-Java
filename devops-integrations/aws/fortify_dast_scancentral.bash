#!/bin/bash
# Integrate Fortify ScanCentral Dynamic AppSec Testing (DAST) into your AWS Codestar pipeline
# The following environment variables must be defined in AWS Parameter Store before using this script
#   - /fortify/ssc_user
#   - /fortify/ssc_password
#   - /fortify/ci_token
#   - /fortify/ssc_url
#   - $SC_DAST_CICD_IDENTIFIER
FCLI_DEFAULT_SSC_USER=$(aws ssm get-parameters --region us-east-1 --names /fortify/ssc_user --query Parameters[0].Value)
FCLI_DEFAULT_SSC_PASSWORD=$(aws ssm get-parameters --region us-east-1 --names /fortify/ssc_password --query Parameters[0].Value)
FCLI_DEFAULT_SSC_CI_TOKEN=$(aws ssm get-parameters --region us-east-1 --names /fortify/ci_token --query Parameters[0].Value)
FCLI_DEFAULT_SSC_URL=$(aws ssm get-parameters --region us-east-1 --names /fortify/ssc_url --query Parameters[0].Value)

export FCLI_DEFAULT_SSC_USER=$FCLI_DEFAULT_SSC_USER
export FCLI_DEFAULT_SSC_PASSWORD=$FCLI_DEFAULT_SSC_PASSWORD
export FCLI_DEFAULT_SSC_CI_TOKEN=$FCLI_DEFAULT_SSC_CI_TOKEN
export FCLI_DEFAULT_SSC_URL=$FCLI_DEFAULT_SSC_URL

# Local variables (modify as needed)
FCLI_VERSION=v2.4.0
SCANCENTRAL_VERSION=24.2.0
FCLI_URL=https://github.com/fortify-ps/fcli/releases/download/${FCLI_VERSION}/fcli-linux.tgz
FCLI_SIG_URL=${FCLI_URL}.rsa_sha256
FORTIFY_TOOLS_DIR="/opt/fortify/tools"	
FCLI_HOME=$FORTIFY_TOOLS_DIR/fcli
SCANCENTRAL_HOME=$FORTIFY_TOOLS_DIR/ScanCentral
SC_DAST_CICD_IDENTIFIER='<<15xxxxx-2xxx-4xxx-xxxx-77xxxxxxx814>>'
SC_DAST_SCAN_NAME='AWS_SCAN'

# *** Supported Functions ***
verifySig() {
  local src sig
  src="$1"; sig="$2"
  openssl dgst -sha256 -verify <(echo "-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEArij9U9yJVNc53oEMFWYp
NrXUG1UoRZseDh/p34q1uywD70RGKKWZvXIcUAZZwbZtCu4i0UzsrKRJeUwqanbc
woJvYanp6lc3DccXUN1w1Y0WOHOaBxiiK3B1TtEIH1cK/X+ZzazPG5nX7TSGh8Tp
/uxQzUFli2mDVLqaP62/fB9uJ2joX9Gtw8sZfuPGNMRoc8IdhjagbFkhFT7WCZnk
FH/4Co007lmXLAe12lQQqR/pOTeHJv1sfda1xaHtj4/Tcrq04Kx0ZmGAd5D9lA92
8pdBbzoe/mI5/Sk+nIY3AHkLXB9YAaKJf//Wb1yiP1/hchtVkfXyIaGM+cVyn7AN
VQIDAQAB
-----END PUBLIC KEY-----") -signature "${sig}" "${src}"
}

installFcli() {
  local src sigSrc tgt tmpRoot tmpFile tmpDir
  src="$1"; sigSrc="$2"; tgt="$3"; 
  tmpRoot=$(mktemp -d); tmpFile="$tmpRoot/archive.tmp"; tmpDir="$tmpRoot/extracted"
  echo "Downloading file"
  wget -O $tmpFile $src
  echo "Verifying Signature..."
  verifySig "$tmpFile" <(curl -fsSL -o - "$sigSrc")
  echo "Unzipping: tar -zxf " + $tmpFile + " -C " + $tmpDir
  mkdir $tmpDir
  mkdir -p $tgt
  
  tar -zxf $tmpFile -C $tmpDir
  mv $tmpDir/* $tgt
  rm -rf $tmpRoot
  find $tgt -type f
}

# *** Execution ***
# Install FCLI
installFcli ${FCLI_URL} ${FCLI_SIG_URL} ${FCLI_HOME}/bin

# Use when domain name not available in the public registry
#echo "setting domain..."
#echo ${ssc_ip} + " fortify.cyberxdemo.com" | tee -a /etc/hosts
#cat /etc/hosts

export PATH=$fcli_home/bin:${PATH}

echo Setting connection with Fortify Platform
# USE --INSECURE WHEN YOUR SSL CERTIFICATES ARE SELF GENERATED/UNTRUSTED
fcli ssc session login
fcli sc-dast session login

fcli sc-dast scan start $SC_DAST_SCAN_NAME --settings $SC_DAST_CICD_IDENTIFIER

echo Terminating connection with Fortify Platform
fcli sc-dast session logout
fcli ssc session logout
# *** Execution Completes ***

# *** EoF ***