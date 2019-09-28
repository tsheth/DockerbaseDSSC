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
    stage('Build') {
      parallel {
        stage('Build Cluster service') {
          steps {
            sh '''rm -rf DockerbaseDSSC
git clone https://github.com/tsheth/DockerbaseDSSC.git
cd DockerbaseDSSC
docker build -t cluster-service:latest .'''
          }
        }
        stage('AWS Environment') {
          steps {
            sh '''/usr/local/bin/terraform init
/usr/local/bin/terraform apply --auto-approve'''
          }
        }
        stage('Build Java Location Service') {
          steps {
            sh '''rm -rf struts-app
git clone https://github.com/tsheth/struts-app.git
cd struts-app
docker build -t location-service:latest .'''
          }
        }
      }
    }
    stage('Test') {
      parallel {
        stage('Performance Test') {
          steps {
            sh '''echo "local testing results"
sleep 20'''
          }
        }
        stage('Smart Check Security Test') {
          steps {
            sh '''docker run -v /var/run/docker.sock:/var/run/docker.sock deepsecurity/smartcheck-scan-action --image-name cluster-service:latest --smartcheck-host="dssc.bryceindustries.net" --smartcheck-user="administrator" --smartcheck-password="Trend@123" --insecure-skip-tls-verify --insecure-skip-registry-tls-verify --preregistry-scan --preregistry-user admin --preregistry-password Trend@123 --findings-threshold \'{"malware": 100, "vulnerabilities": { "defcon1": 100, "critical": 100, "high": 100 }, "contents": { "defcon1": 100, "critical": 100, "high": 100 }, "checklists": { "defcon1": 100, "critical": 100, "high": 100 }}\'
'''
            sh 'docker run -v /var/run/docker.sock:/var/run/docker.sock deepsecurity/smartcheck-scan-action --image-name location-service:latest --smartcheck-host="dssc.bryceindustries.net" --smartcheck-user="administrator" --smartcheck-password="Trend@123" --insecure-skip-tls-verify --insecure-skip-registry-tls-verify --preregistry-scan --preregistry-user admin --preregistry-password Trend@123 --findings-threshold \'{"malware": 100, "vulnerabilities": { "defcon1": 100, "critical": 100, "high": 100 }, "contents": { "defcon1": 100, "critical": 100, "high": 100 }, "checklists": { "defcon1": 100, "critical": 100, "high": 100 }}\''
            emailext(attachLog: true, subject: 'DSSC Security scan results', body: '[DSSC image scanning report]', from: 'devops@trendmicro.com', to: 'tsheth.p@gmail.com')
          }
        }
        stage('Integration Test') {
          steps {
            sh '''echo "Integration test"
sleep 17'''
          }
        }
        stage('Unit test') {
          steps {
            sh '''echo "Unit test"
sleep 24'''
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
    stage('Push image stage') {
      steps {
        sh '''echo "ECR registry push for image"
sleep 10'''
      }
    }
    stage('Deploy to Staging') {
      steps {
        sh '''echo "ECS Application deployment started"
sleep 10'''
      }
    }
    stage('Manual Test Success?') {
      steps {
        input 'Deployment Approval based on manual testing'
      }
    }
    stage('Classify image for production') {
      parallel {
        stage('Classify image for production') {
          steps {
            sh '''docker tag cluster-service:latest bryce.azurecr.io/bryce/cluster-service:latest
sleep 10'''
          }
        }
        stage('Destroy AWS Environment ') {
          steps {
            sh '/usr/local/bin/terraform destroy -target aws_instance.shellshock_host --auto-approve'
          }
        }
      }
    }
    stage('Approve for production deploy') {
      steps {
        input 'Approved for production deploy'
      }
    }
    stage('Push Prod Image') {
      steps {
        sh '''docker login bryce.azurecr.io -u bryce -p +3BMjKEDQVvWuODOMM4SR2iZ1LWtOUMo
docker push bryce.azurecr.io/bryce/cluster-service:latest'''
      }
    }
    stage('Virtual Patch Prod') {
      steps {
        sh '''echo "Deep Security virtual patching of server using recommendation scan"
sleep 10'''
      }
    }
    stage('White list Apps') {
      steps {
        sh '''echo "Deep Security Application control whitelist application"
sleep 5'''
      }
    }
    stage('Deplo to Prod') {
      steps {
        sh '''echo "Deploy application to production"
sleep 7'''
      }
    }
    stage('Stop Whitelist App') {
      steps {
        sh '''echo "Deep security stop whitelisting of app using Application control"
sleep 3'''
      }
    }
  }
}