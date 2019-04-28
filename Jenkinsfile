#!/usr/bin/env groovy

pipeline {
    agent { node { label 'Host_Node' }
    
        stages {
            stage('Build') {
                steps {
                    sh './Slack_bot.sh Build';
                }
            }
        }
    }

