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
            sh '''docker run -v /var/run/docker.sock:/var/run/docker.sock deepsecurity/smartcheck-scan-action --image-name cluster-service:latest --smartcheck-host="ae586be628a2b4046be3989278a9d2b6-1694873914.us-east-2.elb.amazonaws.com" --smartcheck-user="administrator" --smartcheck-password="newpass123" --insecure-skip-tls-verify --insecure-skip-registry-tls-verify --preregistry-scan --preregistry-user admin --preregistry-password Trend@123 --findings-threshold \'{"malware": 100, "vulnerabilities": { "defcon1": 100, "critical": 100, "high": 200 }, "contents": { "defcon1": 100, "critical": 100, "high": 200 }, "checklists": { "defcon1": 100, "critical": 100, "high": 200 }}\'
docker run -v $WORKSPACE:/root/app tshethp/dssc-vulnerability-report:v4 --smartcheck-host ae586be628a2b4046be3989278a9d2b6-1694873914.us-east-2.elb.amazonaws.com --smartcheck-user administrator --smartcheck-password newpass123 --insecure-skip-tls-verify --min-severity low ae586be628a2b4046be3989278a9d2b6-1694873914.us-east-2.elb.amazonaws.com:5000/cluster-service:latest
mv $WORKSPACE/DSSCReport.xlsx $WORKSPACE/ClusterService-Vulnerability-report.xlsx
curl -F file=@$WORKSPACE/ClusterService-Vulnerability-report.xlsx -F "initial_comment=DSSC report for Cluster service image" -F channels=buildnotification -H "Authorization: Bearer xoxp-375765158032-376600608661-776771608885-6093db05ce4db6b26c68ca36bc42c4cf" https://slack.com/api/files.upload
'''
            sh '''docker run -v /var/run/docker.sock:/var/run/docker.sock deepsecurity/smartcheck-scan-action --image-name location-service:latest --smartcheck-host="ae586be628a2b4046be3989278a9d2b6-1694873914.us-east-2.elb.amazonaws.com" --smartcheck-user="administrator" --smartcheck-password="newpass123" --insecure-skip-tls-verify --insecure-skip-registry-tls-verify --preregistry-scan --preregistry-user admin --preregistry-password Trend@123 --findings-threshold \'{"malware": 100, "vulnerabilities": { "defcon1": 100, "critical": 100, "high": 100 }, "contents": { "defcon1": 100, "critical": 100, "high": 100 }, "checklists": { "defcon1": 100, "critical": 100, "high": 100 }}\'
docker run -v $WORKSPACE:/root/app tshethp/dssc-vulnerability-report:v4 --smartcheck-host ae586be628a2b4046be3989278a9d2b6-1694873914.us-east-2.elb.amazonaws.com --smartcheck-user administrator --smartcheck-password newpass123 --insecure-skip-tls-verify --min-severity low ae586be628a2b4046be3989278a9d2b6-1694873914.us-east-2.elb.amazonaws.com:5000/location-service:latest
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
docker login -u AWS -p eyJwYXlsb2FkIjoiVUM4TFdDSS9odU5aQWh1MHFrMzlHYmZIRTkvNVQ3emdsd01YaDFia2s3NmNiaEJrNDMrdFp1QUgySHI1d09PNHlYSlZJM0FoZzFxbUJ5WlQ3NmpLZEg5TzM2amc0dmI3K2UyRENjdyt6c0tyRXMvMnVzYk9ZVU9kN3ZMVlZLOHRsWW0yZlFkUEdBdlByVXRHOXNCS2xnZElaMzhxdCtFQlA2Yml6aWJLUytPdmRiSjBqYWZURnIyTnRtLzc3NHpOdFkwckZnbkpJVUo4RUxqRlJNZ0UvZi9rZjVvZk9IY2dmMng5Y2lENk9WTkQ0TUZTZkZrMnJ0YmJGS3N6a0hjcjhveGlBZSt0VzQ0dkZMc2R2NVUwOU9SUDJBeUd2MU1zVTVqTHVnS2hCbCszZHJzSTJRdVpyS3diM0ZNQzlqc1piV1RTSXFBQU5jbkZyVGl4YXZSS1diNjZucjJiWUp5N25mVGZNY1MxZ1E4VEkwb3ZZSEFNdWpVck5oK0NQSXJGWEs1VnZ6K2tqUzdtdUt5ajVMRXRObFlyd3pVQ1kwRUd2YytwVXphalpPUmREUzMxaFA5NXQ0bUZOVndJTk1OeTNxWUdqTmVCMmREQWhIeGN4akdTYitOSUs3MGVndWRLc1BqSDRIZXFHdFVTQ01jM1BFZHlDaWFrTW51TmpjTWFPNmJKR2FyZ0JRS0lwejVSK0dxTEZ4bThUM3N5YWtLaEQzL3BybjVHV1piYlNXYTNjRmR3blMza1JhZkZGREdXNm1VYzFBR213amxXTjBGZWg3cjFST0ZUMzBvUDhPUzFjZnFaalVEUTRjNXgydVVaNThibkgyeE1ENDhtNlZXWjhMa2dwMVRnUzJpN1dJVWxaWm9MNVY1YlZtb1g3S2xQZWk3cW9aRTRETElYZkl0Si9HWm5VY2oyeTFDNXcrQVJ4bmtlV0p5RXMxMFRPQ1IrcWFXc3FSY1VPSVVMQ0N0UTFVT0NaSHRWdnRwTkVEdlZOSWpNOXhPcUV2ZENZTG1iQ01YYXl5SEdxamJtSUdmcm9nR2Y4QXNKblV1SzVMbnRjenBWSVpxNGJNKzNmWkVaT20vcXRjcTZQemJIdnRHU0FLZERPZnVJRVJDVUNhQkQ5TytpOTdSK2wzZVpsNnNYMFh4Q0x4ZXZsc1BsSUJ3dENDZFR4TFVaWHNmYnVwTGM4ZittZnJ0QWkvcmY0VXdEdC9sUERPOUZ1bEZXYkdCVUVMelBwVW1PcTc3WDlKZ3NLR0JENndVZy9ZQXp3YjlFQkZZQmU2RG12MlhEczJBNzVNYVdCUzhJa3lJbnNtZXBmVkVBV3I0bVJrU2taeU5BS1BXaE0xY3FsQ3l5TUdsVG55bEp5dkFBalpsK01kaDRhVG1ZOTlPaytlNTl5MFdRSnBOVUhtRm5hOUNFam5JSE9BdnpFMnBVTmJ1dndPcllZb29UQkZXNDBxc2NqejViUDZNcjVESFEzUVl2bVpjZ2lsS2htQzdpdm5ZNllCcnZ4R2ZEanYrUVVSYnIySU5idHlyWlhuNW9pL1QwaWFjSG1RaFRNNlhIVTRETFkvbFMxWUszY3pYWlhhQVZteTh0eDZ0NEkzT1pzMFBoZVJnaHBvTFV6ZnVtYjZDQmlYdktUaVhXazBhN05UZ3I0VUYxSkswTWF4M2FQcTVQekpMUlZUUEthU2V6U1RkZmhCOU53L3lwSGhienFqR013aXVUNmREUkRrTkFYQWZhTEpZSDNBditzQ0Nra2Mzbi9ITVlPcHRCS0taOUNOWjFYTFpFSFFKbGtEVWNiSGx3TFZMMGdxMHNVcVpzWkJMWjFrTnNUNGJFYy9MM2dFam1jVjdPN3FidXdMK0lyby9FRlBFZExPaGdrMDN1c1JsQUJFZ2xYbzBDK3Q4ckYxcUlhZWZsdlZjM3R4U1g3QVVjbmp3MDlhaUlKSEpMWUV4K2QxeFUrZkw3QlhvK3d1VEdMK29ia2lwWGZySW55YnFpdWQyTGFDMTBrREZBTWkvYy9JRGtxYXYrVjl6WHQ2eVdKTEh0aTY1RlpGQjkvcENXQ1QyWXNjWkF2TDd3T2hhYnQwNW03Wm1rL2c1Q01qZ3dRdmxNUll2WWh6OVVZclFsY0Zqb1FVRXRNblp3MkxEYnFFK3owTHZ3QStSRTJMa1VVTTFLMjhlT0p1ZGREU3JsdlFjTDZadTJvN1Bra3IrZEk3aUVQRmpJaVFWNXp3SGdTS08vOUFkUUxUS0NIRTI3IiwiZGF0YWtleSI6IkFRRUJBSGpCNy9pZ3dNZzROUHdhdXJ4U0lZeDRIZm54dUdjLzQ4YkR3dndEcE5ZV1pnQUFBSDR3ZkFZSktvWklodmNOQVFjR29HOHdiUUlCQURCb0Jna3Foa2lHOXcwQkJ3RXdIZ1lKWUlaSUFXVURCQUV1TUJFRUREeDhnanV4aGZJU3hkbXJMZ0lCRUlBNzBlS2lkVTJYYjJMcVFNTzcrQStsOEJoUU1PQUNvazhvaUlRK3kxaVJuYmZUYlpmWnhoazlDT051UDlLdERYTS8vREVIbGdtWFAxS2ZEamc9IiwidmVyc2lvbiI6IjIiLCJ0eXBlIjoiREFUQV9LRVkiLCJleHBpcmF0aW9uIjoxNjE0ODkyMDY0fQ== https://983592080135.dkr.ecr.us-east-2.amazonaws.com

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