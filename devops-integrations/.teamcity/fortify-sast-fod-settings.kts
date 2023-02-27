import jetbrains.buildServer.configs.kotlin.*
import jetbrains.buildServer.configs.kotlin.buildFeatures.perfmon
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

Integrate Fortify on Demand Static AppSec Testing (SAST) into your TeamCity build pipeline
 Rename this file to "settings.kts" before use
 The following environment variables must be defined in Project/Agent settings before using this job
   - env.FOD_RELEASE_ID
   - env.FOD_USER
   - env.FOD_PAT
   - env.FOD_TENANT
*/

version = "2022.10"

project {

    buildType(Build)
}

object Build : BuildType({
    name = "Build"

    vcs {
        root(DslContext.settingsRoot)
    }

    steps {
        maven {
            goals = "clean package"
            runnerArgs = "-Dmaven.test.failure.ignore=true"
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
                export FOD_API_URL=https://api.ams.fortify.com
                export FOD_URL=https://ams.fortify.com
                export FOD_UPLOADER_OPTS='-ep 2 -pp 0 -I 1 -apf'
                export FOD_NOTES='Triggered by TeamCity Build Pipeline'
                
                scancentral package -bt mvn -oss -o package.zip
                
                FoDUpload -z package.zip -aurl ${'$'}FOD_API_URL -purl ${'$'}FOD_URL -rid %env.FOD_RELEASE_ID% -tc %env.FOD_TENANT% -uc %env.FOD_USER% %env.FOD_PAT% ${'$'}FOD_UPLOADER_OPTS -n "${'$'}FOD_NOTES"
            """.trimIndent()
            dockerImage = "fortifydocker/fortify-ci-tools:latest-jdk-11"
        }
    }

    triggers {
        vcs {
        }
    }

    features {
        perfmon {
        }
    }
})
