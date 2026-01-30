pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "someone15me/voice-gis-app:latest"
    }

    stages {

        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh '''
                      docker build -t $DOCKER_IMAGE ./MapApp
                    '''
                }
            }
        }

        stage('Docker Hub Login') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'dockerhub-creds',
                        usernameVariable: 'DOCKERHUB_USER',
                        passwordVariable: 'DOCKERHUB_PASS'
                    )
                ]) {
                    sh '''
                      echo "$DOCKERHUB_PASS" | docker login -u "$DOCKERHUB_USER" --password-stdin
                    '''
                }
            }
        }

        stage('Push Image to Docker Hub') {
            steps {
                sh '''
                  docker push $DOCKER_IMAGE
                '''
            }
        }

        stage('Deploy with Docker Compose') {
            steps {
                sh '''
                  docker compose down
                  docker compose pull
                  docker compose up -d
                '''
            }
        }
    }

    post {
        success {
            echo "✅ Deployment successful!"
        }
        failure {
            echo "❌ Deployment failed. Check logs."
        }
        always {
            sh 'docker logout'
        }
    }
}
