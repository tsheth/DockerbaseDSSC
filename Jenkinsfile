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
        stage('Provision VMware Environment') {
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
        stage('Docker image scanning') {
          steps {
            sh '''docker run -v /var/run/docker.sock:/var/run/docker.sock deepsecurity/smartcheck-scan-action --image-name cluster-service:latest --smartcheck-host="dssc.bryceindustries.net" --smartcheck-user="administrator" --smartcheck-password="Trend@123" --insecure-skip-tls-verify --insecure-skip-registry-tls-verify --preregistry-scan --preregistry-user admin --preregistry-password Trend@123 --findings-threshold \'{"malware": 100, "vulnerabilities": { "defcon1": 100, "critical": 100, "high": 200 }, "contents": { "defcon1": 100, "critical": 100, "high": 200 }, "checklists": { "defcon1": 100, "critical": 100, "high": 200 }}\'
docker run -v $WORKSPACE:/root/app tshethp/dssc-vulnerability-report:v4 --smartcheck-host dssc.bryceindustries.net --smartcheck-user administrator --smartcheck-password Trend@123 --insecure-skip-tls-verify --min-severity low dssc.bryceindustries.net:5000/cluster-service:latest
mv $WORKSPACE/DSSCReport.xlsx $WORKSPACE/ClusterService-Vulnerability-report.xlsx
curl -F file=@$WORKSPACE/ClusterService-Vulnerability-report.xlsx -F "initial_comment=DSSC report for Cluster service image" -F channels=buildnotification -H "Authorization: Bearer xoxp-375765158032-376600608661-776771608885-6093db05ce4db6b26c68ca36bc42c4cf" https://slack.com/api/files.upload
'''
            sh '''docker run -v /var/run/docker.sock:/var/run/docker.sock deepsecurity/smartcheck-scan-action --image-name location-service:latest --smartcheck-host="dssc.bryceindustries.net" --smartcheck-user="administrator" --smartcheck-password="Trend@123" --insecure-skip-tls-verify --insecure-skip-registry-tls-verify --preregistry-scan --preregistry-user admin --preregistry-password Trend@123 --findings-threshold \'{"malware": 100, "vulnerabilities": { "defcon1": 100, "critical": 100, "high": 100 }, "contents": { "defcon1": 100, "critical": 100, "high": 100 }, "checklists": { "defcon1": 100, "critical": 100, "high": 100 }}\'
docker run -v $WORKSPACE:/root/app tshethp/dssc-vulnerability-report:v4 --smartcheck-host dssc.bryceindustries.net --smartcheck-user administrator --smartcheck-password Trend@123 --insecure-skip-tls-verify --min-severity low dssc.bryceindustries.net:5000/location-service:latest
mv $WORKSPACE/DSSCReport.xlsx $WORKSPACE/LocationService-Vulnerability-report.xlsx
curl -F file=@$WORKSPACE/LocationService-Vulnerability-report.xlsx -F channels=buildnotification -H "Authorization: Bearer xoxp-375765158032-376600608661-776771608885-6093db05ce4db6b26c68ca36bc42c4cf" https://slack.com/api/files.upload'''
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

# docker login to AWS ECR ohio
docker login -u AWS -p eyJwYXlsb2FkIjoiajA2aVF2Zzc0ekQzeDFmNFhnUHVuekkxOGIyMEVRelhwM21la2xuNUlrNWNVS1Y4eEIvTGhrOVRLM0MyNnVyMkViSGZLdG1HYTZSR1RQQkNaNnNKTjN2Z0lReVlVLzMzMkROSkpEbTIvUVdaa0FiKzlGY2lKVHpDM1Y0VVVSdThsM29mU3FHeUlPclhmd1Zqc3VQTzJkR3hEN3dBZVdSbmJXbFVvS3QzV0dRRWc5bjFoNW81dWxyV0FCWnpYU3NuK29tZTl2UmFDTW9XTWhaRE9zWEpIRE5Lc1BKcy9ZNlBzNk9NcmJUZ3prMmZxQVlNNUxrSEZrcm5kbzRMKzhVbGpsb1doZmNzNzdJbWFWMWxxaTA5MXIwb2JXclZWTHEzL3hNN3VJdDFXTlcrdzRobHFMdFN3cGdGeUNwcDduUElKTlBMRGFMZlVLNCtlLysxOW9BTkkvYmptOEdDclF4b0xlK1hCTXlJcEM4T0NxeFo4SkxqWDFjcFQ2MFRzV3h0T0luckNJa01aS3p1R2hWV05pWVp4emF5bkhnUWFweVVkS0U5RStmcm5TZlZQMUg3OWd5a1hza0VZMmpuZTY4S3Y4c01zNW5YL29vWnpnMW1COS9BRERFeUFaWEpvWjd5TGtnb3htZlFsUnBIamNuTzFLVU9jeEVvVkR4eC91VmIxdW41MTlTWGRNLzZ3VTJSNkxYcExVUXFVeFBhaEVqTVhnczd4RGczNGhtVlBMbnZWemVITTVuQnpnbWluQWJvRzNGQU4zZ05kWFpmeHZyMjBwYWRmdzViMzFXRTZxaHY4VzZyR0l2NGY0ME1jOTM3OVlLME5ENXFMd3pZbDR2WWV6SzFvemJZQmtiR3dmMWNCemVYU3ZsLzgreUVseXpJemtjY1FjNHk5Q2NBTFRDKzluOFpEbzRueUFjMVhnQUtNdHcvbXl1YXR4WFNFa2d0djMwamx3SVZIV2FUazFzdHdTay9PL2ZqZlozRUVVbVBPU1VSSUlGTmlMQTh3UklFMDJrcGxZV3FXOGswd1ZZdFVpUStlYlNhZERWWE9oTzU5ZFFreE5XNGtqUVE2Z2VkY05tOVZKMk5vR3MyNXFsNE05QzRxRCtuZUtuTE1CR2dYTlFIVFpvdWo1R3dvdGEyQVJJTG1pMXBrL2p4WUZ4NExITW44QnF6bXd6cWV0STl0aWdoZUloNDBVRkdVN0dRTVpLTUtVdGhpUWxiQWhPZFBJTVdTM1RSb0tnUFlEcU1SRkV2VDNWQXNMTGFiaHRpbEFMSWtnajFxZng1bThQVXJkK2NKV2JrMjg1bEpUd0w5ZVp6NE9LOHJyYlVKZXRPTStIWDU4OFNFdHl3eUphLzd2MmVzMkthUE55ME13enZ0dG9zMnFFMksxNUlLN2dMQWNGcXRvTGtZempZR0hKdm1lTytNL21ZRGpWUVpBcFBQU1ZsVThoSHQ4WWx4T3BSS1UwamJ4Y1l5TGtoS0tFWmxURG4rZkxBU1hKVGEwR3lUZlBSamxvME5DRG5yc1gwUGhFeDB3SE9kYVJqZnJwWDF4S0Q1cEpGNXRFVFVuN0xsUGVWSElZcWFCNjVYOVVhRURzZHBPcHhKcmNIZ2Z6VXY1SWoxcnZKMUplZFhsTnJCWk5LaFhWMk03ZG9nK2pkREU5VVBzdEhnMEJNd3A4NU9IN2QwOTJBeGhYZGRYN211OWdKdjV2ZnJSMlJNM094eGZmMlpFTnltcGVJMUZMR3A5SzVBT3JrL05aSTZEZlRibWVVem5uRzQvUW9QaUtPZ21abDBDcGZUOUR4eDFVOElXeGEwWUdwUUJvMDY1MFM2U3A3cE1zSlQ4Z0xVdzBBdkxmRXcrQWdDczFGZlZwZ1F2U0wzdmtkVDdpanZQalZ1RXkzd0FiOWZmR3NFbHo5cHlBUHk0elFHQzdRUXJlMVpocG00elVZK2tONFBqKy9wdjBOeUs0czNRUFZ0MU9HaVVTYVU2QkFrTGZUb3ZiZCtvUTRVaDd5dDVIRjdURmJ2LzZmSmFNR2d0OEtHakpvTk5qRzVINUJtbzhPYkk2aDR3a2RBK3Z3UjNGeDRQend2MEpIc3pBcitoUFUranE0dUlHYzluR1k1SGcvT0hpZUd1akRLYWE2TjFyRGxzc3N1eXFmT1krc0tiZ0VES2hxVnJBb1ZhV2U2WExYQWYwclA1aEpmQUxWTm90T0hqZktZQXJ2TGRxRTBLY29wM0RjNWJSS2xMekdzWmVvIiwiZGF0YWtleSI6IkFRRUJBSGpCNy9pZ3dNZzROUHdhdXJ4U0lZeDRIZm54dUdjLzQ4YkR3dndEcE5ZV1pnQUFBSDR3ZkFZSktvWklodmNOQVFjR29HOHdiUUlCQURCb0Jna3Foa2lHOXcwQkJ3RXdIZ1lKWUlaSUFXVURCQUV1TUJFRURMVEo5UW1STEMrY0xWdFc4UUlCRUlBN3FWakUrVFE0TkwvVlVGN2U1bXFiWlVIM2JaOGQvSEkzUEk4cXRGL3BBaW5xT2FwQytId3VtY01qQ0dnVWczOFdQVnhxd1JIbmxQc2RjVlE9IiwidmVyc2lvbiI6IjIiLCJ0eXBlIjoiREFUQV9LRVkiLCJleHBpcmF0aW9uIjoxNjE0NzI5NzI4fQ== 983592080135.dkr.ecr.us-east-2.amazonaws.com

# Pushing docker image
docker push 983592080135.dkr.ecr.us-east-2.amazonaws.com/test-dssc:latest
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