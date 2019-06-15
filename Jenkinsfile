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
        sh 'docker tag <source image> <destination image>:cleartest1'
      }
    }
    stage('Push to stagging') {
      steps {
        sh 'echo "ECR registry push for image"'
      }
    }
    stage('Halt for approval') {
      parallel {
        stage('Halt for approval') {
          steps {
            input 'Test result'
          }
        }
        stage('Notify approval result') {
          steps {
            sh 'echo "send notification over mail"'
          }
        }
      }
    }
    stage('Classify image for prod') {
      steps {
        sh 'echo "production classified image"'
      }
    }
    stage('Deploy to production') {
      steps {
        sh 'echo "Deploy image to production ECR"'
      }
    }
  }
}