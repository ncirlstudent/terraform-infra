// WIP ...
pipeline {
    agent any

    environment {
        TF_VAR_access_key = credentials('AWS_ACCESS_KEY_ID')
        TF_VAR_secret_key = credentials('AWS_SECRET_ACCESS_KEY')
        TF_VAR_session_token = credentials('AWS_SESSION_TOKEN')
        TF_VAR_remote_state = credentials('remote_state')
        TF_VAR_AWS_REGION = credentials('aws_region')
        TF_VAR_branch_name = "${BRANCH_NAME}"
        TF_VAR_project_name = env.GIT_URL.replace('.git', '').split('/').last()                              
    }

    stages {
        stage('Checkout') {
            steps {
                script {
                    
                    checkout scm
                }
            }
        }

        stage('Terraform backend') {
            steps {
                script {
                    withCredentials([
                        string(credentialsId: 'AWS_ACCESS_KEY_ID', variable: 'ACCESS_KEY'),
                        string(credentialsId: 'AWS_SECRET_ACCESS_KEY', variable: 'SECRET_KEY'),
                        string(credentialsId: 'AWS_SESSION_TOKEN', variable: 'SESSION_TOKEN'),
                        string(credentialsId: 'remote_state', variable: 'REMOTE_STATE'),
                        string(credentialsId: 'aws_region', variable: 'AWS_REGION')
                    ]) {
                    writeFile file: 'backend.tf', text: """
                    provider "aws" {
                        region = "${AWS_REGION}"
                        access_key = "${ACCESS_KEY}"
                        secret_key = "${SECRET_KEY}"
                        token      = "${SESSION_TOKEN}"
                    }

                    terraform {
                        required_version = ">= 0.13.5"
                        required_providers {
                            aws = {
                                source  = "hashicorp/aws"
                                version = ">= 4.67.0"
                            }
                        }
                        backend "s3" {
                            bucket         = "${REMOTE_STATE}"
                            dynamodb_table = "${REMOTE_STATE}"
                            region         = "${AWS_REGION}"
                            key            = "${TF_VAR_project_name}"
                            access_key = "${ACCESS_KEY}"
                            secret_key = "${SECRET_KEY}"
                            token      = "${SESSION_TOKEN}"
                        }
                    }
                    """
                    }
                    sh 'cat backend.tf'
                }
            }
        }

        stage('Terraform Init') {
            steps {
                script {
                    
                    sh 'terraform init'
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                script {
                   
                    sh 'terraform plan -out=tfplan'
                }
            }
        }

        stage('Manual Approval') {
            steps {
                script {
                    // Request manual approval
                    input "Do you approve the Terraform changes? (Click 'Proceed' to approve)"
                }
            }
        }
        
        stage('Terraform Apply') {
            steps {
                script {
                    
                    sh 'terraform apply -auto-approve tfplan'
                }
            }
        }

        stage('Clean Up Workspace') {
            steps {
                script {
                    // Delete the entire workspace
                    deleteDir()
                }
            }
        }
    }
}