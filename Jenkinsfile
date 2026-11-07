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