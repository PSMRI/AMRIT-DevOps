pipeline {
    agent any

    parameters {
        choice(name: 'project', choices: ['CICD_Test', 'Dev', 'UAT', 'Sanjeevni_Assam'], description: 'Choose the project')
    }
    
    tools {
        jdk 'JDK_17'
        nodejs 'NODE_20'
        maven 'MAVEN_3.9.8'
    }
    
    

    stages {
        
        stage('Load Environment Variables') {
            steps {
                echo "Setting environment variables based on the selected project"
                
                script {
                  
                    sh "rm -rf ${env.WORKSPACE}/repos"
                    sh "mkdir -p ${env.WORKSPACE}/repos"
                    sh "rm -rf ${env.WORKSPACE}/target "
                    sh "mkdir -p ${env.WORKSPACE}/target"
                    
                  
                    if (params.project == 'CICD_Test') {
                        
                        
                        env.WILDFLY_HOST = 'IP'
                        env.WILDFLY_USER = 'USER'
                        withCredentials([string(credentialsId: 'USER1', variable: 'WILDFLY_PASSWORD')]) {
                            env.WILDFLY_PASSWORD=WILDFLY_PASSWORD
                        }
                        env.TARGET_DIR = 'target'
                        env.REMOTE_DEPLOY_DIR='E:\\AppServer\\wildfly-30.0.0.Final\\wildfly-30.0.0.Final\\standalone\\deployments'
                        env.REMOTE_DEPLOY_DIR2='E:/AppServer/wildfly-30.0.0.Final/wildfly-30.0.0.Final/standalone/deployments'
                        
                        env.COMMON_API="https://amritdemo.piramalswasthya.org/commonapi-v3.0.0/"
                        env.COMMON_API_BASE="https://amritdemo.piramalswasthya.org/commonapi-v3.0.0/"
                        env.COMMON_API_BASE_URL="https://amritdemo.piramalswasthya.org/commonapi-v3.0.0/"
                        
                        
                        env.ADMIN_API="https://amritdemo.piramalswasthya.org/adminapi-v3.0.0/"
                        env.ADMIN_API_BASE="https://amritdemo.piramalswasthya.org/adminapi-v3.0.0/"
                        env.ADMIN_API_BASE_URL="https://amritdemo.piramalswasthya.org/adminapi-v3.0.0/"
                        
                        env.ECD_API="https://amritdemo.piramalswasthya.org/ecdapi/"
                        env.ECD_API_BASE="https://amritdemo.piramalswasthya.org/ecdapi/"
                        env.ECD_API_BASE_URL="https://amritdemo.piramalswasthya.org/ecdapi/"
                        
                        env.COMMON_API_OPEN="https://amritdemo.piramalswasthya.org/commonapi-v3.0.0/"
                        
                        env.INVENTORY_API="https://amritdemo.piramalswasthya.org/Inventoryapi-v3.0.0/"
                        env.INVENTORY_API_BASE="https://amritdemo.piramalswasthya.org/Inventoryapi-v3.0.0/"
                        env.INVENTORY_API_BASE_URL="https://amritdemo.piramalswasthya.org/Inventoryapi-v3.0.0/"
                        
                        env.MMU_API="https://amritdemo.piramalswasthya.org/mmuapi-v3.0.0/"
                        env.MMU_API_BASE="https://amritdemo.piramalswasthya.org/mmuapi-v3.0.0/"
                        env.MMU_API_BASE_URL="https://amritdemo.piramalswasthya.org/mmuapi-v3.0.0/"
                        
                        env.FHIR_API="https://amritdemo.piramalswasthya.org/fhirapi-v3.0.0/"
                        env.FHIR_API_BASE="https://amritdemo.piramalswasthya.org/fhirapi-v3.0.0/"
                        env.FHIR_API_BASE_URL="https://amritdemo.piramalswasthya.org/fhirapi-v3.0.0/"
                        
                        env.SCHEDULER_API="https://amritdemo.piramalswasthya.org/schedulerapi-v3.0.0/"
                        env.SCHEDULER_API_BASE="https://amritdemo.piramalswasthya.org/schedulerapi-v3.0.0/"
                        env.SCHEDULER_API_BASE_URL="https://amritdemo.piramalswasthya.org/schedulerapi-v3.0.0/"
                        
                        env.TM_API="https://amritdemo.piramalswasthya.org/tmapi-v3.0.0/"
                        env.TM_API_BASE="https://amritdemo.piramalswasthya.org/tmapi-v3.0.0/"
                        env.TM_API_BASE_URL="https://amritdemo.piramalswasthya.org/tmapi-v3.0.0/"
                        
                        env.HWC_API="https://amritdemo.piramalswasthya.org/hwc-facility-service-v3.0.0/"
                        env.HWC_API_BASE="https://amritdemo.piramalswasthya.org/hwc-facility-service-v3.0.0/"
                        env.HWC_API_BASE_URL="https://amritdemo.piramalswasthya.org/hwc-facility-service-v3.0.0/"
                        
                        env.GRIEVANCE_API_BASE_URL="https://grievance1097naco.piramalswasthya.org"
                        env.GRIEVANCE_USERNAME=""
                        env.GRIEVANCE_PASSWORD=""
                        env.GRIEVANCE_USER_AUTHENTICATE=""
                        env.GRIEVANCE_DATA_SYNC_DURATION=15
                        env.SESSION_STORAGE_ENC_KEY=""
                        env.JWT_SECRET_KEY=""
                        
                        env.SERVER_IP=""
                        env.SWYMED_IP="IP"
                        env.COMMON_API_OPEN_SYNC="https://amritdemo.piramalswasthya.org/commonapi-v3.0.0/"
                        env.SCHEDULER_UI="https://amritdemo.piramalswasthya.org/hwc-scheduler/"
                        env.INVENTORY_UI="https://amritdemo.piramalswasthya.org/hwc-inventory/"
                        
                        env.IDENTITY_API="https://amritdemo.piramalswasthya.org/identity-v3.0.0/"
                        env.IDENTITY_API_BASE="https://amritdemo.piramalswasthya.org/identity-v3.0.0/"
                        env.IDENTITY_API_BASE_URL="https://amritdemo.piramalswasthya.org/identity-v3.0.0/"
                        
                        env.HELPLINE104_API="https://amritdemo.piramalswasthya.org/104api-v3.0.0/"
                        env.HELPLINE104_API_BASE="https://amritdemo.piramalswasthya.org/104api-v3.0.0/"
                        env.MMU_UI="https://amritdemo.piramalswasthya.org/mmu"
                        env.IOT_API=""
                        env.DATABASE_URL="jdbc:mysql://localhost:3306/db_iemr?autoReconnect=true&useSSL=false&allowPublicKeyRetrieval=true"
                        env.DATABASE_USERNAME="dbuser"
                        withCredentials([string(credentialsId: 'DB_PASS_CICD_TEST', variable: 'DATABASE_PASSWORD')]) {
                            env.DATABASE_PASSWORD=DATABASE_PASSWORD
                        }
                        env.DATABASE_IDENTITY_URL="jdbc:mysql://localhost:3306/db_identity?autoReconnect=true&useSSL=false&allowPublicKeyRetrieval=true"
                        env.DATABASE_1097_IDENTITY_URL="jdbc:mysql://localhost:3306/db_1097_identity?autoReconnect=true&useSSL=false&allowPublicKeyRetrieval=true"
                        env.DATABASE_IDENTITY_USERNAME="dbuser"
                        withCredentials([string(credentialsId: 'DATABASE_IDENTITY_PASSWORD_CICD_TEST', variable: 'DATABASE_IDENTITY_PASSWORD')]) {
                            env.DATABASE_IDENTITY_PASSWORD=DATABASE_IDENTITY_PASSWORD
                        }
                        env.CALLCENTRE_SERVER_IP="IP"
                        withCredentials([string(credentialsId: 'SWYMED_APIKEY_CICD_TEST', variable: 'SWYMED_APIKEY')]) {
                            env.SWYMED_APIKEY=SWYMED_APIKEY
                        }
                        env.SWYMED_BASE_URL="https://psmri.swymed.com:9274"
                        env.REPORTING_DATABASE_USERNAME="dbuser"
                        withCredentials([string(credentialsId: 'REPORTING_DATABASE_PASSWORD_CICD_TEST', variable: 'REPORTING_DATABASE_PASSWORD')]) {
                            env.REPORTING_DATABASE_PASSWORD=REPORTING_DATABASE_PASSWORD
                        }
                        env.REPORTING_DATABASE_URL="jdbc:mysql://localhost:3306/db_reporting?autoReconnect=true&useSSL=false"
                        env.KM_API_BASE_URL="http://localhost:8084/OpenKM"
                        env.KM_API_BASE_PATH="localhost:8084/OpenKM"
                        env.CTI_SERVER_IP="IP"
                        env.CTI_SERVER_LOGGER_BASE="http://IP/logger"
                        env.IDENTITY_API_URL="http://localhost:8080/identity-v3.0.0"
                        env.IDENTITY_1097_API_URL="http://localhost:8080/1097identityapi-v3.0.0"
                        env.BEN_GEN_API_URL="http://localhost:8080/bengenapi-v3.0.0"
                        env.MMU_API="http://localhost:8080/mmuapi-v3.0.0"
                        
                        env.MMU_CENTRAL_SERVER="http://localhost:8080/mmuapi-v3.0.0"
                        env.TM_CENTRAL_SERVER="http://localhost:8080/tmapi-v3.0.0"
                        env.SCHEDULER_API="http://localhost:8080/schedulerapi-v3.0.0"
                        withCredentials([string(credentialsId: 'FETOSENSE_API_KEY_CICD_TEST', variable: 'FETOSENSE_API_KEY')]) {
                            env.FETOSENSE_API_KEY=FETOSENSE_API_KEY
                        }
                        
                        env.TM_API="http://localhost:8080/telemedicineapi-v1.0"
                        env.SERVICE_POINT_ID= 235
                        env.PARKING_PLACE_ID= 233
                        env.PROVIDER_SERVICE_MAP_ID= 1261
                        env.VAN_ID= 220
                        env.SERVICE_ID= 4
                        env.PROVIDER_ID= 500
                        env.APP_ID= 85696
                        env.AUTH_KEY= ""
                        env.AUTH_SECRET= ""
                        env.MMU_FILE_BASE_PATH="C:/apps/Neeraj/mmuDoc"
                        env.HWC_IDENTITY_API=""
                        env.FILE_SYNC_SERVER_IP=""
                        env.FILE_SYNC_SERVER_DOMAIN=""
                        env.FILE_SYNC_SERVER_USERNAME=""
                        env.FILE_SYNC_SERVER_PASSWORD=""
                        env.LOCAL_FOLDER_TO_SYNC=""
                        env.SEND_SMS="TRUE"
                        env.CARESTREAM_SOCKET_IP="IP"
                        env.CARESTREAM_SOCKET_PORT="1235"
                        env.SEND_SMS_URL="http://localhost:8080/commonapi-v3.0.0/sms/sendSMS"
                        env.SMS_USERNAME=""
                        withCredentials([string(credentialsId: 'SMS_PASSWORD_CICD_TEST', variable: 'SMS_PASSWORD')]) {
                            env.SMS_PASSWORD=SMS_PASSWORD
                        }
                        env.SMS_SOURCE_ADDRESS=""
                        env.SMS_MESSAGE_URL="https://openapi.airtel.in/gateway/airtel-iq-sms-utility/sendSingleSms"
                        env.SEND_EMAIL=""
                        env.MAIL_HOST="" 
                        env.MAIL_PORT="" 
                        env.MAIL_USERNAME="" 
                        env.MAIL_PASSWORD="" 
                        env.EVERWELL_USERNAME=""  
                        env.EVERWELL_PASSWORD=""  
                        env.EVERWELL_AMRIT_USERNAME=""  
                        env.EVERWELL_AMRIT_PASSWORD=""  
                        env.EVERWELL_BASE_URL=""  
                        env.SWAASA_EMAIL=""  
                        env.SWAASA_PASSWORD=""  
                        env.ESANJEEVANI_URL=""  
                        env.ESANJEEVANI_USERNAME=""  
                        env.ESANJEEVANI_PASSWORD=""  
                        env.ESANJEEVANI_SALT=""  
                        env.ESANJEEVANI_SOURCE=""  
                        env.ESANJEEVANI_REGISTER_PATIENT_URL=""  
                        env.ESANJEEVANI_ROUTE_URL=""  
                        env.BIOMETRIC_URL=""  
                        env.EAUSHADHI_URL=""  
                        env.FHIR_USER_NAME=""  
                        env.FHIR_PASSWORD=""  
                        env.MONGO_HOST="IP"  
                        env.MONGO_AUTH_DBNAME=""  
                        env.MONGO_DBNAME=""  
                        env.MONGO_USERNAME="" 
                        withCredentials([string(credentialsId: 'MONGO_PASSWORD_CICD_TEST', variable: 'MONGO_PASSWORD')]) {
                            env.MONGO_PASSWORD=MONGO_PASSWORD
                        }
                        env.BAHMINI_URL="" 
                        env.FEED_AUTH_URL=""  
                        env.FEED_AUTH_PASSWORD=""  
                        env.NDHM_ABHA_CLIENT_ID=""  
                        env.NDHM_ABHA_CLIENT_SECRET_KEY=""  
                        env.ABDM_BASE_URL="https://abhasbx.abdm.gov.in"  
                        env.ABDM_HEALTH_ID_BASE_URL="https://healthidsbx.abdm.gov.in"  
                        
                        env.NHM_AGENT_REAL_TIME_DATA_URL="http://IP/apps/utility/alive_api.php"
                        
                        env.BASE_URL = 'AnotherValueForType1'
                        env.TERM='xterm'
                        env.COMMON_API_LOGGING_FILE_NAME='E:/AppServer/wildfly-30.0.0.Final/wildfly-30.0.0.Final/Logs/common-api.log'
                        env.ADMIN_UI_LOGGING_FILE_NAME='E:/AppServer/wildfly-30.0.0.Final/wildfly-30.0.0.Final/Logs/admin-ui.log'
                        env.ADMIN_API_LOGGING_FILE_NAME='E:/AppServer/wildfly-30.0.0.Final/wildfly-30.0.0.Final/Logs/admin-api.log'
                        env.HELPLINEMCTS_API_LOGGING_FILE_NAME='E:/AppServer/wildfly-30.0.0.Final/wildfly-30.0.0.Final/Logs/helplinemcts-api.log'
                        env.TM_API_LOGGING_FILE_NAME='E:/AppServer/wildfly-30.0.0.Final/wildfly-30.0.0.Final/Logs/tm-api.log'
                        env.FHIR_API_LOGGING_FILE_NAME='E:/AppServer/wildfly-30.0.0.Final/wildfly-30.0.0.Final/Logs/fhir-api.log'
                        env.IDENTITY_API_LOGGING_FILE_NAME='E:/AppServer/wildfly-30.0.0.Final/wildfly-30.0.0.Final/Logs/identity-api.log'
                        env.HWC_API_LOGGING_FILE_NAME='E:/AppServer/wildfly-30.0.0.Final/wildfly-30.0.0.Final/Logs/hwc-api.log'
                        env.INVENTORY_API_LOGGING_FILE_NAME='E:/AppServer/wildfly-30.0.0.Final/wildfly-30.0.0.Final/Logs/inventory-api.log'
                        env.BENEFICIARYID_GENERATION_API_LOGGING_FILE_NAME='E:/AppServer/wildfly-30.0.0.Final/wildfly-30.0.0.Final/Logs/beneficiaryid-generation-api.log'
                        env.HELPLINE104_API_LOGGING_FILE_NAME='E:/AppServer/wildfly-30.0.0.Final/wildfly-30.0.0.Final/Logs/helpline104-api.log'
                        env.MMU_API_LOGGING_FILE_NAME='E:/AppServer/wildfly-30.0.0.Final/wildfly-30.0.0.Final/Logs/mmu-api.log'
                        env.HELPLINE1097_API_LOGGING_FILE_NAME='E:/AppServer/wildfly-30.0.0.Final/wildfly-30.0.0.Final/Logs/helpline1097-api.log'
                        env.SCHEDULER_UI_LOGGING_FILE_NAME='E:/AppServer/wildfly-30.0.0.Final/wildfly-30.0.0.Final/Logs/scheduler-ui.log'
                        env.SCHEDULER_API_LOGGING_FILE_NAME='E:/AppServer/wildfly-30.0.0.Final/wildfly-30.0.0.Final/Logs/scheduler-api.log'
                        env.ECD_API_LOGGING_FILE_NAME='E:/AppServer/wildfly-30.0.0.Final/wildfly-30.0.0.Final/Logs/ecd-api.log'
                        env.ECD_UI_LOGGING_FILE_NAME='E:/AppServer/wildfly-30.0.0.Final/wildfly-30.0.0.Final/Logs/ecd-ui.log'
                        
                        env.SWAGGER_DOC_ENABLED='true'
 
                        
                        
                        
                    } else if (params.project == 'Dev') {
                    } else if (params.project == 'UAT') {
                        
                    }
                }
            }
            
            
            
        }
       
        stage('Admin-UI') {
            
            steps {
                dir('repos'){
                
                        
                        cleanWs()
                        checkout([$class: 'GitSCM', 
                          branches: [[name: 'develop']],
                          userRemoteConfigs: [[
                            url: 'git@github.com:PSMRI/ADMIN-UI.git',
                            credentialsId: '' // Specify your SSH credentials ID
                          ]]
                        ])
                        
                        sh 'git submodule init'
                        sh 'git submodule update --recursive'
                        sh 'npm install --force'
                        sh 'npm run build-ci'
                        sh 'mvn -B package --file pom.xml -P ci'
                        archiveArtifacts 'target/*.war'
                        sh "cp target/*.war ${env.WORKSPACE}/target/" 
                    
                }
            }
        }

        
        
        
        
        stage('ECD-UI') {
            
            steps {
                dir('repos'){
                
                        
                        cleanWs()
                        checkout([$class: 'GitSCM', 
                          branches: [[name: 'develop']],
                          userRemoteConfigs: [[
                            url: 'git@github.com:PSMRI/ECD-UI.git',
                            credentialsId: '' // Specify your SSH credentials ID
                          ]]
                        ])
                        sh 'git submodule init'
                        sh 'git submodule update --recursive'
                        sh 'npm install --force'
                        sh 'npm run build-ci'
                        sh 'mvn -B package --file pom.xml -P ci'
                        archiveArtifacts 'target/*.war'
                            sh "cp target/*.war ${env.WORKSPACE}/target/" 
                    
                }
            }
        }
        
        
        stage('HWC-Inventory-UI') {
            
            steps {
                dir("${env.WORKSPACE}/repos") {
                    
                    cleanWs()
                    checkout([$class: 'GitSCM', 
                    branches: [[name: 'develop']],
                    userRemoteConfigs: [[
                    url: 'git@github.com:PSMRI/HWC-Inventory-UI.git',
                    credentialsId: '' // Specify your SSH credentials ID
                     ]]
                    ])
                    sh 'npm config set legacy-peer-deps true'
                    sh 'git submodule init'
                    sh 'git submodule update --recursive'
                    sh 'npm install --force'
                    sh 'npm run build-ci'
                    sh 'mvn -B package --file pom.xml -P ci'
                    archiveArtifacts 'target/*.war'
                    sh "echo ${env.WORKSPACE}" 
                    
                    sh " cp target/*.war ${env.WORKSPACE}/target/ " 
                     
                }
            }
        }
        
        stage('HWC-Scheduler-UI') {
            
            steps {
                dir('repos') {
                     
                cleanWs()
                checkout([$class: 'GitSCM', 
                  branches: [[name: 'develop']],
                  userRemoteConfigs: [[
                    url: 'git@github.com:PSMRI/HWC-Scheduler-UI.git',
                    credentialsId: '' // Specify your SSH credentials ID
                  ]]
                ])
                sh 'git submodule init'
                sh 'git submodule update --recursive'
                sh 'npm install --force'
                sh 'npm run build-ci'
                sh 'mvn -B package --file pom.xml -P ci'
                archiveArtifacts 'target/*.war'
                sh "cp target/*.war ${env.WORKSPACE}/target/" 
                }
                
            }
        }
        
        stage('HWC-UI') {
            
            steps {
                script {
                    
                    dir('repos/') {
                            cleanWs()
                        
                            
                            checkout([$class: 'GitSCM', 
                                branches: [[name: 'develop']],
                                userRemoteConfigs: [[
                                url: 'git@github.com:PSMRI/HWC-UI.git',
                                credentialsId: '' // Specify your SSH credentials ID
                              ]]
                            ])
                        
                    }
                    dir('repos/Common-UI') {
                    
                            checkout([$class: 'GitSCM', 
                                branches: [[name: 'develop']],
                                userRemoteConfigs: [[
                                url: 'git@github.com:PSMRI/Common-UI.git',
                                credentialsId: '' // Specify your SSH credentials ID
                              ]]
                            ])
                        
                    }
                    dir('repos/') {
                    
                            sh 'git submodule init'
                            sh 'git submodule update --recursive'
                            sh 'npm install --force'
                            sh 'npm run build-ci'
                            sh 'mvn -B package --file pom.xml -P ci'
                            archiveArtifacts 'target/*.war'
                            sh "cp target/*.war ${env.WORKSPACE}/target/" 
                        
                    }
                }
            }
        }
        
        stage('Inventory-UI') {
            
            steps {
                dir('repos'){
                
                        
                        cleanWs()
                        checkout([$class: 'GitSCM', 
                          branches: [[name: 'develop']],
                          userRemoteConfigs: [[
                            url: 'git@github.com:PSMRI/Inventory-UI.git',
                            credentialsId: '' // Specify your SSH credentials ID
                          ]]
                        ])
                       sh 'git submodule init'
                        sh 'git submodule update --recursive'
                        sh 'npm install --force'
                        sh 'npm run build-ci'
                        sh 'mvn -B package --file pom.xml -P ci'
                        archiveArtifacts 'target/*.war'
                            sh "cp target/*.war ${env.WORKSPACE}/target/" 
                    
                }
            }
        }
        
        stage('MMU-UI') {
            
          steps {
                script {
                    
                    dir('repos/') {
                            cleanWs()
                        
                            
                            checkout([$class: 'GitSCM', 
                                branches: [[name: 'feature/test']],
                                userRemoteConfigs: [[
                                url: 'git@github.com:psmri/MMU-UI.git',
                                credentialsId: '' // Specify your SSH credentials ID
                              ]]
                            ])
                        
                    }
                    dir('repos/Common-UI') {
                    
                            checkout([$class: 'GitSCM', 
                                branches: [[name: 'develop']],
                                userRemoteConfigs: [[
                                url: 'git@github.com:psmri/Common-UI.git',
                                credentialsId: '' // Specify your SSH credentials ID
                              ]]
                            ])
                        
                    }
                    dir('repos/') {
                    
                            sh 'git submodule init'
                            sh 'git submodule update --recursive'
                            sh 'npm install --force'
                            sh 'npm run build-ci'
                            sh 'mvn -B package --file pom.xml -P ci'
                            archiveArtifacts 'target/*.war'
                            sh "cp target/*.war ${env.WORKSPACE}/target/" 
                        
                    }
                }
            }
        }
        
        stage('Scheduler-UI') {
            
            steps {
                dir('repos'){
                
                        
                        cleanWs()
                        checkout([$class: 'GitSCM', 
                          branches: [[name: 'develop']],
                          userRemoteConfigs: [[
                            url: 'git@github.com:PSMRI/Scheduler-UI.git',
                            credentialsId: '' // Specify your SSH credentials ID
                          ]]
                        ])
                       sh 'git submodule init'
                        sh 'git submodule update --recursive'
                        sh 'npm install --force'
                        sh 'npm run build-ci'
                        sh 'mvn -B package --file pom.xml -P ci'
                        archiveArtifacts 'target/*.war'
                            sh "cp target/*.war ${env.WORKSPACE}/target/" 
                    
                }
            }
        }
        
          stage('TM-UI') {
            
            steps {
                script {
                    
                    dir('repos/') {
                            cleanWs()
                        
                            
                            checkout([$class: 'GitSCM', 
                                branches: [[name: 'develop']],
                                userRemoteConfigs: [[
                                url: 'git@github.com:PSMRI/TM-UI.git',
                                credentialsId: '' // Specify your SSH credentials ID
                              ]]
                            ])
                        
                    }
                    dir('repos/Common-UI') {
                    
                            checkout([$class: 'GitSCM', 
                                branches: [[name: 'develop']],
                                userRemoteConfigs: [[
                                url: 'git@github.com:PSMRI/Common-UI.git',
                                credentialsId: '' // Specify your SSH credentials ID
                              ]]
                            ])
                        
                    }
                    dir('repos/') {
                            sh 'git submodule init'
                            sh 'git submodule update --recursive'
                            sh 'npm install --force'
                            sh 'npm run build-ci'
                            sh 'mvn -B package --file pom.xml -P ci'
                            archiveArtifacts 'target/*.war'
                            sh "cp target/*.war ${env.WORKSPACE}/target/" 
                        
                    }
                }
            }
        }
        
        stage('Helpline104-UI') {
            
            steps {
                dir('repos'){
                
                        
                        cleanWs()
                        checkout([$class: 'GitSCM', 
                          branches: [[name: 'develop']],
                          userRemoteConfigs: [[
                            url: 'git@github.com:PSMRI/Helpline104-UI.git',
                            credentialsId: '' // Specify your SSH credentials ID
                          ]]
                        ])
                        script {
                        // sh 'curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash'
                        sh '''
                        export NVM_DIR="/var/lib/jenkins/.nvm"
                        [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" 
                        git submodule init
                        git submodule update --recursive
                        nvm install 14
                        nvm use 14
                        npm i
                        npm run build
                        '''
                        sh '''
                        cd dist/
                        mkdir WEB_INF/
                        touch WEB_INF/web.xml
                        jar -cvf Helpline104.war *
                        
                        '''
                        archiveArtifacts 'dist/*.war'
                            sh "cp dist/*.war ${env.WORKSPACE}/target/" 
                        }
                    
                }
            }
        }
        
        // stage('Helpline1097-UI') {
            
        //     steps {
        //         dir('repos'){
                
                        
        //                 cleanWs()
        //                 checkout([$class: 'GitSCM', 
        //                   branches: [[name: 'develop']],
        //                   userRemoteConfigs: [[
        //                     url: 'git@github.com:PSMRI/Helpline1097-UI.git',
        //                     credentialsId: '' // Specify your SSH credentials ID
        //                   ]]
        //                  ])
                       
        //                 script {
        //                 // sh 'curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash'
        //                 // sh '''
        //                 //      apt install python2
        //                 //      update-alternatives --install /usr/bin/python python /usr/bin/python2 1
        //                 //      update-alternatives --config python

        //                 // '''
        //                 sh 'python --version'
        //                 sh '''
        //                 export NVM_DIR="/var/lib/jenkins/.nvm"
        //                 [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" 
        //                 nvm install 14
        //                 nvm use 14
        //                 npm i
        //                 npm run build
        //                 '''
        //                 // archiveArtifacts 'target/*.war'
        //                 //     sh "cp target/*.war ${env.WORKSPACE}/target/" 
        //                 }
        //         }
        //     }
        // }
        
        stage('Admin-API') {
            
            steps {
                dir('repos') {
                    
                checkout([$class: 'GitSCM', 
                  branches: [[name: 'develop']],
                  userRemoteConfigs: [[
                    url: 'git@github.com:PSMRI/Admin-API.git',
                    credentialsId: ''
                  ]]
                ])
                sh 'mvn clean package -DENV_VAR=ci -Dmaven.test.skip -e'
                archiveArtifacts 'target/*.war'
                sh "cp target/*.war ${env.WORKSPACE}/target/" 
                
                }
            }
        }
        
        stage('BeneficiaryID-Generation-API') {
            
            steps {
                dir('repos') {
                     
                checkout([$class: 'GitSCM', 
                  branches: [[name: 'develop']],
                  userRemoteConfigs: [[
                    url: 'git@github.com:PSMRI/BeneficiaryID-Generation-API.git',
                    credentialsId: ''
                  ]]
                ])
                sh 'mvn clean package -DENV_VAR=ci -Pbengenapi -Dmaven.test.skip -e'
                archiveArtifacts 'target/*.war'
                sh "cp target/*.war ${env.WORKSPACE}/target/" 
                
                }
            }
        }
       
        stage('Common-API') {
            
            steps {
                dir('repos') {
                     
                checkout([$class: 'GitSCM', 
                  branches: [[name: 'develop']],
                  userRemoteConfigs: [[
                    url: 'git@github.com:PSMRI/Common-API.git',
                    credentialsId: ''
                  ]]
                ])
                sh 'mvn clean package -DENV_VAR=ci -Dmaven.test.skip -e'
                archiveArtifacts 'target/*.war'
                sh "cp target/*.war ${env.WORKSPACE}/target/" 
                
                }
            }
        }
       
        stage('ECD-API') {
            
            steps {
                 dir('repos') {
         
                checkout([$class: 'GitSCM', 
                  branches: [[name: 'develop']],
                  userRemoteConfigs: [[
                    url: 'git@github.com:PSMRI/ECD-API.git',
                    credentialsId: ''
                  ]]
                ])
                sh 'mvn clean package -DENV_VAR=ci -Dmaven.test.skip -e'
                archiveArtifacts 'target/*.war'
                  sh "cp target/*.war ${env.WORKSPACE}/target/"
                
        }
            }
        }
        
        stage('FHIR-API') {
            
            steps {
                 dir('repos') {
         
                checkout([$class: 'GitSCM', 
                  branches: [[name: 'develop']],
                  userRemoteConfigs: [[
                    url: 'git@github.com:PSMRI/FHIR-API.git',
                    credentialsId: ''
                  ]]
                ])
                sh 'mvn clean package -DENV_VAR=ci -Dmaven.test.skip -e'
                archiveArtifacts 'target/*.war'
                  sh "cp target/*.war ${env.WORKSPACE}/target/"
                
        }
            }
        }
        
        stage('Helpline104-API') {
            
            steps {
                 dir('repos') {
         
                checkout([$class: 'GitSCM', 
                  branches: [[name: 'develop']],
                  userRemoteConfigs: [[
                    url: 'git@github.com:PSMRI/Helpline104-API.git',
                    credentialsId: ''
                  ]]
                ])
                sh 'mvn clean package -DENV_VAR=ci -Dmaven.test.skip -e'
                archiveArtifacts 'target/*.war'
                  sh "cp target/*.war ${env.WORKSPACE}/target/"
                
        }
            }
        }
        
        stage('Helpline1097-API') {
            
            steps {
                 dir('repos') {
         
                checkout([$class: 'GitSCM', 
                  branches: [[name: 'develop']],
                  userRemoteConfigs: [[
                    url: 'git@github.com:PSMRI/Helpline1097-API.git',
                    credentialsId: ''
                  ]]
                ])
                sh 'mvn clean package -DENV_VAR=ci -Dmaven.test.skip -e'
                archiveArtifacts 'target/*.war'
                  sh "cp target/*.war ${env.WORKSPACE}/target/"
                
        }
            }
        }
        
        stage('Identity-API') {
            
            steps {
                dir('repos') {
                    
                        checkout([$class: 'GitSCM', 
                          branches: [[name: 'develop']],
                          userRemoteConfigs: [[ 
                            url: 'git@github.com:PSMRI/Identity-API.git',
                            credentialsId: ''
                          ]]
                        ])
                        sh 'mvn clean package -DENV_VAR=ci -Dmaven.test.skip -e'
                        archiveArtifacts 'target/*.war'
                        sh "cp target/*.war ${env.WORKSPACE}/target/" 
                    
                    
                }
            }
        }
        
        stage('HWC-API') {
            
            steps {
                dir('repos') {
                     
                checkout([$class: 'GitSCM', 
                  branches: [[name: 'develop']],
                  userRemoteConfigs: [[
                    url: 'git@github.com:PSMRI/HWC-API.git',
                    credentialsId: '' // Specify your SSH credentials ID
                  ]]
                ])
                sh 'mvn clean package -DENV_VAR=ci -Dmaven.test.skip -e'
                archiveArtifacts 'target/*.war'
                sh "cp target/*.war ${env.WORKSPACE}/target/"
                }
                
            }
        }
        
        stage('Scheduler-API') {
            
            steps {
                dir('repos') {
                    
                checkout([$class: 'GitSCM', 
                  branches: [[name: 'develop']],
                  userRemoteConfigs: [[
                    url: 'git@github.com:PSMRI/Scheduler-API.git',
                    credentialsId: ''
                  ]]
                ])
                sh 'mvn clean package -DENV_VAR=ci -Dmaven.test.skip -e'
                archiveArtifacts 'target/*.war'
                sh "cp target/*.war ${env.WORKSPACE}/target/"
                
                }
            }
        }

        stage('Inventory-API') {
            
            steps {
                dir('repos') {
                     
                checkout([$class: 'GitSCM', 
                  branches: [[name: 'develop']],
                  userRemoteConfigs: [[
                    url: 'git@github.com:PSMRI/Inventory-API.git',
                    credentialsId: ''
                  ]]
                ])
                sh 'mvn clean package -DENV_VAR=ci -Dmaven.test.skip -e'
                archiveArtifacts 'target/*.war'
                sh "cp target/*.war ${env.WORKSPACE}/target/"
                
                }
            }
        }
        
        stage('MMU-API') {
            
            steps {
                 dir('repos') {
         
                checkout([$class: 'GitSCM', 
                  branches: [[name: 'develop']],
                  userRemoteConfigs: [[
                    url: 'git@github.com:PSMRI/MMU-API.git',
                    credentialsId: ''
                  ]]
                ])
                sh 'mvn clean package -DENV_VAR=ci -Dmaven.test.skip -e'
                archiveArtifacts 'target/*.war'
                  sh "cp target/*.war ${env.WORKSPACE}/target/"
                
        }
            }
        }
        
        stage('TM-API') {
            
            steps {
                 dir('repos') {
         
                checkout([$class: 'GitSCM', 
                  branches: [[name: 'develop']],
                  userRemoteConfigs: [[
                    url: 'git@github.com:PSMRI/TM-API.git',
                    credentialsId: ''
                  ]]
                ])
                sh 'mvn clean package -DENV_VAR=ci -Dmaven.test.skip -e'
                archiveArtifacts 'target/*.war'
                  sh "cp target/*.war ${env.WORKSPACE}/target/"
                
        }
            }
        }
     
     stage('Undeploy All') {
            steps {
                script {
                    

                        // Delete all files in the remote folder
                        sh '''
                        sshpass -p "${WILDFLY_PASSWORD}" ssh -o StrictHostKeyChecking=no ${WILDFLY_USER}@${WILDFLY_HOST} "del /q ${REMOTE_DEPLOY_DIR}\\*"
                        '''
                }
            }
    }
     
    
      stage('Deploy WARs') {
            steps {
                script {
                
                    sh "sshpass -p ${WILDFLY_PASSWORD} scp -o StrictHostKeyChecking=no -r ${TARGET_DIR}/* ${WILDFLY_USER}@${WILDFLY_HOST}:${REMOTE_DEPLOY_DIR2}"

                
                }
            }
        }
        
    }
}
