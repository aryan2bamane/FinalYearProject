pipeline {
    agent any

    environment {
        REGISTRY = "someone15me"
        IMAGE_NAME = "voice-gis-app"
        BUILD_TAG = "${BUILD_NUMBER}"
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
                script {
                    GIT_COMMIT_SHORT = sh(
                        script: "git rev-parse --short HEAD",
                        returnStdout: true
                    ).trim()
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    IMAGE_BUILD = "${REGISTRY}/${IMAGE_NAME}:${BUILD_TAG}"
                    IMAGE_COMMIT = "${REGISTRY}/${IMAGE_NAME}:${GIT_COMMIT_SHORT}"
                    IMAGE_LATEST = "${REGISTRY}/${IMAGE_NAME}:latest"

                    sh """
                      docker build \
                        -t ${IMAGE_BUILD} \
                        -t ${IMAGE_COMMIT} \
                        -t ${IMAGE_LATEST} \
                        ./MapApp
                    """
                }
            }
        }

        stage('Trivy Image Scan') {
            steps {
                catchError(buildResult: 'UNSTABLE', stageResult: 'UNSTABLE') {
                    sh """
                      if ! command -v trivy >/dev/null 2>&1; then
                        curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh
                        sudo mv trivy /usr/local/bin/
                      fi

                      trivy image \
                        --severity HIGH,CRITICAL \
                        --ignore-unfixed \
                        ${IMAGE_BUILD}
                    """
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-creds',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh """
                      echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin

                      docker push ${IMAGE_BUILD}
                      docker push ${IMAGE_COMMIT}
                      docker push ${IMAGE_LATEST}

                      docker logout
                    """
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG_FILE')]) {
                    sh """
                        export KUBECONFIG=$KUBECONFIG_FILE

                        kubectl set image deployment/voice-gis-app \
                          voice-gis-app=${IMAGE_BUILD}

                        kubectl rollout status deployment/voice-gis-app --timeout=180s
                    """
                }
            }
        }

        stage('Docker Cleanup') {
            steps {
                sh '''
                  docker image prune -f
                  docker builder prune -f
                '''
            }
        }
    }

    post {
        success {
            echo "✅ CI/CD Pipeline SUCCESS"
        }
        failure {
            echo "❌ CI/CD Pipeline FAILED"
        }
        always {
            sh 'df -h'
        }
    }
}
