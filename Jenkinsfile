pipeline {

    agent { label 'Tadrous' }

    environment {
        FLUTTER_HOME = "F:\\flutterSdk\\flutter"
        PATH = "${FLUTTER_HOME}\\bin;${env.PATH}"
    }

    parameters {

        string(
            name: 'BRANCH',
            defaultValue: 'feature/parent-app',
            description: 'Git branch to build'
        )

        booleanParam(
            name: 'CLEAN',
            defaultValue: true,
            description: 'Run flutter clean before pub get'
        )

        booleanParam(
            name: 'RUN_TESTS',
            defaultValue: true,
            description: 'Run Flutter tests'
        )

        choice(
            name: 'BUILD_MODE',
            choices: ['debug', 'release', 'profile'],
            description: 'Flutter build mode'
        )

        // lib/config/app_config.dart: the servers the app talks to.
        choice(
            name: 'ENV',
            choices: ['dev', 'staging', 'prod'],
            description: 'dev = office servers (192.168.0.219, office network only). staging = live servers, with logs. prod = live servers (almahabbahschools.com), no logs'
        )

        booleanParam(
            name: 'PARENT_ACCOUNT',
            defaultValue: true,
            description: 'Parent log in and screens. Off = visitor-only app'
        )

        booleanParam(
            name: 'STATIC_DATA',
            defaultValue: false,
            description: 'Built-in data instead of the APIs (for demos while the server is not public)'
        )
    }

    stages {

        stage('Checkout') {
            steps {
                git branch: "${params.BRANCH}",
                    url: 'http://petrasoftware:3000/Mobile_Projects/Elmahaba-APP.git'
            }
        }

        stage('Setup Flutter') {
            steps {

                bat """
                    %FLUTTER_HOME%\\bin\\flutter --version
                """

                script {
                    if (params.CLEAN) {
                        bat """
                            %FLUTTER_HOME%\\bin\\flutter clean
                        """
                    }
                }

                // Also generates the translations (flutter: generate: true).
                bat """
                    %FLUTTER_HOME%\\bin\\flutter pub get
                """
            }
        }

        stage('Analyze') {
            steps {
                bat """
                    %FLUTTER_HOME%\\bin\\flutter analyze --no-fatal-infos
                """
            }
        }

        stage('Test') {
            when {
                expression {
                    params.RUN_TESTS
                }
            }

            steps {
                catchError(
                    buildResult: 'UNSTABLE',
                    stageResult: 'FAILURE'
                ) {
                    bat """
                        %FLUTTER_HOME%\\bin\\flutter test --concurrency=1
                    """
                }
            }
        }

        stage('Build APK') {
            steps {
                // Release is signed with the debug key unless
                // android/key.properties is on the agent (it isn't in git).
                bat """
                    %FLUTTER_HOME%\\bin\\flutter build apk --${params.BUILD_MODE} --build-number=${env.BUILD_NUMBER} --dart-define=ENV=${params.ENV} --dart-define=PARENT_ACCOUNT=${params.PARENT_ACCOUNT} --dart-define=STATIC_DATA=${params.STATIC_DATA}
                """
            }
        }

        stage('Deploy') {
            steps {
                archiveArtifacts(
                    artifacts: "build/app/outputs/flutter-apk/app-${params.BUILD_MODE}.apk",
                    fingerprint: true
                )
            }
        }
    }

    post {

        success {
            echo "✅ Al Mahabbah ${params.BUILD_MODE} (${params.ENV}) build #${env.BUILD_NUMBER} successful!"
        }

        unstable {
            echo '⚠️ Built, but some tests failed.'
        }

        failure {
            echo '❌ Build failed!'
        }
    }
}
