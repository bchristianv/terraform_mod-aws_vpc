// Jenkinsfile

String awsCredentials = 'ci-user' // ID of AWS credentials in Jenkins

pipeline {
    agent any

    options {
        ansiColor('xterm')
    }

    stages {
        stage('Check format') {
            steps {
                sh "$HOME/bin/terraform fmt -check -diff"
            }
        }

        stage('Initialize') {
            steps {
                dir("${env.WORKSPACE}/tests") {
                    sh "$HOME/bin/terraform init"
                }
            }
        }

        stage('Validate') {
            steps {
                dir("${env.WORKSPACE}/tests") {
                    sh "$HOME/bin/terraform validate"
                }
            }
        }

        stage('Plan') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: awsCredentials,
                    accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                    secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                ]]) {
                    dir("${env.WORKSPACE}/tests") {
                        sh "$HOME/bin/terraform plan"
                    }
                }
            }
        }
    }

    post {
        cleanup {
            cleanWs()
        }
    }
}
