#!/usr/bin/env groovy

pipeline {
    agent agent-node
    stages {
        stage('Build') {
            steps {
                sh './Slack_bot.sh Build';
                
            }
        }
    }
}
