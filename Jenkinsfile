pipeline {
    
    agent none

    triggers {
        pollSCM('H 8-20/2 * * 1-5')
    }

    stages {
        stage("lint n' print") {
            failFast true
            parallel {
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
                stage('print') {
                    agent {
                        label 'lutri-go'
                    }
                    steps {                   
                        sh 'echo hola!'
                    }
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
                    sh 'CGO_ENABLED=0 go test ./... -coverprofile=coverage'
                    sh 'go tool cover -html=coverage -o ./coverage.html'
                }
            }
            post {
                success {
                    archiveArtifacts(artifacts: 'lutri-backend/coverage.html', allowEmptyArchive: true)
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
                    stash name: 'build-artifacts', includes: 'build/lutri-backend'
                }
            }
            post {
                success {
                    archiveArtifacts(artifacts: 'lutri-backend/build/lutri-backend', allowEmptyArchive: true)
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
            input {
                message "Deploy to cluster?"
                submitter "admin"
            }
            agent {
                label 'lutri-openshift'
            }
            steps {
                // NOTE: 'oc login' on local machine before this
                sh 'make lutri-up'
            }
        }

        stage('github release') {
            input {
                message "Release to github?"
                submitter "admin"
            }
            agent {
                label 'lutri-go'
            }
            steps {
                dir('lutri-backend/build-artifacts') {
                    unstash 'build-artifacts'
                }
                dir ('lutri-backend') {                    
                    sh 'mv build-artifacts/build/lutri-backend lutri-backend'
                    sh 'zip lutri-backend.zip lutri-backend static/foodsData.json config.yml'

                    // NOTE: for a new release, update the tag argument here
                    sh 'chmod +x -R ${WORKSPACE}'
                    sh './release.sh owner=alparius repo=lutri-devops tag=v0.1.2 filename=./lutri-backend.zip'
                }
            }
        }


    }
}
