pipeline {
    agent any

    
    environment {
        // Configuración de Docker
        DOCKER_COMPOSE_FILE = 'docker/docker-compose.yml'
        DOCKER_IMAGE_TAG = "${env.BUILD_NUMBER}-${env.GIT_COMMIT.take(7)}"
        
        // Nombres de las imágenes
        BACKEND_IMAGE = 'tasku-backend'
        FRONTEND_IMAGE = 'tasku-frontend'
        
        // Rutas de los proyectos
        BACKEND_DIR = 'backend'
        FRONTEND_DIR = 'frontend'
        DOCKER_DIR = 'docker'
        
        // Docker Host para la conexión con Docker Desktop
        DOCKER_HOST = 'tcp://localhost:2375'
        
        // SonarQube - credenciales
        SONARQUBE_URL = 'http://localhost:9000'
        SONARQUBE_TOKEN = ''
    }
    
    options {
        // Mantener solo los últimos 5 builds
        buildDiscarder(logRotator(numToKeepStr: '5'))
        // Timeout de 30 minutos
        timeout(time: 30, unit: 'MINUTES')
        // Timestamps en los logs
        timestamps()
    }
    
    stages {
        stage('Verificar Docker') {
            steps {
                script {
                    echo "Verificando conexión con Docker Desktop..."
                    if (isUnix()) {
                        sh '''
                            if ! command -v docker &> /dev/null; then
                                echo "Error: No se puede conectar con Docker"
                                exit 1
                            fi
                            docker --version
                            docker ps
                            echo "Conexión con Docker verificada exitosamente"
                        '''
                    } else {
                        bat '''
                            docker --version
                            if errorlevel 1 (
                                echo Error: No se puede conectar con Docker
                                echo Asegúrate de que Docker Desktop esté corriendo
                                exit /b 1
                            )
                            docker ps
                            if errorlevel 1 (
                                echo Error: No se puede conectar con Docker Desktop
                                echo Verifica que Docker Desktop esté corriendo
                                exit /b 1
                            )
                            echo Conexión con Docker verificada exitosamente
                        '''
                    }
                }
            }
        }
        
        stage('Checkout') {
            steps {
                script {
                    echo "Obteniendo código del repositorio..."
                    checkout scm
                    echo "Código obtenido exitosamente"
                    if (isUnix()) {
                        sh 'git log -1 --pretty=format:"%h - %an, %ar : %s"'
                    } else {
                        bat 'git log -1 --pretty=format:"%h - %an, %ar : %s"'
                    }
                }
            }
        }
        
        stage('Validación') {
            steps {
                script {
                    echo "Validando estructura del proyecto..."
                    if (isUnix()) {
                            sh '''
                                if [ ! -d "${BACKEND_DIR}" ]; then
                                    echo "Error: Directorio backend no encontrado"
                                    exit 1
                                fi
                                if [ ! -d "${FRONTEND_DIR}" ]; then
                                    echo "Error: Directorio frontend no encontrado"
                                    exit 1
                                fi
                                if [ ! -f "${DOCKER_COMPOSE_FILE}" ]; then
                                    echo "Error: docker-compose.yml no encontrado"
                                    exit 1
                                fi
                                echo "Estructura del proyecto válida"
                            '''
                        } else {
                            bat '''
                                if not exist "%BACKEND_DIR%" (
                                    echo Error: Directorio backend no encontrado
                                    exit /b 1
                                )
                                if not exist "%FRONTEND_DIR%" (
                                    echo Error: Directorio frontend no encontrado
                                    exit /b 1
                                )
                                if not exist "%DOCKER_COMPOSE_FILE%" (
                                    echo Error: docker-compose.yml no encontrado
                                    exit /b 1
                                )
                                echo Estructura del proyecto válida
                            '''
                        }
                    }
            }
        }
        
        stage('Pruebas Unitarias') {
            steps {
                script {
                    echo "Ejecutando pruebas unitarias del backend..."
                    dir("${env.BACKEND_DIR}") {
                        if (isUnix()) {
                            sh 'mvn clean test'
                        } else {
                            bat 'mvn clean test'
                        }
                    }
                    echo "Pruebas unitarias completadas"
                }
            }
        }

        stage('SonarQube Analysis') {
            environment {
                SONAR_HOST_URL = 'http://localhost:9000'
                SONAR_AUTH_TOKEN = credentials('sonarqube-token')
            }
            steps {
                script {
                    if (!env.SONAR_AUTH_TOKEN?.trim()) {
                        echo "Token de SonarQube no configurado - se omite el análisis"
                        return
                    }
                    echo "Ejecutando análisis de SonarQube..."
                    dir("${env.BACKEND_DIR}") {
                        if (isUnix()) {
                            sh '''
                                mvn sonar:sonar \
                                    -Dsonar.projectKey=tasku-backend \
                                    -Dsonar.host.url=$SONAR_HOST_URL \
                                    -Dsonar.login=$SONAR_AUTH_TOKEN \
                                    -Dsonar.sources=src/main/java \
                                    -Dsonar.tests=src/test/java \
                                    -Dsonar.java.binaries=target/classes \
                                    -Dsonar.junit.reportPaths=target/surefire-reports
                            '''
                        } else {
                            bat '''
                                mvn sonar:sonar ^
                                    -Dsonar.projectKey=tasku-backend ^
                                    -Dsonar.host.url=%SONAR_HOST_URL% ^
                                    -Dsonar.login=%SONAR_AUTH_TOKEN% ^
                                    -Dsonar.sources=src/main/java ^
                                    -Dsonar.tests=src/test/java ^
                                    -Dsonar.java.binaries=target/classes ^
                                    -Dsonar.junit.reportPaths=target/surefire-reports
                            '''
                        }
                    }
                    echo "Análisis de SonarQube completado"
                }
            }
        }
        
        stage('Build Imágenes Docker') {
            parallel {
                stage('Build Backend') {
                    steps {
                        script {
                            echo "Construyendo imagen Docker del backend..."
                            dir("${env.BACKEND_DIR}") {
                                def backendImage = "${env.BACKEND_IMAGE}:${env.DOCKER_IMAGE_TAG}"
                                
                                if (isUnix()) {
                                    sh """
                                        docker build -t ${backendImage} .
                                        docker tag ${backendImage} ${env.BACKEND_IMAGE}:latest
                                    """
                                } else {
                                    bat """
                                        docker build -t ${backendImage} .
                                        docker tag ${backendImage} ${env.BACKEND_IMAGE}:latest
                                    """
                                }
                                
                                echo "Imagen del backend construida: ${backendImage}"
                            }
                        }
                    }
                }
                
                stage('Build Frontend') {
                    steps {
                        script {
                            echo "Construyendo imagen Docker del frontend..."
                            dir("${env.FRONTEND_DIR}") {
                                def frontendImage = "${env.FRONTEND_IMAGE}:${env.DOCKER_IMAGE_TAG}"
                                
                                if (isUnix()) {
                                    sh """
                                        docker build -t ${frontendImage} .
                                        docker tag ${frontendImage} ${env.FRONTEND_IMAGE}:latest
                                    """
                                } else {
                                    bat """
                                        docker build -t ${frontendImage} .
                                        docker tag ${frontendImage} ${env.FRONTEND_IMAGE}:latest
                                    """
                                }
                                
                                echo "Imagen del frontend construida: ${frontendImage}"
                            }
                        }
                    }
                }
            }
        }
        
        stage('Limpieza de Contenedores Anteriores') {
            steps {
                script {
                    echo "Deteniendo y eliminando contenedores anteriores..."
                    dir("${env.DOCKER_DIR}") {
                        if (isUnix()) {
                            sh '''
                                docker-compose -f docker-compose.yml down --remove-orphans || true
                                docker image prune -f || true
                            '''
                        } else {
                            bat '''
                                docker-compose -f docker-compose.yml down --remove-orphans
                                if errorlevel 1 (
                                    echo Advertencia: Error al detener contenedores, continuando...
                                )
                                docker image prune -f
                            '''
                        }
                    }
                    echo "Limpieza completada"
                }
            }
        }
        
        stage('Despliegue con Docker Compose') {
            steps {
                script {
                    echo "Desplegando servicios con Docker Compose..."
                    dir("${env.DOCKER_DIR}") {
                        // Verificar conexión con Docker antes de desplegar
                        if (isUnix()) {
                            sh 'docker ps > /dev/null 2>&1 || (echo "Error: No se puede conectar con Docker" && exit 1)'
                        } else {
                            bat 'docker ps >nul 2>&1 || (echo Error: No se puede conectar con Docker && exit /b 1)'
                        }
                        
                        // Desplegar con force-recreate para asegurar redespliegue
                        if (isUnix()) {
                            sh '''
                                docker-compose -f docker-compose.yml up -d --build --force-recreate --no-deps
                            '''
                        } else {
                            bat '''
                                docker-compose -f docker-compose.yml up -d --build --force-recreate --no-deps
                                if errorlevel 1 (
                                    echo Error durante el despliegue
                                    exit /b 1
                                )
                            '''
                        }
                    }
                    echo "Servicios desplegados exitosamente"
                }
            }
        }
    }
    
    post {
        success {
            script {
                echo "Pipeline completado exitosamente"
                echo """
                ============================================
                DESPLIEGUE EXITOSO
                ============================================
                Backend: http://localhost:8081
                Frontend: http://localhost:4200
                PostgreSQL: localhost:5432
                ============================================
                """
            }
        }
        
        failure {
            script {
                echo "Pipeline falló"
                echo "Revisando logs de los contenedores..."
                if (isUnix()) {
                    sh '''
                        echo "=== Logs Backend ==="
                        docker logs --tail 50 tasku-backend || true
                        echo "=== Logs Frontend ==="
                        docker logs --tail 50 tasku-frontend || true
                        echo "=== Logs PostgreSQL ==="
                        docker logs --tail 50 tasku-postgresql || true
                    '''
                } else {
                    bat '''
                        echo === Logs Backend ===
                        docker logs --tail 50 tasku-backend
                        echo === Logs Frontend ===
                        docker logs --tail 50 tasku-frontend
                        echo === Logs PostgreSQL ===
                        docker logs --tail 50 tasku-postgresql
                    '''
                }
            }
        }
        
        always {
            script {
                echo "Limpiando workspace..."
                if (isUnix()) {
                    sh 'docker image prune -f || true'
                } else {
                    bat 'docker image prune -f'
                }
            }
        }
    }
}

