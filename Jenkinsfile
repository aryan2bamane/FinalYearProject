pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'someone15me/voice-gis-app:latest'
    }

    options {
        timestamps()
        ansiColor('xterm')
    }

    stages {

        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }

        stage('Verify Tooling') {
            steps {
                sh '''
                    docker --version
                    trivy --version
                    kubectl version --client
                '''
            }
        }

        stage('Build Docker Image') {
            steps {
                sh '''
                    echo "[INFO] Building Docker image"
                    docker build -t ${DOCKER_IMAGE} ./MapApp
                '''
            }
        }

        stage('Trivy Security Scan') {
            steps {
                sh '''
                    echo "[INFO] Running Trivy scan"
                    trivy image \
                      --severity HIGH,CRITICAL \
                      --scanners vuln,secret \
                      --exit-code 1 \
                      ${DOCKER_IMAGE}
                '''
            }
        }

        stage('Docker Hub Login & Push') {
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
                        docker push ${DOCKER_IMAGE}
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

                        kubectl apply -f k8s/deployment.yaml
                        kubectl apply -f k8s/service.yaml

                        kubectl rollout status deployment/voice-gis-app --timeout=120s
                    '''
                }
            }
        }
    }

    post {
        success {
            echo "Pipeline completed successfully"
        }
        failure {
            echo "Pipeline failed – check logs"
        }
    }
}
