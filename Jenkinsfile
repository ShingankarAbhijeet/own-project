pipeline {
    agent any

    triggers {
        githubPush ( )
    }
    stages {
        stage("checkout") {
           steps {
            git branch: 'main',
            credentialsId: 'github-creds',
            url: 'https://github.com/ShingankarAbhijeet/own-project.git'
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
       /// stage("terraform apply"){
    ///        steps{
       ///         dir('own-project'){
          ///        sh 'terraform apply -auto-approve'
             ///   }
            
            ///}
        }
    
    }
        
    
}