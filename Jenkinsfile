pipeline {
    agent any

    environment {
        REGISTRY = "someone15me"
        IMAGE_NAME = "voice-gis-app"
        // # Dynamically tag the image with BUILD_NUMBER to force Kubernetes to pull the new image
        DOCKER_IMAGE = "${REGISTRY}/${IMAGE_NAME}:${BUILD_NUMBER}"
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                sh '''
                    docker build -t $DOCKER_IMAGE ./MapApp
                '''
            }
        }

        stage('Push to Docker Hub') {
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
                        # Delete old resources (optional, ensures no stale pods)
                        kubectl delete deployment voice-gis-app --ignore-not-found
                        kubectl delete service voice-gis-app --ignore-not-found
                        kubectl delete ingress voice-gis-app-ingress --ignore-not-found

                        # Apply manifests
                        kubectl apply -f k8s/deployment.yaml
                        kubectl apply -f k8s/service.yaml
                        kubectl apply -f k8s/ingress.yaml

                        # Wait for deployment rollout
                        kubectl rollout status deployment/voice-gis-app --timeout=120s
                    '''
                }
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
    }
}
