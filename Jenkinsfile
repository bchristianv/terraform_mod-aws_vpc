// Jenkinsfile

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
                dir("${env.WORKSPACE}/tests") {
                    sh "$HOME/bin/terraform plan"
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
