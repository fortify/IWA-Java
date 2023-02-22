package _Self.buildTypes

import jetbrains.buildServer.configs.kotlin.*
import jetbrains.buildServer.configs.kotlin.buildSteps.dockerCommand
import jetbrains.buildServer.configs.kotlin.buildSteps.maven
import jetbrains.buildServer.configs.kotlin.buildSteps.script
import jetbrains.buildServer.configs.kotlin.triggers.vcs

/*
The settings script is an entry point for defining a single
TeamCity project. TeamCity looks for the 'settings.kts' file in a
project directory and runs it if it's found, so the script name
shouldn't be changed and its package should be the same as the
project's external id.

Integrate Fortify ScanCentral Static AppSec Testing (SAST) into your TeamCity build pipeline.
 Rename this file to "settings.kts" before use
 The following environment variables must be defined in Project/Agent settings before using this job
   - env._FCLI_DEFAULT_SC_SAST_CLIENT_AUTH_TOKEN
   - env._FCLI_DEFAULT_SSC_CI_TOKEN
   - env._FCLI_DEFAULT_SSC_URL
   - env._FCLI_DEFAULT_SSC_USER
   - env._FCLI_DEFAULT_SSC_PASSWORD
   - env.SSC_AV_ID
*/

object DevBuild : BuildType({
    name = "dev_build"

    vcs {
        root(HttpsGitlabComMforgIwaJavaTravisGit)
    }

    steps {
        maven {
            name = "build"
            goals = "clean package"
        }
        dockerCommand {
            commandType = build {
                source = file {
                    path = "Dockerfile"
                }
            }
        }
        script {
            name = "Fortify Scan"
            scriptContent = """
				export FCLI_DEFAULT_SC_SAST_CLIENT_AUTH_TOKEN=%env._FCLI_DEFAULT_SC_SAST_CLIENT_AUTH_TOKEN%		# SCANCENTRAL CLIENT AUTH TOKEN
				export FCLI_DEFAULT_SSC_USER=%env._FCLI_DEFAULT_SSC_USER%										# SSC USER NAME
				export FCLI_DEFAULT_SSC_PASSWORD=%env._FCLI_DEFAULT_SSC_PASSWORD%								# SSC PASSWORD
				export FCLI_DEFAULT_SSC_CI_TOKEN=%env._FCLI_DEFAULT_SSC_CI_TOKEN%								# SSC CI TOKEN
				export FCLI_DEFAULT_SSC_URL=%env._FCLI_DEFAULT_SSC_URL%											# SSC URL
				export SC_SAST_SENSOR_VERSION='22.2.0'
				
				# USE --INSECURE WHEN YOUR SSL CERTIFICATES ARE SELF GENERATED/UNTRUSTED
				fcli ssc session login
                fcli sc-sast session login
				
                scancentral package -bt mvn -o package.zip
				
				fcli sc-sast scan start --package-file=package.zip --upload --sensor-version=${'$'}SC_SAST_SENSOR_VERSION --appversion=%env.SSC_AV_ID% --store '?'
				
				fcli sc-sast scan wait-for '?' --interval=30s
				
				fcli ssc appversion-vuln count --appversion=%env.SSC_AV_ID%
				
				fcli sc-sast session logout
				fcli ssc session logout 
            """.trimIndent()
            dockerImage = "fortifydocker/fortify-ci-tools:latest-jdk-11"
        }
    }

    triggers {
        vcs {
            branchFilter = ""
        }
    }
})
