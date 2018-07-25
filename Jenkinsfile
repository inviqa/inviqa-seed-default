String cron_string = BRANCH_NAME == 'master' ? 'H H * * *' : ''

def GetWorkspace(suffix = '')
{
    return 'workspace/' + env.BUILD_TAG.replace('%', '-') + suffix;
}

pipeline {
    agent none

    triggers {
        cron cron_string
    }

    options {
        buildDiscarder(logRotator(numToKeepStr: '5', artifactNumToKeepStr: '5'))
        disableConcurrentBuilds()
        timeout(time: 1, unit: 'HOURS')
        timestamps()
        skipDefaultCheckout()
    }

    stages {
        stage('Plant seed') {
            agent {
                label 'vmbuild || dockerbuild'
            }
            steps {
                checkout scm

                script {
                    env.PLANTED_PATH = sh(returnStdout: true, script: 'mktemp -d -p "${WORKSPACE}" seed-test-XXXXX').trim()
                }

                // make an available branch for Hem from the current git reference
                sh 'git branch -D ci-test || true'
                sh 'git checkout -b ci-test'

                dir(env.PLANTED_PATH) {
                    deleteDir()
                }

                sh 'hem seed plant "$(basename "${PLANTED_PATH}")" "--seed=${WORKSPACE}" --branch=ci-test --non-interactive'

                dir(env.PLANTED_PATH) {
                    sh 'hem deps gems'
                    sh 'sed -i -e \'/^\\s*ASSETS_S3_BUCKET/d\' docker-compose.yml'
                    sh 'touch docker.env'
                    sh '''python -c "$(cat <<EOF
import sys, yaml
data = yaml.load(sys.stdin)
for service in data['services']:
  data['services'][service].pop('ports', None)
print yaml.dump(data, default_flow_style = False)
EOF
)" < docker-compose.override.yml.dist > docker-compose.override.yml'''

                    stash name: 'planted', useDefaultExcludes: false
                }
            }
            post {
                always {
                    dir(env.PLANTED_PATH) {
                        deleteDir()
                    }
                }
            }
        }
        stage('Provision dev environments') {
            parallel {
                stage('Vagrant') {
                    agent {
                        node {
                            label 'vmbuild'
                            customWorkspace GetWorkspace('@vm')
                        }
                    }
                    steps {
                        unstash 'planted'
                        sh 'eval "$(ssh-agent)" && ssh-add && hem vm rebuild'
                        sh 'hem exec bash -c \'cd tools/vagrant && rake\''
                    }
                    post {
                        always {
                            sh 'hem vm destroy'
                        }
                    }
                }
                stage('Docker Compose (stable tags)') {
                    agent {
                        node {
                            label 'dockerbuild'
                            customWorkspace GetWorkspace('@stable')
                        }
                    }
                    steps {
                        unstash 'planted'
                        sh 'hem deps gems'
                        sh 'hem exec bash -c \'rake docker:up\''
                    }
                    post {
                        always {
                            sh 'hem exec bash -c \'rake docker:down\''
                        }
                    }
                }
                stage('Docker Compose (latest tags)') {
                    agent {
                        node {
                            label 'dockerbuild'
                            customWorkspace GetWorkspace('@latest')
                        }
                    }
                    steps {
                        unstash 'planted'
                        sh 'sed -i -E "s#(quay.io/continuouspipe/[^:]*:)stable(\\s*)#\\1latest\\2#g" Dockerfile docker-compose.yml'
                        sh 'hem deps gems'
                        sh 'hem exec bash -c \'rake docker:up\''
                    }
                    post {
                        always {
                            sh 'hem exec bash -c \'rake docker:down\''
                        }
                    }
                }
            }
        }
    }
}
