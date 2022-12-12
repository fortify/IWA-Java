#!/bin/bash
# Integrate Fortify on Demand Static AppSec Testing (SAST) into your Travis CI pipeline

# *** Configuration ***

# The following environment variables must be defined in Repository settings
fod_tenant=$FOD_TENANT 			# TENANT ID
fod_user=$FOD_USER				# FOD USER KEY
fod_pat=$FOD_PAT				# FOD PAT
fod_release_id=$FOD_RELEASE_ID	# FOD APPLICATION BASED RELEASE ID

# Local variables (modify as needed)
fod_url='https://ams.fortify.com'
fod_api_url='https://api.ams.fortify.com/'
fod_uploader_opts='-ep 2 -pp 0 -I 1 -apf'
fod_notes="Triggered by Travis CI"
fod_uploader_version='v5.4.0'
scancentral_client_version='22.1.2'
fti_version='v2.14.0'
fti_sha='d9ebd439c5b426a5ea207e6c1a17a466f79363ca5735fea1d7a4d8ef5807dc06'

# Local variables (DO NOT MODIFY)
fortify_tools_dir="/home/travis/.fortify/tools/FoDUploader/$fod_uploader_version"		
fti_install='FortifyToolsInstaller.sh'
fod_util='FoDUpload.jar'

# *** Execution ***

# Download Fortify Tools Installer
wget "https://raw.githubusercontent.com/fortify/FortifyToolsInstaller/$fti_version/FortifyToolsInstaller.sh" 
e=$?        # return code last command
if [ "${e}" -ne "0" ]; then
	echo "ERROR: Failed to download Fortify Tools Installer - exit code ${e}"
	exit 100
fi

# Set permission to execute Fortify Tools Installer and verify integrity
chmod +x "$fti_install"
sha256sum -c <(echo "$fti_sha $fti_install")
e=$?        # return code last command
if [ "${e}" -ne "0" ]; then
	echo "ERROR: Fortify Tool Installer hash does not match - exit code ${e}"
	exit 100
fi

# Download and install Fortify ScanCentral Client
FTI_TOOLS=sc:$scancentral_client_version source $fti_install
e=$?        # return code last command
if [ "${e}" -ne "0" ]; then
	echo "ERROR: Failed to download and install Fortify ScanCentral Client - exit code ${e}"
	exit 100
fi

# Download and install Fortify on Demand Uploader
FTI_TOOLS=fu:$fod_uploader_version source $fti_install
e=$?        # return code last command
if [ "${e}" -ne "0" ]; then
	echo "ERROR: Failed to download and install Fortify on Demand Uploader - exit code ${e}"
	exit 100
fi

# Generate Java Package for upload to Fortify on Demand
scancentral package -bt mvn -oss -o package.zip

# Execute Fortify on Demand SAST scan
java -jar $fortify_tools_dir/$fod_util -z package.zip -aurl $fod_api_url -purl $fod_url -rid $fod_release_id -tc $fod_tenant -uc $fod_user $fod_pat $fod_uploader_opts -n "$fod_notes"
