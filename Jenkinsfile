#!groovy

build('image-holmes', 'docker-host') {
  checkoutRepo()
  loadBuildUtils()

  def pipeDefault
  runStage('load pipeline') {
    env.JENKINS_LIB = "build_utils/jenkins_lib"
    pipeDefault = load("${env.JENKINS_LIB}/pipeDefault.groovy")
  }

  pipeDefault() {
    runStage('fetch submodules') {
      withGithubPrivkey {
        sh 'make submodules'
      }
    }

    runStage('build image') {
      sh 'make build_image'
    }

    try {
      if (env.BRANCH_NAME == 'master' || env.BRANCH_NAME.startsWith('epic')) {
        runStage('push image') {
          sh 'make push_image'
        }
      }
    } finally {
      runStage('rm local image') {
        sh 'make rm_local_image'
      }
    }
  }
}
