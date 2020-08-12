pipeline {
    
    agent none

    stages {

        stage('lint') {
            agent {
                label 'lutri-go'
            }
            steps {
                dir ('lutri-backend') {
                    sh 'GO111MODULE=on CGO_ENABLED=0 golangci-lint run'
                }
            }
        }

        stage('test') {
            agent {
                label 'lutri-go'
            }
            steps {
                dir ('lutri-backend') {
                    sh 'go mod download'
                    sh 'CGO_ENABLED=0 go test ./...'
                }
            }
        }

        stage('build') {
            agent {
                label 'lutri-go'
            }
            steps {
                dir ('lutri-backend') {
                    sh 'rm -rf build'
                    sh 'CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o ./build/lutri-backend'
                }
            }
        }

        stage('docker image') {
            agent {
                label 'lutri-docker'
            }
            steps {
                sh 'docker login'
                sh 'make docker-backend'
                // sh 'make docker-frontend'
            }
        }

        stage('openshift') {
            agent {
                label 'lutri-openshift'
            }
            steps {
                // NOTE: 'oc login' on local machine before this
                sh 'make lutri-up'
            }
        }
    }
}
