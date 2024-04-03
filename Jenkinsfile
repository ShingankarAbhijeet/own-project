pipeline {
    agent any

    triggers {
        githubPush //{
          //sourceId "ShingankarAbhijeet/own-project"
          //branch "main"
          //credentialsId "github-cred"
          //event "push"
        //}
    }
    stages {
        stage("checkout") {
           steps {
            git branch: 'main',
            credentialsId: 'github-cred',
            url: 'https://github.com/ShingankarAbhijeet/own-project.git'
           }
        }
        stage("Terraform Init"){
           steps {
            sh 'terraform init'
           }
        }
        stage("terraform plan"){
            steps{
                sh ' terraform plan'
            }
        }
        stage("terraform apply"){
            steps{
                sh 'terraform apply -auto-approve'
            }
        }
    
    }
        
    
}