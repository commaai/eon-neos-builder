pipeline {
  agent any
  stages {
    stage('Build Docker Image') {
      steps {
        sh 'docker build -t eon-neos-builder .'
      }
    }
    stage('Build Android') {
      steps {
        sh 'docker run eon-neos-builder ./run_ci.sh'
      }
    }
  }
}