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
            sh '''docker run -v /var/run/docker.sock:/var/run/docker.sock deepsecurity/smartcheck-scan-action --image-name cluster-service:latest --smartcheck-host="https://ae586be628a2b4046be3989278a9d2b6-1694873914.us-east-2.elb.amazonaws.com/" --smartcheck-user="administrator" --smartcheck-password="newpass123" --insecure-skip-tls-verify --insecure-skip-registry-tls-verify --preregistry-scan --preregistry-user administrator --preregistry-password newpass123 --findings-threshold \'{"malware": 100, "vulnerabilities": { "defcon1": 100, "critical": 100, "high": 200 }, "contents": { "defcon1": 100, "critical": 100, "high": 200 }, "checklists": { "defcon1": 100, "critical": 100, "high": 200 }}\'
docker run -v $WORKSPACE:/root/app tshethp/dssc-vulnerability-report:v4 --smartcheck-host https://ae586be628a2b4046be3989278a9d2b6-1694873914.us-east-2.elb.amazonaws.com/ --smartcheck-user administrator --smartcheck-password newpass123 --insecure-skip-tls-verify --min-severity low https://ae586be628a2b4046be3989278a9d2b6-1694873914.us-east-2.elb.amazonaws.com:5000/cluster-service:latest
mv $WORKSPACE/DSSCReport.xlsx $WORKSPACE/ClusterService-Vulnerability-report.xlsx
curl -F file=@$WORKSPACE/ClusterService-Vulnerability-report.xlsx -F "initial_comment=DSSC report for Cluster service image" -F channels=buildnotification -H "Authorization: Bearer xoxp-375765158032-376600608661-776771608885-6093db05ce4db6b26c68ca36bc42c4cf" https://slack.com/api/files.upload
'''
            sh '''docker run -v /var/run/docker.sock:/var/run/docker.sock deepsecurity/smartcheck-scan-action --image-name location-service:latest --smartcheck-host="https://ae586be628a2b4046be3989278a9d2b6-1694873914.us-east-2.elb.amazonaws.com/" --smartcheck-user="administrator" --smartcheck-password="newpass123" --insecure-skip-tls-verify --insecure-skip-registry-tls-verify --preregistry-scan --preregistry-user administrator --preregistry-password newpass123 --findings-threshold \'{"malware": 100, "vulnerabilities": { "defcon1": 100, "critical": 100, "high": 100 }, "contents": { "defcon1": 100, "critical": 100, "high": 100 }, "checklists": { "defcon1": 100, "critical": 100, "high": 100 }}\'
docker run -v $WORKSPACE:/root/app tshethp/dssc-vulnerability-report:v4 --smartcheck-host https://ae586be628a2b4046be3989278a9d2b6-1694873914.us-east-2.elb.amazonaws.com/ --smartcheck-user administrator --smartcheck-password newpass123 --insecure-skip-tls-verify --min-severity low https://ae586be628a2b4046be3989278a9d2b6-1694873914.us-east-2.elb.amazonaws.com/:5000/location-service:latest
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

docker tag cluster-service:latest 983592080135.dkr.ecr.us-east-2.amazonaws.com/test-dssc:latest'''
      }
    }
    stage('Push image stage') {
      steps {
        sh '''
# docker login to AWS ECR ohio
docker login -u AWS -p eyJwYXlsb2FkIjoiSFRYNGNkQTJZTFdYTHcwbUtlMXZ5VHo0ZEZCS3VtZ3VYTnJCVTBFZWhhTUFYZUt4eTVIVWQ4N2xYcUFoeUlhVVU2RmEvKzFaS2NiWkhWSEhKdkkvbW9oMUQ1M0VLVnludGFPam9NTUN3dVgvSjNhZExpbkN2TWRVbFFJOUNJUUZXR0lPOENJSWxnci9YQUxkNnRjd1kzVkpyQ3dQMlUzZzlkZitmZU1aeHlYdHhINnc3dDBUODhVamtrZ3ZwK0VDeTVGYkVkZmVwK2U2R2VHZzVwU2prMjhQeW1oSDNLTXlLdzhYajNOdHZ4SVN3eFRXTHNuZjI4VG1obG15UkU5aHdsQmhINjBSTC8wWEY0ZVZXTU1UTUpuWkFvUDJpamlBMmR0MUpLNnJhY296WGIxSEJhb0I4Z2lmZDVxdUpOWFJNYjI5K2Q1dnlQaEFJdFRZZ051SHpxOVZXV0QzMkw5T2ZBRXlpQys2T1EzZjJvc1oxbDVqY0szYWZSTVBISE1Na1JneUhzN2JrTkVUMGoyd2pUUStwaU9QRE9uZTBpbkhTa3RJczJYa3hFbG92YVl0YVVJcXJYWTRIVXY5Mkljb0lBQndXcmh0WW16eVVXR0VMQ2djOWVIdFhCSzhvS3dXSmpHeGJSNmNqYWJKM3Bvend5MEhscjh5azBCTUNsejNPMU5OQnFwNExmWUlueGZjK0d0N3FDYngyMGtVaXVHbDYyeUhkdlNnTDJvZUpsLzVOMXZVMTY4YllGV1RJY212MXpwM1QzY3l5SDdSVmpaMklZSldSVzRpdXdHSi9veXErZzVzaytKMHV1ZzRVclZmWHpzTUZGeXdqNk9pUFA2eGNtZ0F1YU45VG5xZk5peklHUEVqRnJ2RDd5SVc0UXJpaEdiZkpZbFYxUXpleHhKWG9uUGpHS0FiOUN4cGdjbnNJOXI1RnhlYTAxcXlrQUpYU3ZmRkhJemlEOEpNWFA3VmJVOVd4S1pZV2tSaXhaOGpZVzMyVFI1TmxTc1kzalY5bDRkMmlYZ3N3VVkxMXM1RThSYkdreHhmaVFKVjMrS0NzYmk1ZVlsdVBiZTFTaFhvWG5DemQyQTl2ZXpFemNzLzNtVzMxOXQvYWFMWGxyY3ZncTZrWk5vcHFYVTQyWG1ZYXlva2lqQnlIQkpKV3FQdGFnc0dNTkFWc2NzZWF6dEV6cnJMZGpqcnZMNUZhc0xkS2VXS1hPR1ppdTE0R2t1L1hicFp3ZzR0ZWtiWTViNnpZQVNLSGxnWUZDeWdDYVc4ZEUzVG82S2VvdVhmZnpCZ1pQWUtRUGxxa25JeGN0ZGNUZzNvdWZaSXViVDBCbzdEaFFLU0ZRSU9NMTBtZUZpclBIYnR4RTN2eXFHSFNUSWw0emhKMUM5L0ZiRjhXSE9ETDJNZHpCby9rbGVsN1UrSmFYaFVvVmlkbUZIL3dyakttUFl0Q1VZY2ZkYzlpbGhBWFdBbWRFQkNnYzN2NGh1N1RUWjVBSlBrUDdIY2RxZ0NpNytISy9kclV5OXpuTW0wSTQ2V1hxcmxLV290RVZwRXBtd2t1MSsrTzFxSTBLT2xHekc4L3ZxOW9GNUd1dDZyNkdTWkpWUmpzYWsvclUxQkVuZnlYQkhBMFRScDN0dW5EdkdKSFZxb0xIcDlIbWo2U3I4SnBlQ2s5V3BJS2hsOFdBaU93bVdtY3I1NExOdGZTK1V4TGlHSG9zZ2VkMzJvTVZOUWFvUWtYcFE3Y3ZsT3R5c0ticC9TK1NrcTVSaXlIOEhZU1VCS3doQjM2aTgrTWl2aDRJNTVrVGdLeXBIa2JZU2dUUjJQdkpzbWVpQnNPY3QyRlQ1S0gweWJzV0xwYVRBdTNUcTVSZnBpMzJ1ZlVSTlQrTWRpZmVteVlsUGtJNk50OVhEL1VwT2ptSkZyQ1NTTzVtWGhybThQYVhIczlpeTl3MlFCOVArSEQrNTJnbWxkN1dROGdicmNHOGJaRFBka2Q1c1RLWFJTeEpNbnJnVE1YUkpYNzhLN2NBR01aR1NmRzdBVUg0ODYwRld4azVQdjF2NXlHbXJGMDBydTdFeXRxcVBZdUwxeWx4QmZaYkloSFVybEJwb0JPd29HbTNvSGpwVjRhQUR1SnNaaGtqbmRhL0FZUzl2aFljZmZvRWdiWmFJVjYreXNsNXc1TUtRR3ZiMTkwL0lOSTBOTkQvQlJldERKRjVMYTV1RHZ0NUFhaFlqTG9WUnZyQmN4VWNzNFJjZWpuMWRJIiwiZGF0YWtleSI6IkFRRUJBSGpCNy9pZ3dNZzROUHdhdXJ4U0lZeDRIZm54dUdjLzQ4YkR3dndEcE5ZV1pnQUFBSDR3ZkFZSktvWklodmNOQVFjR29HOHdiUUlCQURCb0Jna3Foa2lHOXcwQkJ3RXdIZ1lKWUlaSUFXVURCQUV1TUJFRUREVzJ0K0NRQVl6VVNVc0s3UUlCRUlBN0YyUkFydkREOGhmdVpMNldtY0d6eE96VWs4dFFHYy91M3pLWDdQeFp4YllVaGRQTEVNd01rampZcFpPQVN1cDRZQ1llL2d4N3ltekE3MnM9IiwidmVyc2lvbiI6IjIiLCJ0eXBlIjoiREFUQV9LRVkiLCJleHBpcmF0aW9uIjoxNjE0NzkxNjk3fQ== https://983592080135.dkr.ecr.us-east-2.amazonaws.com

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