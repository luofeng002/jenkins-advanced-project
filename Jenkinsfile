pipeline {
    agent any

    environment {
        // 应用配置
        APP_NAME = 'jenkins-advanced'
        IMAGE_NAME = 'my-hello-jenkins'
        CONTAINER_NAME = 'jenkins-advanced-app'
        VERSION = "${env.BUILD_NUMBER}"
        PORT = '8088'
        
        // 修复 Git TLS 问题
       // GIT_SSL_NO_VERIFY = 'true'
    }

    parameters {
        choice(
            name: 'DEPLOY_ENV',
            choices: ['dev', 'prod'],
            description: '选择部署环境'
        )
        booleanParam(
            name: 'RUN_TESTS',
            defaultValue: true,
            description: '是否运行测试'
        )
    }

    options {
        buildDiscarder(logRotator(numToKeepStr: '10'))
        timeout(time: 15, unit: 'MINUTES')
        disableConcurrentBuilds()
    }

    stages {
        // ============================================
        // 阶段 1: 准备环境
        // ============================================
        stage('🔧 准备环境') {
            steps {
                echo '''
                ════════════════════════════════════════
                🚀 开始构建: ${APP_NAME}
                📌 构建编号: ${BUILD_NUMBER}
                📌 部署环境: ${params.DEPLOY_ENV}
                ════════════════════════════════════════
                '''
                
                // // 修复 Git
                // sh '''
                //     git config --global http.sslVerify false
                //     echo "✅ Git 环境准备完成"
                // '''
            }
        }

        // ============================================
        // 阶段 2: 拉取代码
        // ============================================
        stage('📥 拉取代码') {
            steps {
                echo '从 GitHub 拉取代码...'
                git url: 'https://github.com/luofeng002/jenkins-advanced-project.git',
                    branch: 'main',
                    //credentialsId: 'github-token'
                echo '✅ 代码拉取完成'
                sh 'ls -la'
            }
        }

        // ============================================
        // 阶段 3: 构建 Docker 镜像
        // ============================================
        stage('🐳 构建镜像') {
            steps {
                echo '构建 Docker 镜像...'
                sh """
                    docker build -t ${IMAGE_NAME}:${VERSION} .
                    docker tag ${IMAGE_NAME}:${VERSION} ${IMAGE_NAME}:latest
                """
                echo '✅ 镜像构建完成'
            }
        }

        // ============================================
        // 阶段 4: 运行测试
        // ============================================
        stage('🧪 运行测试') {
            when {
                expression { params.RUN_TESTS == true }
            }
            steps {
                echo '启动测试容器...'
                sh """
                    # 启动测试容器
                    docker run -d --name ${CONTAINER_NAME}-test \
                        -p 8888:80 ${IMAGE_NAME}:${VERSION}
                    
                    # 等待服务启动
                    sleep 3
                    
                    # 运行测试脚本
                    chmod +x tests/test.sh
                    ./tests/test.sh
                    
                    # 清理测试容器
                    docker stop ${CONTAINER_NAME}-test || true
                    docker rm ${CONTAINER_NAME}-test || true
                """
                echo '✅ 所有测试通过'
            }
        }

        // ============================================
        // 阶段 5: 部署
        // ============================================
        stage('🚀 部署') {
            steps {
                echo "部署到 ${params.DEPLOY_ENV} 环境..."
                script {
                    def env = params.DEPLOY_ENV
                    def port = env == 'prod' ? '8089' : '8088'
                    def container = "jenkins-advanced-${env}"
                    
                    sh """
                        # 停止旧容器
                        docker stop ${container} 2>/dev/null || true
                        docker rm ${container} 2>/dev/null || true
                        
                        # 启动新容器
                        docker run -d \
                            --name ${container} \
                            -p ${port}:80 \
                            --restart unless-stopped \
                            -e ENV=${env} \
                            -e VERSION=${VERSION} \
                            ${IMAGE_NAME}:${VERSION}
                        
                        # 等待服务启动
                        sleep 3
                    """
                    
                    // 健康检查
                    sh """
                        if curl -s http://localhost:${port}/ | grep -q "Jenkins"; then
                            echo "✅ 部署成功！访问: http://localhost:${port}"
                        else
                            echo "❌ 部署失败"
                            exit 1
                        fi
                    """
                }
            }
        }

        // ============================================
        // 阶段 6: 保存构建信息
        // ============================================
        stage('📦 归档') {
            steps {
                sh '''
                    cat > build-info.txt << EOF
                    应用名称: ${APP_NAME}
                    构建编号: ${BUILD_NUMBER}
                    版本号: ${VERSION}
                    部署环境: ${params.DEPLOY_ENV}
                    构建时间: $(date)
                    Git提交: $(git rev-parse --short HEAD)
                    EOF
                '''
                archiveArtifacts artifacts: 'build-info.txt'
            }
        }
    }

    // ============================================
    // 构建后处理
    // ============================================
    post {
        success {
            echo '''
            🎉🎉🎉 构建成功！
            ════════════════════════════════════════
            应用: ${APP_NAME}
            版本: ${VERSION}
            环境: ${params.DEPLOY_ENV}
            访问: http://localhost:${PORT}
            ════════════════════════════════════════
            '''
        }
        failure {
            echo '''
            ❌ 构建失败！
            请查看控制台日志了解详情。
            '''
        }
        always {
            echo '📊 构建结束，清理工作...'
            // 清理旧镜像（保留最近3个）
            sh '''
                docker images ${IMAGE_NAME} --format "{{.Tag}}" | \
                sort -r | \
                tail -n +4 | \
                xargs -r docker rmi 2>/dev/null || true
            '''
        }
    }
}