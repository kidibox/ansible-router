pipeline {
  agent any

  environment {
    PATH = "${JENKINS_HOME}/.rbenv/bin:${JENKINS_HOME}/.rbenv/shims:${JENKINS_HOME}/.local/bin:${PATH}"
    HOME = "${JENKINS_HOME}"
    RBENV_VERSION = "2.4.1"
  }

  options {
    ansiColor('xterm')
    disableConcurrentBuilds()
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
    stage('lint') {
      steps {
        sh('pipenv run yamllint --strict .')
        sh('pipenv run ansible-lint .')
        sh('bundle exec rubocop .')
      }
    }
    stage('build') {
      steps {
        sh('bundle exec vagrant box update')
        // We are using pipenv here because vagrant will call ansible
        sh('pipenv run bundle exec vagrant up')
      }
    }
    stage('test') {
      steps {
        sh('bundle exec rake spec')
      }
    }
  }
  post {
    cleanup {
      sh('bundle exec vagrant destroy -f')
    }
  }
}
