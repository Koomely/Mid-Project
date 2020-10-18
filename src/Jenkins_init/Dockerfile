# Extended from https://github.com/jenkinsci/docker/blob/master/README.md

FROM jenkins/jenkins

# Skip setup wizard
ENV JAVA_OPTS="-Djenkins.install.runSetupWizard=false"

# Add groovy script to Jenkins hook
COPY --chown=jenkins:jenkins init.groovy.d/ /var/jenkins_home/init.groovy.d/
COPY --chown=jenkins:jenkins cred_key.xml /var/jenkins_home/
COPY --chown=jenkins:jenkins docker-cred.xml /var/jenkins_home/
COPY --chown=jenkins:jenkins slave.groovy /var/jenkins_home/
COPY --chown=jenkins:jenkins project.groovy /var/jenkins_home/



# Get plugins
RUN /usr/local/bin/install-plugins.sh \
  workflow-multibranch:latest \
  pipeline-model-definition:latest \
  pipeline-stage-view:latest \
  git:latest \
  jdk-tool:latest \
  credentials:latest \
  ssh-credentials \
  jaxb \
  ssh-slaves:latest

WORKDIR /var/jenkins_home


# Remark: there is no CMD or statement. Since jenkins/jenkins:lts image uses an ENTRYPOINT, this image will inherit that behavior.
