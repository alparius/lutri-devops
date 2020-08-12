pipeline {
    
    agent none

    stages {

        stage('lint') {
            agent {
                label 'golang-lint'
            }
            steps {
                sh 'golangci-lint run'
            }
        }

        stage('test') {
            agent {
                label 'golang'
            }
            steps {
                sh 'go test ./...'
            }
        }

        stage('build') {
            agent {
                label 'golang'
            }
            steps {
                sh 'CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o /lutri-backend'
            }
        }

        // stage('docker image') {
        //     agent {
        //         label 'docker'
        //     }
        //     steps {
        //         sh 'make docker-build'
        //         sh 'make docker-push'
        //     }
        // }

        // stage('kubernetes') {
        //     agent {
        //         label 'kubernetes'
        //     }
        //     steps {
        //         sh 'make lutri-up'
        //     }
        // }
    }
}
