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
                sh 'docker build -t $DOCKER_IMAGE .'
            }
        }

        stage('Trivy Security Scan') {
            steps {
                withCredentials([string(credentialsId: 'NVD_API_KEY', variable: 'NVD_API_KEY')]) {
                    sh '''
                        export NVD_API_KEY=$NVD_API_KEY
                        trivy image --exit-code 1 $DOCKER_IMAGE || exit 1
                    '''
                }
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

        stage('Blue-Green Deployment') {
            steps {
                withCredentials([file(credentialsId: 'kubeconfig.yaml', variable: 'KUBECONFIG_FILE')]) {
                    sh '''
                        export KUBECONFIG=$KUBECONFIG_FILE

                        # Determine current live deployment
                        CURRENT=$(kubectl get svc voice-gis-app -o jsonpath='{.spec.selector.app}' || echo "")
                        if [ "$CURRENT" == "blue" ]; then
                            NEW_COLOR="green"
                        else
                            NEW_COLOR="blue"
                        fi
                        echo "Current live deployment: $CURRENT, deploying new version to: $NEW_COLOR"

                        # Deploy new color
                        sed "s/{{COLOR}}/$NEW_COLOR/g" k8s/deployment.yaml | kubectl apply -f -

                        # Wait for pods to be ready
                        echo "Waiting for new pods to become ready..."
                        kubectl rollout status deployment/voice-gis-app-$NEW_COLOR --timeout=120s

                        # Optional: HTTP health check
                        POD_NAME=$(kubectl get pods -l app=$NEW_COLOR -o jsonpath='{.items[0].metadata.name}')
                        for i in {1..12}; do
                            STATUS_CODE=$(kubectl exec $POD_NAME -- curl -s -o /dev/null -w "%{http_code}" http://localhost:5000/health || echo 0)
                            if [ "$STATUS_CODE" == "200" ]; then
                                echo "Pod $POD_NAME is healthy"
                                break
                            fi
                            echo "Waiting for pod health... ($i/12)"
                            sleep 5
                        done

                        if [ "$STATUS_CODE" != "200" ]; then
                            echo "❌ Health check failed! Rolling back..."
                            if [ ! -z "$CURRENT" ]; then
                                kubectl rollout undo deployment/voice-gis-app-$NEW_COLOR
                            fi
                            exit 1
                        fi

                        # Switch service to new color
                        kubectl patch svc voice-gis-app -p '{"spec":{"selector":{"app":"'"$NEW_COLOR"'"}}}'
                        echo "✅ Service switched to $NEW_COLOR"

                        # Optional: clean up old deployment
                        if [ ! -z "$CURRENT" ]; then
                            kubectl delete deployment voice-gis-app-$CURRENT || true
                        fi
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
            echo "🚨 Pipeline failed. Check logs above. Rollback may have occurred."
        }
    }
}
