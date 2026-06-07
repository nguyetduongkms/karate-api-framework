# Karate API Test Framework — Anh Tester

Automated API testing framework using **Karate + JUnit5 + Masterthought Cucumber Reports**.

## Tech Stack

| Library | Version | Purpose |
|---------|---------|---------|
| karate-junit5 | 1.5.1 | BDD API Testing Engine |
| junit-jupiter | 5.10.2 | Test Runner |
| cucumber-reporting | 5.11.0 | HTML Report with Pie Chart |
| logback-classic | 1.4.14 | Logging |
| dotenv-java | 3.0.0 | Load `.env` secrets for local dev |
| commons-io | 2.15.1 | File utilities (report generation) |

## Project Structure

```
karate-api-framework/
├── .env.example                                     # Template — copy to .env and fill in values
├── .gitignore                                       # Excludes .env and sensitive testdata
├── pom.xml                                          # Maven config & dependencies
└── src/
    └── test/
        ├── java/
        │   └── com/anhtester/
        │       └── runner/
        │           └── TestRunner.java              # JUnit5 Parallel Runner (loads .env)
        └── resources/
            ├── karate-config.js                     # Reads YAML config + env var secrets
            ├── logback-test.xml                     # Logging configuration
            ├── config/
            │   ├── dev.yaml                         # Dev environment config
            │   ├── qa.yaml                          # QA environment config
            │   ├── staging.yaml                     # Staging environment config
            │   └── production.yaml                  # Production environment config
            ├── templates/
            │   └── auth/
            │       └── register-request.json        # Register request payload (uses #(username), #(email))
            ├── testdata/
            │   ├── accounts.csv.example             # Template for data-driven login accounts
            │   └── register-accounts.csv.example    # Template for data-driven register accounts
            └── features/
                └── auth/
                    ├── helpers/
                    │   └── create-user.feature      # @ignore reusable helper — registers a user and exposes credentials
                    └── login.feature                # Login tests (uses create-user as pre-condition)
```

## First-Time Setup (Credentials)

Credentials are **never hardcoded** — they live in environment variables.

### 1. Copy the template file
```bash
cp .env.example .env
```

### 2. Fill in real values
**.env** — sensitive credentials loaded by dotenv-java at test startup:
```env
DEMO_USERNAME=
DEMO_PASSWORD=
DEMO_EMAIL=
NEW_USER_PASSWORD=Demo@1234
EXISTING_USERNAME=
EXISTING_PASSWORD=
EXISTING_EMAIL=
```

> **In CI/CD**: skip `.env` entirely — set the variables as native environment variables in your pipeline. dotenv-java calls `ignoreIfMissing()` so it silently skips the file when absent.

## How Tests Are Structured

### Pre-condition pattern: create-user → login

`login.feature` uses `create-user.feature` as a **pre-condition** in its `Background`. Before each scenario, a unique user is registered via the API, and the returned credentials are used to log in:

```gherkin
Background:
  * def user = call read('classpath:features/auth/helpers/create-user.feature')
  * url baseUrl
```

`create-user.feature` is tagged `@ignore` so it never runs standalone — it is only invoked via `call read(...)` from other features. It exposes variables to the caller:

| Variable | Value |
|----------|-------|
| `user.payload.username` | Generated username (`user_<timestamp>`) |
| `user.payload.password` | Password from `NEW_USER_PASSWORD` env var |
| `user.payload.email` | Generated email (`user_<timestamp>@anhtester.com`) |
| `user.response` | Full HTTP response body from the register API |

### Unique data generation

`create-user.feature` uses `Java.type('java.lang.System').currentTimeMillis()` to guarantee unique usernames and emails on every run, avoiding 422 conflicts from repeated execution.

## How to Run Tests

### 1. Clean compile without running tests
```bash
mvn clean install -DskipTests
```

### 2. Run the full test suite
```bash
mvn clean test
```

### 3. Run on a specific environment
```bash
# Dev (default)
mvn clean test

# QA
mvn clean test -Dkarate.env=qa

# Staging
mvn clean test -Dkarate.env=staging

# Production
mvn clean test -Dkarate.env=production
```

### 4. Run by tag
```bash
# Smoke tests only
mvn clean test -Dkarate.options="--tags @smoke"

# Login tests only
mvn clean test -Dkarate.options="--tags @login"

# Exclude a tag
mvn clean test -Dkarate.options="--tags ~@ignore"
```

### 5. Run a specific feature file
```bash
mvn clean test -Dkarate.options="classpath:features/auth/login.feature"
```

## View Reports

After the run completes, open:
```
target/cucumber-html-reports/overview-features.html
```

> Open in Chrome or Firefox. The report includes a pie chart, tag breakdown, timeline, and step-level details.

### Output folder structure
```
target/
├── surefire-reports/          # JSON files (input for Masterthought)
├── karate-reports/            # Karate HTML reports (basic)
└── cucumber-html-reports/
    ├── overview-features.html  ← OPEN THIS FILE
    ├── overview-tags.html
    ├── overview-failures.html
    └── ...
```

## Tag Reference

| Tag | Description |
|-----|-------------|
| `@smoke` | Most critical tests, run before deploy |
| `@login` | All tests related to Login API |
| `@happy-path` | Success scenarios |
| `@negative` | Error/failure scenarios |
| `@ignore` | Helper features — not run standalone |

## Environment Configuration

Each environment has its own YAML file under `src/test/resources/config/`. To add a new environment (e.g. `uat`):

1. Create `src/test/resources/config/uat.yaml` with the appropriate values:
```yaml
baseUrl: https://uat-api.anhtester.com
connectTimeout: 15000
readTimeout: 45000
logLevel: info
ssl: true
```

2. Run with:
```bash
mvn clean test -Dkarate.env=uat
```

## Important Notes

1. **Parallel Execution**: TestRunner runs 4 threads in parallel. Adjust in `TestRunner.java` → `.parallel(N)` to match your CI/CD server capacity.

2. **Unique Test Data**: `create-user.feature` generates a unique username and email on every run using `currentTimeMillis()`, preventing conflicts when tests are re-run.

3. **Pre-condition reuse**: Any feature that needs an authenticated user can call `create-user.feature` via `call read(...)`. Use `callonce` in `Background` to register once per feature, or `call` inside a `Scenario` to register per scenario.
