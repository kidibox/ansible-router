pipeline {
  agent any

  stages {
    stage('bundler') {
      steps {
        sh('bundler install')
      }
    }
    stage('vagrant up') {
      steps {
        sh('vagrant up')
      }
    }
    stage('rake spec') {
      steps {
        sh('rake spec')
      }
    }
  }
  post {
    cleanup {
      sh('vagrant destroy -f')
    }
  }
}
