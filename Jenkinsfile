pipeline {
  agent any

  environment {
    IMAGE_NAME = "tiru43/product-service"
    VERSION = "v1.0.0"  // update per branch
    JAVA_HOME = '/usr/lib/jvm/java-11-openjdk-amd64'
    PATH = "${JAVA_HOME}/bin:${env.PATH}"
  }

  stages {
    stage('Checkout') {
      steps {
        git 'https://github.com/tirumala43/spring-boot-crud-example.git'
      }
    }

    stage('Build JAR') {
      steps {
        sh ' java --version'
        sh '  /usr/bin/mvn clean package -DskipTests'
      }
    }

    stage('Verify Workspace') {
  steps {
    sh '''
      echo "🔍 Current Directory:"
      pwd
      echo "📂 List of Files:"
      ls -la
    '''
  }
}


    stage('Build Docker Image') {
      steps {
        sh 'docker build -t $IMAGE_NAME:$VERSION .'
      }
    }

    stage('Push to Docker Hub') {
      steps {
        withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'USER', passwordVariable: 'PASS')]) {
          sh 'echo $PASS | docker login -u $USER --password-stdin'
          sh 'docker push $IMAGE_NAME:$VERSION'
        }
      }
    }

    stage('Kubernetes Deploy (MicroK8s)') {
      steps {
        sh '''
        sed -i "s|IMAGE_NAME|$IMAGE_NAME:$VERSION|g" kubernetes/deployment.yaml
        kubectl apply -f kubernetes/namespace.yaml
        kubectl apply -f kubernetes/deployment.yaml
        kubectl apply -f kubernetes/service.yaml
        kubectl apply -f kubernetes/ingress.yaml
        '''
      }
    }

    stage('Integration Test') {
      steps {
        sh 'curl -f http://localhost/v1/health || exit 1'
      }
    }

    stage('Vulnerability Scan') {
      steps {
        sh 'trivy image $IMAGE_NAME:$VERSION || true'
      }
    }
  }
}
