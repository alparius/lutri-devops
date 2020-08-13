pipeline {
    
    agent none

    triggers {
        pollSCM('H 8-20/2 * * 1-5')
    }

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

        stage('test & coverage') {
            agent {
                label 'lutri-go-pod'
            }
            steps {
                dir ('lutri-backend') {
                    sh 'go mod download'
                    sh 'CGO_ENABLED=0 go test ./... -cover'
                }
            }
        }

        stage('build app') {
            agent {
                label 'lutri-go'
            }
            steps {
                dir ('lutri-backend') {
                    sh 'rm -rf build'
                    sh 'CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o ./build/lutri-backend'
                }
            }
            post {
                success {
                    archiveArtifacts(artifacts: 'lutri-backend/build/lutri-backend, lutri-backend/static/*, lutri-backend/config.yml', allowEmptyArchive: true)
                }
            }
        }

        stage('docker build & push') {
            agent {
                label 'lutri-docker'
            }
            steps {
                sh 'docker login'
                sh 'make docker-backend-jenkins' // this docker image has no go compiling in it
                // sh 'make docker-frontend'
            }
        }

        stage('openshift deploy') {
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
