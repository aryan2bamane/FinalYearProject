pipeline {
    agent any

    options {
        timestamps()
        disableConcurrentBuilds()
        ansiColor('xterm')
    }

    environment {
        REGISTRY        = 'someone15me'
        IMAGE_NAME      = 'voice-gis-app'
        DOCKER_CONTEXT  = './MapApp'
        K8S_DIR         = 'k8s'
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
                script {
                    env.GIT_COMMIT_SHORT = sh(
                        script: 'git rev-parse --short HEAD',
                        returnStdout: true
                    ).trim()
                    env.BUILD_TAG_NUM = "${BUILD_NUMBER}"
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                sh """
                  docker build \
                    -t ${REGISTRY}/${IMAGE_NAME}:${BUILD_TAG_NUM} \
                    -t ${REGISTRY}/${IMAGE_NAME}:${GIT_COMMIT_SHORT} \
                    -t ${REGISTRY}/${IMAGE_NAME}:latest \
                    ${DOCKER_CONTEXT}
                """
            }
        }

        stage('Trivy Image Scan') {
            steps {
                catchError(buildResult: 'SUCCESS', stageResult: 'UNSTABLE') {
                    sh """
                      docker run --rm \
                        -v /var/run/docker.sock:/var/run/docker.sock \
                        aquasec/trivy:latest image \
                        --severity HIGH,CRITICAL \
                        --ignore-unfixed \
                        ${REGISTRY}/${IMAGE_NAME}:${BUILD_TAG_NUM}
                    """
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
                    sh """
                      echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                      docker push ${REGISTRY}/${IMAGE_NAME}:${BUILD_TAG_NUM}
                      docker push ${REGISTRY}/${IMAGE_NAME}:${GIT_COMMIT_SHORT}
                      docker push ${REGISTRY}/${IMAGE_NAME}:latest
                      docker logout
                    """
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                withCredentials([
                    file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG_FILE')
                ]) {
                    sh """
                      export KUBECONFIG=$KUBECONFIG_FILE
                      kubectl apply -f ${K8S_DIR}/
                      kubectl set image deployment/voice-gis-app \
                        voice-gis-app=${REGISTRY}/${IMAGE_NAME}:${BUILD_TAG_NUM}
                      kubectl rollout status deployment/voice-gis-app
                    """
                }
            }
        }

        stage('Docker Cleanup') {
            steps {
                sh """
                  docker image prune -f --filter until=24h
                  docker builder prune -f --filter until=24h
                """
            }
        }
    }

    post {
        success {
            sh 'df -h'
            echo '✅ CI/CD Pipeline SUCCESS'
        }
        unstable {
            echo '⚠️ Pipeline completed with vulnerabilities'
        }
        failure {
            echo '❌ CI/CD Pipeline FAILED'
        }
        always {
            cleanWs()
        }
    }
}
