pipeline {
  agent any
  stages {
    stage('Git Checkout') {
      parallel {
        stage('Git Checkout') {
          steps {
            git(url: 'https://github.com/tsheth/DockerbaseDSSC.git', credentialsId: 'git-creds', branch: 'master')
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

        stage('Build Cloud Environment') {
          steps {
            sh 'echo "terraform apply --auto-approved"'
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

        stage('Docker image scanning') {
          steps {
            withCredentials(bindings: [
                                                                                                                              [$class: 'UsernamePasswordMultiBinding', credentialsId: 'dssc-login-creds', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD'],
                                                                                                                              [$class: 'UsernamePasswordMultiBinding', credentialsId: 'dssc-scan-creds', usernameVariable: 'SCAN_USERNAME', passwordVariable: 'SCAN_PASSWORD']
                                                                                                                              ]) {
                sh '''#docker run -v /var/run/docker.sock:/var/run/docker.sock deepsecurity/smartcheck-scan-action --image-name cluster-service:latest --smartcheck-host="dssc.trendebc.org" --smartcheck-user=$SCAN_USERNAME --smartcheck-password=$SCAN_PASSWORD --insecure-skip-tls-verify --insecure-skip-registry-tls-verify --preregistry-scan --preregistry-user $USERNAME --preregistry-password $PASSWORD --findings-threshold \'{"malware": 100, "vulnerabilities": { "defcon1": 100, "critical": 100, "high": 200 }, "contents": { "defcon1": 100, "critical": 100, "high": 200 }, "checklists": { "defcon1": 100, "critical": 100, "high": 200 }}\'
#docker run -v $WORKSPACE:/root/app shunyeka/dssc-vulnerability-report:latest --smartcheck-host dssc.trendebc.org --smartcheck-user $SCAN_USERNAME --smartcheck-password $SCAN_PASSWORD --insecure-skip-tls-verify --min-severity low dssc.trendebc.org:5000/cluster-service:latest
#mv $WORKSPACE/DSSCReport.xlsx $WORKSPACE/ClusterService-Vulnerability-report.xlsx
#curl -F file=@$WORKSPACE/ClusterService-Vulnerability-report.xlsx -F "initial_comment=DSSC report for Cluster service image" -F channels=buildnotification -H "Authorization: Bearer xoxp-375765158032-376600608661-776771608885-6093db05ce4db6b26c68ca36bc42c4cf" https://slack.com/api/files.upload
'''
                sh '''docker run -v /var/run/docker.sock:/var/run/docker.sock deepsecurity/smartcheck-scan-action --image-name location-service:latest --smartcheck-host="dssc.trendebc.org" --smartcheck-user=$SCAN_USERNAME --smartcheck-password=$SCAN_PASSWORD --insecure-skip-tls-verify --insecure-skip-registry-tls-verify --preregistry-scan --preregistry-user $USERNAME --preregistry-password $PASSWORD --findings-threshold \'{"malware": 100, "vulnerabilities": { "defcon1": 100, "critical": 100, "high": 100 }, "contents": { "defcon1": 100, "critical": 100, "high": 100 }, "checklists": { "defcon1": 100, "critical": 100, "high": 100 }}\'
docker run -v $WORKSPACE:/root/app shunyeka/dssc-vulnerability-report:latest --smartcheck-host dssc.trendebc.org --smartcheck-user $SCAN_USERNAME --smartcheck-password $SCAN_PASSWORD --insecure-skip-tls-verify --min-severity low dssc.trendebc.org:5000/location-service:latest
mv $WORKSPACE/DSSCReport.xlsx $WORKSPACE/LocationService-Vulnerability-report.xlsx
curl -F file=@$WORKSPACE/LocationService-Vulnerability-report.xlsx -F channels=buildnotification -H "Authorization: Bearer xoxp-375765158032-376600608661-776771608885-6093db05ce4db6b26c68ca36bc42c4cf" https://slack.com/api/files.upload'''
              }

              script {
                slackSend color: "warning", message: "REPORT: ${env.JOB_NAME} with buildnumber ${env.BUILD_NUMBER} created Cluster service and scanned with security tool. To get more details go to http://jenkins.bryceindustries.net:8080/job/DockerbaseDSSC/job/master/${env.BUILD_NUMBER}/execution/node/3/ws/ClusterService-Vulnerability-report.xlsx"

                slackSend color: "warning", message: "REPORT: ${env.JOB_NAME} with buildnumber ${env.BUILD_NUMBER} created Location service and scanned with security tool. To get more details go to http://jenkins.bryceindustries.net:8080/job/DockerbaseDSSC/job/master/${env.BUILD_NUMBER}/execution/node/3/ws/LocationService-Vulnerability-report.xlsx"
              }

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

docker tag cluster-service:latest 983592080135.dkr.ecr.us-east-2.amazonaws.com/test-dssc:latest'''
        }
      }

      stage('Push image stage') {
        steps {
          sh '''# docker login 

#1 docker login to AWS ECR ohio (not working)
#docker login -u AWS -p $(aws ecr get-login-password --region us-east-2) https://983592080135.dkr.ecr.us-east-2.amazonaws.com

#2 more dynamic
#aws ecr get-login --region us-east-2 > aws-ecr-pass
#sed -i \'s/-e none//g\' aws-ecr-pass
#bash aws-ecr-pass
#rm aws-ecr-pass

#3 more dynamic
aws ecr get-login --region us-east-2 | sed \'s/-e none//g\' | bash

# Pushing docker image
docker push 983592080135.dkr.ecr.us-east-2.amazonaws.com/test-dssc:latest

'''
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
              sh '''# changing image name and tag
docker tag cluster-service:latest 983592080135.dkr.ecr.us-east-2.amazonaws.com/test-dssc:latest
#docker tag cluster-service:latest bryce.azurecr.io/bryce/cluster-service:latest
'''
            }
          }

          stage('Destroy VMware Environment ') {
            steps {
              sh '''# /usr/local/bin/terraform destroy -target aws_instance.shellshock_host --auto-approve
/usr/local/bin/terraform destroy --auto-approve'''
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
        parallel {
          stage('Push Prod Image') {
            steps {
              sh '''# old
#docker login bryce.azurecr.io -u bryce -p +3BMjKEDQVvWuODOMM4SR2iZ1LWtOUMo
#docker push bryce.azurecr.io/bryce/cluster-service:latest

# docker login
# aws ecr get-login-password --region us-east-2 | sudo docker login --username AWS --password-stdin 983592080135.dkr.ecr.us-east-2.amazonaws.com
#2 sudo docker login -u AWS -p $(aws ecr get-login-password --region us-east-2) 983592080135.dkr.ecr.us-east-2.amazonaws.com
#3
#aws ecr get-login-password --region us-east-2 > aws-ecr-pass
#docker login -u AWS -p $(cat aws-ecr-pass) 983592080135.dkr.ecr.us-east-2.amazonaws.com



'''
            }
          }

          stage('Push image to DR ECR region') {
            steps {
              sh '''echo "Pushing image to AWS DR region"

'''
            }
          }

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