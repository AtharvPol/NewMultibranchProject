pipeline {
    agent any

    environment {
        IMAGE_NAME     = "myapp"
        CONTAINER_NAME = "myapp-container"
        REPO_URL       = "https://github.com/AtharvPol/NewMultibranchProject.git"
    }

    stages {

        stage('Checkout Source') {
            steps {
                checkout scm

                script {
                    echo "===================================="
                    echo "Branch Name : ${env.BRANCH_NAME}"
                    echo "Build Number: ${env.BUILD_NUMBER}"
                    echo "===================================="
                }
            }
        }

        stage('Select Deployment Server') {
            steps {
                script {

                    def servers = [
                        prod : "13.203.207.152",
                        dev  : "13.201.194.60",
                        stage: "13.126.210.218"
                    ]

                    if (!servers.containsKey(env.BRANCH_NAME)) {
                        error("No deployment server configured for branch: ${env.BRANCH_NAME}")
                    }

                    env.SERVER_IP = servers[env.BRANCH_NAME]

                    echo "Deploying ${env.BRANCH_NAME} branch to ${env.SERVER_IP}"
                }
            }
        }

        stage('Deploy Application') {
            steps {

                sh """
                ssh -o StrictHostKeyChecking=no ec2-user@${SERVER_IP} << EOF

                set -e

                echo "==============================="
                echo "Deployment Started"
                echo "Branch : ${BRANCH_NAME}"
                echo "Server : ${SERVER_IP}"
                echo "==============================="

                # Clone repository if not present
                if [ ! -d ~/NewMultibranchProject ]; then
                    git clone ${REPO_URL} ~/NewMultibranchProject
                fi

                cd ~/NewMultibranchProject

                # Update source
                git fetch origin
                git checkout ${BRANCH_NAME}
                git reset --hard origin/${BRANCH_NAME}
                git pull origin ${BRANCH_NAME}

                echo "Source code updated."

                # Stop old container
                docker stop ${CONTAINER_NAME} || true
                docker rm ${CONTAINER_NAME} || true

                # Remove old image
                docker rmi ${IMAGE_NAME}:latest || true

                # Build Docker image
                docker build -t ${IMAGE_NAME}:latest .

                # Run Docker container
                docker run -d \\
                    --name ${CONTAINER_NAME} \\
                    --restart always \\
                    -p 80:80 \\
                    ${IMAGE_NAME}:latest

                docker ps

                echo "Deployment Completed Successfully."

                EOF
                """
            }
        }

        stage('Verify Deployment') {
            steps {
                sh """
                ssh -o StrictHostKeyChecking=no ec2-user@${SERVER_IP} '
                    docker ps
                '
                """
            }
        }
    }

    post {

        success {
            echo "======================================="
            echo "Deployment Successful"
            echo "Branch : ${env.BRANCH_NAME}"
            echo "Server : ${env.SERVER_IP}"
            echo "======================================="
        }

        failure {
            echo "======================================="
            echo "Deployment Failed"
            echo "Branch : ${env.BRANCH_NAME}"
            echo "======================================="
        }

        always {
            cleanWs()
        }
    }
}
