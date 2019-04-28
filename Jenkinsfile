#!/usr/bin/env groovy

pipeline {
    agent { node { label 'Host_Node' } }
    
        stages {
            stage('Build') {
                steps {
                    sh 'chmod +x Slack_bot.sh';
                    sh './Slack_bot.sh Build';
                }
            }
        }
    }

