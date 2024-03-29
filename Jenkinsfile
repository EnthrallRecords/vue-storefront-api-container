pipeline {
  agent none
  environment {
    VER = "1.12.4"
  }
  stages {
    stage('Build API') {
      agent {
        kubernetes {
          inheritFrom 'kaniko'
        }
      }
      environment {
        PATH = "/busybox:/kaniko:$PATH"
      }
      steps {
        checkout([$class: 'GitSCM', branches: [[name: env.GIT_BRANCH]],
          userRemoteConfigs: [[url: 'https://github.com/EnthrallRecords/vue-storefront-api-container.git']]])
        container(name: 'kaniko', shell: '/busybox/sh') {
          sh '''#!/busybox/sh
          /kaniko/executor --build-arg VERSION=$VER -c `pwd` --skip-tls-verify \
            --destination=containers.internal/vue-storefront-api:$VER \
            --destination=containers.internal/vue-storefront-api:$BUILD_ID
          '''
        }
      }
    }
    stage('Build API with Braintree') {
      agent {
        kubernetes {
          inheritFrom 'kaniko'
        }
      }
      environment {
        PATH = "/busybox:/kaniko:$PATH"
      }
      steps {
        checkout([$class: 'GitSCM', branches: [[name: env.GIT_BRANCH]],
          userRemoteConfigs: [[url: 'https://github.com/EnthrallRecords/vue-storefront-api-container.git']]])
        container(name: 'kaniko', shell: '/busybox/sh') {
          sh '''#!/busybox/sh
          /kaniko/executor --build-arg VERSION=$VER -c `pwd` -f Dockerfile-braintree --skip-tls-verify \
            --destination=containers.internal/vue-storefront-api:braintree-$VER \
            --destination=containers.internal/vue-storefront-api:braintree-$BUILD_ID
          '''
        }
      }
    }
    stage('Deploy') {
      agent {
        kubernetes {
          label "kubectl"
          yaml """
kind: Pod
metadata:
  name: kaniko
spec:
  serviceAccount: jenkins
  containers:
  - name: kubectl
    image: containers.internal/kubectl:latest
    imagePullPolicy: Always
    command:
    - sh
    args:
    - -c
    - cat
    tty: true
""" 
        }
      }
      steps {
        container(name: 'kubectl', shell: '/bin/sh') {
          sh '''#!/bin/sh
          kubectl -n enthrall-test-store set image deployment.v1.apps/vuestorefrontapi vuestorefrontapi=containers.internal/vue-storefront-api:braintree-$BUILD_ID
          '''
        }
      }
    }
  }
}
