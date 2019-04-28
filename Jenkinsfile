#!/usr/bin/env groovy

pipeline {
    agent Host_Node
    stages {
        stage('Build') {
            steps {
                sh Slack_bot.sh Build;
                
            }
        }
    }
}
