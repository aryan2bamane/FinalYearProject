pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'someone15me/voice-gis-app:latest'
    }

    stages {
        stage('Checkout Code') {
            steps {
                checkout scm
            }
            post {
                failure {
                    echo "❌ Stage failed: ${env.STAGE_NAME}"
                }
                success {
                    echo "✅ Stage succeeded: ${env.STAGE_NAME}"
                }
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
            post {
                failure {
                    echo "❌ Stage failed: ${env.STAGE_NAME}"
                }
                success {
                    echo "✅ Stage succeeded: ${env.STAGE_NAME}"
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
            post {
                failure {
                    echo "❌ Stage failed: ${env.STAGE_NAME}"
                }
                success {
                    echo "✅ Stage succeeded: ${env.STAGE_NAME}"
                }
            }
        }

        stage('Push Image to Docker Hub') {
            steps {
                sh '''
                  docker push $DOCKER_IMAGE
                '''
            }
            post {
                failure {
                    echo "❌ Stage failed: ${env.STAGE_NAME}"
                }
                success {
                    echo "✅ Stage succeeded: ${env.STAGE_NAME}"
                }
            }
        }

        stage('Deploy with Docker Compose') {
            steps {
                sh '''
                  echo "Stopping existing container if running..."
                  docker rm -f voice_gis_app || true

                  echo "Deploying latest version..."
                  docker compose pull
                  docker compose up -d
                '''
            }
            post {
                failure {
                    echo "❌ Stage failed: ${env.STAGE_NAME}"
                }
                success {
                    echo "✅ Stage succeeded: ${env.STAGE_NAME}"
                }
            }
        }
    }

    post {
        success {
            echo '🎉 Pipeline completed successfully!'
        }
        failure {
            echo '🚨 Pipeline failed — check the failed stage above'
        }
        always {
            sh 'docker logout || true'
        }
    }
}
