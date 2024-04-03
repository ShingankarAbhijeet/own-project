pipeline {
    agent any
    environment {
    TF_CLI_CONFIG_FILE = '/root/.terraform.d/credentials.tfrc.json'
    }
    triggers {
        githubPush ( )
    }
    stages {
        stage("clone") {
           steps {
             dir('own-project') {
                git branch: 'main',
                credentialsId: 'github-creds',
                url: 'https://github.com/ShingankarAbhijeet/own-project.git'
             }
           }
        }
        
        stage("Terraform Init"){
           steps {
             dir('own-project'){
                            sh 'terraform init'
             }
           }

        }
        stage("terraform plan"){
            steps{
                dir('own-project') {
                  sh ' terraform plan'
                }
            }
        }
       stage("terraform apply"){
            steps{
                dir('own-project'){
                  sh 'terraform apply'
                }
            
            }
        }
    
    }
}        