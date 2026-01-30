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
        }

        stage('Build Docker Image') {
            steps {
                echo "Building Docker image from ./MapApp"
                sh 'docker build -t $DOCKER_IMAGE ./MapApp'
            }
        }

        stage('Trivy Security Scan') {
            steps {
                echo "Running security scan with Trivy"
                sh '''
                    trivy image --exit-code 0 --severity CRITICAL $DOCKER_IMAGE
                '''
            }
        }

        stage('Docker Hub Login & Push') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
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
                withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG_FILE')]) {
                    sh '''
                        export KUBECONFIG=$KUBECONFIG_FILE

                        # Apply deployment and service
                        kubectl apply -f k8s/deployment.yaml
                        kubectl apply -f k8s/service.yaml

                        # Wait for pods to be ready
                        kubectl rollout status deployment/voice-gis-app --timeout=120s
                    '''
                }
            }
        }
    }

    post {
        success {
            echo "🎉 Pipeline completed successfully!"
        }
        failure {
            echo "🚨 Pipeline failed. Check logs above."
        }
    }
}
