pipeline {
  agent any

  environment {
    PATH = "${JENKINS_HOME}/.rbenv/bin:${JENKINS_HOME}/.rbenv/shims:${PATH}"
    RBENV_VERSION = "2.4.1"
  }

  stages {
    stage('bundler') {
      steps {
        sh 'rbenv install --skip-existing $RBENV_VERSION'
        sh 'bundle install'
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
