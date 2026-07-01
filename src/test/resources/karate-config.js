/**
 * ================================================================
 * KARATE CONFIGURATION FILE
 * ================================================================
 * This file is automatically loaded by Karate before each Scenario.
 * REQUIRED location: src/test/resources/karate-config.js
 *
 * How to specify the environment:
 *   - mvn test                       → uses 'dev' (default)
 *   - mvn test -Dkarate.env=staging  → uses 'staging'
 *
 * Secrets (credentials) are read from environment variables.
 * For local development, copy .env.example to .env and fill in values.
 * TestRunner.java loads .env into system properties before Karate starts.
 * ================================================================
 */
function fn() {

    var env = karate.env || 'dev';
    karate.log('>>> Karate is running on environment:', env);

    var supportedEnvironments = ['dev', 'staging'];
    if (supportedEnvironments.indexOf(env) === -1) {
        throw new Error('Unsupported karate.env: ' + env
            + '. Supported environments: ' + supportedEnvironments.join(', '));
    }

    // ----------------------------------------------------------------
    // [1] LOAD ENVIRONMENT-SPECIFIC YAML CONFIG
    // Contains non-sensitive infrastructure settings only:
    // baseUrl, timeouts, log level, ssl flag.
    // ----------------------------------------------------------------
    var envConfig = karate.read('classpath:config/' + env + '.yaml');

    // ----------------------------------------------------------------
    // [2] HELPER — read a secret from system properties (.env via dotenv-java)
    // Falls back to OS environment variables (for CI/CD pipelines).
    // ----------------------------------------------------------------
    var getSecret = function(key) {
        var val = java.lang.System.getProperty(key);
        if (!val) val = java.lang.System.getenv(key);
        return val;
    };

    // ----------------------------------------------------------------
    // [3] BUILD CONFIG OBJECT
    // Infrastructure values come from YAML; credentials from env vars.
    // ----------------------------------------------------------------
    var config = {
        baseUrl:            envConfig.baseUrl,
        connectTimeout:     envConfig.connectTimeout,
        readTimeout:        envConfig.readTimeout,
        logLevel:           envConfig.logLevel,
        defaultContentType: 'application/json',

        retryConfig: {
            count:    2,
            interval: 1000
        },

        // Demo account — sourced from .env / CI environment variables
        demoUser: {
            username: getSecret('DEMO_USERNAME'),
            password: getSecret('DEMO_PASSWORD'),
            email:    getSecret('DEMO_EMAIL')
        },

        // Password injected into register-request.json template at runtime
        newUserPassword: getSecret('NEW_USER_PASSWORD'),

        // Existing user — used in negative registration tests
        existingUser: {
            username: getSecret('EXISTING_USERNAME'),
            password: getSecret('EXISTING_PASSWORD'),
            email:    getSecret('EXISTING_EMAIL')
        }
    };

    // ----------------------------------------------------------------
    // [4] APPLY GLOBAL HTTP CONFIG
    // ----------------------------------------------------------------
    karate.configure('connectTimeout', config.connectTimeout);
    karate.configure('readTimeout',    config.readTimeout);

    // Disable strict SSL only on non-production environments
    if (!envConfig.ssl) {
        karate.configure('ssl', true);
    }

    // ----------------------------------------------------------------
    // [5] GLOBAL HEADERS — applied to ALL HTTP requests
    // Each feature can use "* configure headers = ..." to override.
    // ----------------------------------------------------------------
    karate.configure('headers', {
        'Content-Type':  config.defaultContentType,
        'Accept':        'application/json',
        'X-Client-Name': 'Karate-AutoTest-Framework',
        'X-Test-Env':    env
    });

    // ----------------------------------------------------------------
    // [6] GLOBAL AUTH TOKEN — available to all Features
    // ----------------------------------------------------------------
    var auth = karate.callSingle('classpath:features/auth/helpers/login-user.feature', {
        baseUrl: config.baseUrl,
        username: config.demoUser.username,
        password: config.demoUser.password
    });
    config.authToken = auth.token;

    // ----------------------------------------------------------------
    // [7] HELPER FUNCTIONS — available in all feature files
    // ----------------------------------------------------------------
    var utils = karate.read('classpath:utils/data-generators.js');
    Object.assign(config, utils);

    // ----------------------------------------------------------------
    // [8] RETURN CONFIG — Karate injects this into every Scenario context
    // ----------------------------------------------------------------
    return config;
}
