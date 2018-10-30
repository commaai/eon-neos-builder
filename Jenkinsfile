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
        timeout(time: 1, unit: 'DAYS') {
          sh 'docker run eon-neos-builder ./run_ci.sh'
        }
        
      }
    }
  }
}