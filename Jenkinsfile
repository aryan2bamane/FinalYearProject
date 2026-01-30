pipeline {
    agent any

    environment {
        REGISTRY   = "someone15me"
        IMAGE_NAME = "voice-gis-app"
        IMAGE_TAG  = "${BUILD_NUMBER}"
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
                script {
                    env.GIT_COMMIT_SHORT = sh(
                        script: "git rev-parse --short HEAD",
                        returnStdout: true
                    ).trim()
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    env.IMAGE_BUILD  = "${REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}"
                    env.IMAGE_COMMIT = "${REGISTRY}/${IMAGE_NAME}:${GIT_COMMIT_SHORT}"
                    env.IMAGE_LATEST = "${REGISTRY}/${IMAGE_NAME}:latest"
                }

                sh '''
                  docker build \
                    -t $IMAGE_BUILD \
                    -t $IMAGE_COMMIT \
                    -t $IMAGE_LATEST \
                    ./MapApp
                '''
            }
        }

        stage('Trivy Image Scan') {
            steps {
                catchError(buildResult: 'UNSTABLE', stageResult: 'UNSTABLE') {
                    sh '''
                      docker run --rm \
                        -v /var/run/docker.sock:/var/run/docker.sock \
                        aquasec/trivy:latest image \
                        --severity HIGH,CRITICAL \
                        --ignore-unfixed \
                        $IMAGE_BUILD
                    '''
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'dockerhub-creds',
                        usernameVariable: 'DOCKER_USER',
                        passwordVariable: 'DOCKER_PASS'
                    )
                ]) {
                    sh '''
                      echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin

                      docker push $IMAGE_BUILD
                      docker push $IMAGE_COMMIT
                      docker push $IMAGE_LATEST

                      docker logout
                    '''
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                withCredentials([
                    file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG_FILE')
                ]) {
                    sh '''
                      export KUBECONFIG=$KUBECONFIG_FILE

                      kubectl apply -f k8s/

                      kubectl get deployment voice-gis-app

                      kubectl set image deployment/voice-gis-app \
                        voice-gis-app=$IMAGE_BUILD

                      kubectl rollout status deployment/voice-gis-app --timeout=180s
                    '''
                }
            }
        }

        stage('Docker Cleanup') {
            steps {
                sh '''
                  docker image prune -f --filter "until=24h"
                  docker builder prune -f --filter "until=24h"
                '''
            }
        }
    }

    post {
        success {
            echo "✅ CI/CD Pipeline SUCCESS"
        }
        unstable {
            echo "⚠️ CI/CD Pipeline UNSTABLE (Security issues detected)"
        }
        failure {
            echo "❌ CI/CD Pipeline FAILED"
        }
        always {
            sh 'df -h'
        }
    }
}
