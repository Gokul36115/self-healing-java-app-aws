pipeline {
    agent any

    environment {
        IMAGE_NAME = 'gokul36115/selfheal-app'
        IMAGE_TAG  = "build-${env.BUILD_NUMBER}"
    }

    stages {
        stage('Build & Test') {
            steps {
                dir('app') {
                    sh './mvnw -B clean package'
                }
            }
        }

        stage('Docker Build') {
            steps {
                dir('app') {
                    sh 'docker build -t $IMAGE_NAME:$IMAGE_TAG -t $IMAGE_NAME:latest .'
                }
            }
        }

        stage('Smoke Test') {
            steps {
                sh '''
                    docker rm -f selfheal-smoke || true
                    docker run -d --name selfheal-smoke -p 8082:8080 $IMAGE_NAME:$IMAGE_TAG
                    for i in $(seq 1 30); do
                        if curl -sf http://localhost:8082/actuator/health | grep -q '"status":"UP"'; then
                            echo "Smoke test PASSED after $((i*2)) seconds"
                            exit 0
                        fi
                        sleep 2
                    done
                    echo "Smoke test FAILED - app did not become healthy in 60s"
                    docker logs selfheal-smoke | tail -50
                    exit 1
                '''
            }
            post {
                always { sh 'docker rm -f selfheal-smoke || true' }
            }
        }

        stage('Docker Push') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-creds',
                                                  usernameVariable: 'DH_USER',
                                                  passwordVariable: 'DH_TOKEN')]) {
                    sh '''
                        echo "$DH_TOKEN" | docker login -u "$DH_USER" --password-stdin
                        docker push $IMAGE_NAME:$IMAGE_TAG
                        docker push $IMAGE_NAME:latest
                    '''
                }
            }
        }
    }

    post {
        always  { sh 'docker logout || true' }
        success { echo "Build #${env.BUILD_NUMBER} succeeded - pushed ${IMAGE_NAME}:${IMAGE_TAG}" }
        failure { echo "Build #${env.BUILD_NUMBER} failed - check the stage logs above" }
    }
}