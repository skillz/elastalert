@Library('gitops-pipeline-library@V2') _

switch(env.BRANCH_NAME) {
  case ~/PR-[0-9]+/: testPipeline()
  break
  case 'master': deploymentPipeline(["gitops-qa"])
  break
}

def testPipeline() {
  container('python') {
    sh """
      python setup.py bdist_wheel
    """
  }
}

def python(Map args=[:], Closure body) {
  def tag = args.get('tag', '3.6-alpine')
  def overrides = args.get('overrides', [:])
  def volumeClaim = env.getProperty('CI_MAVEN_CACHE')

  def container = containerTemplate([
    name: 'python',
    image: "python:${tag}",
    command: 'cat',
    ttyEnabled: true
  ] << overrides)

  podTemplate(
    containers: [container],
  ) {
    body.call()
  }
}

def deploymentPipeline(List repos) {
  baseTemplate(env.DB_NAME) { mysql ->
    slaveTemplates.docker {
      slaveTemplates.github {
        node(POD_LABEL) {
          def scmVars = checkout(scm)
          container('python') {
            sh """
              python setup.py bdist_wheel
            """
          }
          def imageTag = scmVars.GIT_COMMIT
          container('docker') {
            dockerBuildPush(tag: imageTag, dockerBuildArgs: ["--skip-tls-verify-pull"])
          }
          container('github') {
            def prBranch   = "${repoName()}@${scmVars.GIT_BRANCH}"
            def modifyFile = "apps/${repoName()}/release.yaml"
            createPR(
              branch: prBranch,
              repos: repos,
              modifyYaml: [
                file: modifyFile,
                key: "imageTag",
                desiredValue: imageTag])
          }
        }
      }
    }
  }
}
