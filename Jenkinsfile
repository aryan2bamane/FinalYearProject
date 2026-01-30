pipeline {
    agent any

    environment {
        REGISTRY = "someone15me"
        IMAGE_NAME = "voice-gis-app"
        DOCKER_TAG = "${BUILD_NUMBER}"                // unique per build
        DOCKER_IMAGE = "${REGISTRY}/${IMAGE_NAME}:${DOCKER_TAG}"
        KUBE_DEPLOYMENT = "voice-gis-app"
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                sh """
                  # Build image without cache to include all changes
                  docker build --no-cache -t $DOCKER_IMAGE ./MapApp
                """
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
                      docker push $DOCKER_IMAGE
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

                        # Delete old deployment/service if you want full cleanup
                        # kubectl delete deployment voice-gis-app --ignore-not-found
                        # kubectl delete service voice-gis-app --ignore-not-found

                        # Apply manifests (deployment already exists, just update image)
                        kubectl apply -f k8s/service.yaml
                        kubectl apply -f k8s/deployment.yaml


                        # Update deployment with the new image
                        kubectl set image deployment/voice-gis-app voice-gis-app=$DOCKER_IMAGE 

                        # Wait for rollout to finish
                        kubectl rollout status deployment/voice-gis-app --timeout=180s
                    """
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
