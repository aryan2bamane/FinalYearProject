pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'someone15me/voice-gis-app:latest'
        DOCKERHUB_USER = credentials('dockerhub-username')
        DOCKERHUB_PASS = credentials('dockerhub-password')
        KUBECONFIG = credentials('kubeconfig')
    }

    stages {

        stage('Checkout Code') {
            steps {
                checkout scm
            }
            post {
                success { echo "✅ Stage succeeded: ${env.STAGE_NAME}" }
                failure { echo "❌ Stage failed: ${env.STAGE_NAME}" }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh '''
                      docker build -t someone15me/voice-gis-app:latest .
                      docker build -t $DOCKER_IMAGE ./MapApp
                    '''
                }
            }
            post {
                success { echo "✅ Stage succeeded: ${env.STAGE_NAME}" }
                failure { echo "❌ Stage failed: ${env.STAGE_NAME}" }
            }
        }

        stage('Trivy Security Scan') {
            steps {
                sh '''
                  trivy image --exit-code 1 someone15me/voice-gis-app:latest
                '''
            }
            post {
                success { echo "✅ Stage succeeded: ${env.STAGE_NAME}" }
                failure { echo "❌ Stage failed: ${env.STAGE_NAME}" }
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
                success { echo "✅ Stage succeeded: ${env.STAGE_NAME}" }
                failure { echo "❌ Stage failed: ${env.STAGE_NAME}" }
            }
        }

        stage('Push Image to Docker Hub') {
            steps {
                sh '''
                  docker push someone15me/voice-gis-app:latest
                  docker push $DOCKER_IMAGE
                '''
            }
            post {
                success { echo "✅ Stage succeeded: ${env.STAGE_NAME}" }
                failure { echo "❌ Stage failed: ${env.STAGE_NAME}" }
            }
        }

        stage('Deploy to Minikube') {
            steps {
                withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG_FILE')]) {
                    sh '''
                      export KUBECONFIG=$KUBECONFIG_FILE

                      kubectl apply -f k8s/service.yaml
                      kubectl apply -f k8s/deployment.yaml

                      kubectl rollout status deployment/voice-gis-app --timeout=120s || \
                      kubectl rollout undo deployment/voice-gis-app
                    '''
                }
            }
            post {
                success { echo "✅ Stage succeeded: ${env.STAGE_NAME}" }
                failure { echo "❌ Stage failed: ${env.STAGE_NAME}" }
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
                success { echo "✅ Stage succeeded: ${env.STAGE_NAME}" }
                failure { echo "❌ Stage failed: ${env.STAGE_NAME}" }
            }
        }
    }

    post {
        success {
            echo "🎉 Pipeline completed successfully!"
        }
        failure {
            echo "🚨 Pipeline failed — check the failed stage above"
        }
        always {
            sh 'docker logout || true'
        }
    }
}
