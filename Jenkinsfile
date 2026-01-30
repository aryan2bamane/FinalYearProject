pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "someone15me/voice-gis-app:latest"
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Image') {
            steps {
                sh '''
                  docker build -t $DOCKER_IMAGE ./MapApp
                '''
            }
        }

        stage('Docker Login & Push') {
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
                      docker push $DOCKER_IMAGE
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
            echo "CI/CD Pipeline SUCCESS"
        }
        failure {
            echo "CI/CD Pipeline FAILED"
        }
    }
}
