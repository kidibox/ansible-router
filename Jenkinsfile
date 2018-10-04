pipeline {
  agent any

  environment {
    PATH = "${JENKINS_HOME}/.rbenv/bin:${JENKINS_HOME}/.rbenv/shims:${JENKINS_HOME}/.local/bin:${PATH}"
    HOME = "${JENKINS_HOME}"
    RBENV_VERSION = "2.4.1"
  }

  options {
    ansiColor('xterm')
    timestamps()
  }

  stages {
    stage('deps') {
      steps {
        sh 'rbenv install --skip-existing $RBENV_VERSION'
        sh 'gem install bundler --no-ri --no-rdoc'
        sh 'rbenv rehash'
        sh 'bundle install'
        sh 'pipenv install'
      }
    }
    stage('build') {
      steps {
        sh('pipenv run bundle exec vagrant up')
      }
    }
    stage('test') {
      steps {
        sh('pipenv run rake spec')
      }
    }
  }
  post {
    cleanup {
      sh('pipenv run bundle exec vagrant destroy -f')
    }
  }
}
