pipeline {
    agent any

    parameters {
        choice(name: 'OS', choices: ['linux', 'darwin', 'windows', 'all'], description: 'Available operating system')
        choice(name: 'ARCH', choices: ['amd64', 'arm64', 'all'], description: 'Available architectures')
    }

    environment {
        REPO = 'https://github.com/shinbuiev/kbot'
        BRANCH = 'main'
        REGISTRY = 'shinbuev'
    }

    stages {
        stage('Example') {
            steps {
                echo "Build for platform ${params.OS}"

                echo "Build for arch: ${params.ARCH}"

            }
        }
        stage("clone") {
            steps {
                echo 'Clone stage'
                git branch: "${BRANCH}", url: "${REPO}"
            }
        }
        stage("test") {
            steps {
                echo 'Testing'
                sh 'make test'
            }
        }
        stage("build") {
            steps {
                echo 'Build'
                sh 'make build '
            }
        }
        stage("image") {
            steps {
                echo 'Create image'
                sh 'make image'
            }
        }
        stage("push") {
            steps {
                script {
                    docker.withRegistry('', 'dockerhub') {
                    sh 'make push'
                    }
                }
            }
        }
    }
}
