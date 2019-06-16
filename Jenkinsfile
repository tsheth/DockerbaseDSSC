pipeline {
  agent any
  stages {
    stage('Git Checkout') {
      steps {
        git 'https://github.com/tsheth/DockerbaseDSSC.git'
      }
    }
    stage('Build image') {
      steps {
        sh 'echo "docker build command"'
      }
    }
    stage('Local Test') {
      parallel {
        stage('Local Test') {
          steps {
            sh 'echo "local testing results"'
          }
        }
        stage('Notify Test result') {
          steps {
            sh 'echo "send message to github issue"'
          }
        }
      }
    }
    stage('Classify image tag') {
      steps {
        sh 'echo "docker tag to classify image"'
      }
    }
    stage('Push image to staging') {
      steps {
        sh 'echo "ECR registry push for image"'
      }
    }
    stage('Deploy to Staging') {
      steps {
        sh 'echo "ECS deploy commands"'
      }
    }
    stage('Approved manual test') {
      steps {
        input 'Deployment Approval based on manual testing'
      }
    }
    stage('Classify image for production') {
      steps {
        sh 'echo "tag image with production ready build"'
      }
    }
    stage('Production deploy approval') {
      steps {
        input 'Approved for production deploy'
      }
    }
    stage('Deploy to production') {
      steps {
        sh 'echo "ECS commands to deploy service to production"'
      }
    }
  }
}