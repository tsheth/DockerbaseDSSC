pipeline {
  agent any
  stages {
    stage('Git Checkout') {
      parallel {
        stage('Git Checkout') {
          steps {
            git(url: 'https://github.com/tsheth/docker-exploit-demo.git', credentialsId: 'git-creds')
          }
        }
        stage('Static code analysis') {
          steps {
            sh '''echo "static code analysis for github code"
sleep 12'''
          }
        }
      }
    }
    stage('Build Docker image') {
      parallel {
        stage('Build Location service') {
          steps {
            sh '''echo "docker build cluster image"
sleep 10'''
          }
        }
        stage('Build Clustering service') {
          steps {
            sh 'echo "Docker build -t <source image> <destination image>"'
          }
        }
        stage('Build AWS Environment') {
          steps {
            sh '''/usr/local/bin/terraform init
/usr/local/bin/terraform apply --auto-approve'''
          }
        }
      }
    }
    stage('Local Test') {
      parallel {
        stage('Performance Test') {
          steps {
            sh '''echo "local testing results"
sleep 10'''
          }
        }
        stage('Smart Check Security Test') {
          steps {
            sh '''echo "send message to github issue"
sleep 15'''
          }
        }
        stage('Integration Test') {
          steps {
            sh 'echo "Integration test"'
          }
        }
        stage('Unit test') {
          steps {
            sh 'echo "Unit test"'
          }
        }
      }
    }
    stage('Classify image tag') {
      steps {
        sh '''echo "docker tag to classify image"
sleep 5'''
      }
    }
    stage('Push image to staging') {
      steps {
        sh '''echo "ECR registry push for image"
sleep 10'''
      }
    }
    stage('Deploy to Staging') {
      steps {
        sh '''echo "ECS deploy commands"
sleep 10'''
      }
    }
    stage('Manual Test Success?') {
      steps {
        input 'Deployment Approval based on manual testing'
      }
    }
    stage('Classify image for production') {
      steps {
        sh '''echo "tag image with production ready build"
sleep 10'''
      }
    }
    stage('Approve for production deploy') {
      steps {
        input 'Approved for production deploy'
      }
    }
    stage('Deploy to production') {
      steps {
        sh '''echo "ECS commands to deploy service to production"
sleep 10'''
      }
    }
  }
}