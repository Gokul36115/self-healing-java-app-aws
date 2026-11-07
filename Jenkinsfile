pipeline {
    agent any

    stages {
        stage('Build & Test') {
            steps {
                dir('app') {
                    sh './mvnw -B clean package'
                }
            }
        }
    }

    post {
        success { echo "Build #${env.BUILD_NUMBER} succeeded" }
        failure { echo "Build #${env.BUILD_NUMBER} failed - check the stage logs above" }
    }
}