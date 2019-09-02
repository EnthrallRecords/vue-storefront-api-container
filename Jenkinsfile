pipeline {
  environment {
    VER = "1.8.1"
  }
  agent {
    kubernetes {
      label "kaniko"
      yaml """
kind: Pod
metadata:
  name: kaniko
spec:
  containers:
  - name: kaniko
    image: gcr.io/kaniko-project/executor:debug-v0.10.0
    command:
    - /busybox/cat
    tty: true
"""
    }
  }
  stages {
    stage('Build with Kaniko') {
      environment {
        PATH = "/busybox:/kaniko:$PATH"
      }
      steps {
        git branch: env.BRANCH_NAME,
          url: 'https://github.com/EnthrallRecords/vue-storefront-api-container.git'
        container(name: 'kaniko', shell: '/busybox/sh') {
          sh '''#!/busybox/sh
          /kaniko/executor -c `pwd` --skip-tls-verify --destination=containers.internal/vue-storefront-api:$VER --destination=containers.internal/vue-storefront-api:$BUILD_ID --destination=containers.internal/vue-storefront-api:latest 
          '''
        }
      }
    }
    stage('Deploy') {
      steps {
        container(name: 'kubectl', shell: '/bin/sh') {
          sh '''#!/bin/sh
          kubectl -n vuestorefront set image deployment.v1.apps/vuestorefrontapi vuestorefrontapi=containers.internal/vue-storefront-api:$BUILD_ID
          '''
        }
      }
    }
  }
}

def getRepoURL() {
  sh "git config --get remote.origin.url > .git/remote-url"
  return readFile(".git/remote-url").trim()
}
 
def getCommitSha() {
  sh "git rev-parse HEAD > .git/current-commit"
  return readFile(".git/current-commit").trim()
}
 
def updateGithubCommitStatus(build) {
  // workaround https://issues.jenkins-ci.org/browse/JENKINS-38674
  repoUrl = getRepoURL()
  commitSha = getCommitSha()
 
  step([
    $class: 'GitHubCommitStatusSetter',
    reposSource: [$class: "ManuallyEnteredRepositorySource", url: repoUrl],
    commitShaSource: [$class: "ManuallyEnteredShaSource", sha: commitSha],
    errorHandlers: [[$class: 'ShallowAnyErrorHandler']],
    statusResultSource: [
      $class: 'ConditionalStatusResultSource',
      results: [
        [$class: 'BetterThanOrEqualBuildResult', result: 'SUCCESS', state: 'SUCCESS', message: build.description],
        [$class: 'BetterThanOrEqualBuildResult', result: 'FAILURE', state: 'FAILURE', message: build.description],
        [$class: 'AnyBuildResult', state: 'PENDING', message: build.description]
      ]
    ]
  ])
}