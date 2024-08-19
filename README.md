# <img height="25" src="logos/test_visibility_logo.png" />  Datadog Test Visibility GitLab Script

Bash script that installs and configures [Datadog Test Visibility](https://docs.datadoghq.com/tests/) for GitLab.
Supported languages are .NET, Java, Javascript, and Python.

## About Datadog Test Visibility

[Test Visibility](https://docs.datadoghq.com/tests/) provides a test-first view into your CI health by displaying important metrics and results from your tests. 
It can help you investigate and mitigate performance problems and test failures that are most relevant to your work, focusing on the code you are responsible for, rather than the pipelines which run your tests.

## Usage

Execute this script in your GitLab CI's job YAML before running the tests. Set the language, service name, api key and [site](https://docs.datadoghq.com/getting_started/site/) parameters:

TODO: Change script url
 ```yaml
 test_node:
  image: node:latest
  script:
  - eval $(LANGUAGES="js" SITE="datadoghq.com" API_KEY="YOUR_API_KEY_SECRET" bash <(curl -s https://raw.githubusercontent.com/ManuelPalenzuelaDD/test-visibility-gitlab-script/master/script.sh))
  - npm run test
 ```

## Configuration

The script takes in the following parameters:

| Name | Description | Required | Default |
| ---- | ----------- | -------- | ------- |
 | LANGUAGES | List of languages to be instrumented. Can be either "all" or any of "java", "js", "python", "dotnet" (multiple languages can be specified as a space-separated list). | true | |
 | SERVICE | The name of the service or library being tested. | true | |
 | API_KEY | Datadog API key. Can be found at https://app.datadoghq.com/organization-settings/api-keys | true | |
 | SITE | Datadog site. See https://docs.datadoghq.com/getting_started/site for more information about sites. | false | datadoghq.com |
 | DOTNET_TRACER_VERSION | The version of Datadog .NET tracer to use. Defaults to the latest release. | false | |
 | JAVA_TRACER_VERSION | The version of Datadog Java tracer to use. Defaults to the latest release. | false | |
 | JS_TRACER_VERSION | The version of Datadog JS tracer to use. Defaults to the latest release. | false | |
 | PYTHON_TRACER_VERSION | The version of Datadog Python tracer to use. Defaults to the latest release. | false | |
 | JAVA_INSTRUMENTED_BUILD_SYSTEM | If provided, only the specified build systems will be instrumented (allowed values are `gradle` and `maven`). Otherwise every Java process will be instrumented. | false | |

### Additional configuration

Any [additional configuration values](https://docs.datadoghq.com/tracing/trace_collection/library_config/) can be added directly to the job that runs your tests:

```yaml
 test_node:
  image: node:latest
  script:
  - export DD_API_KEY="YOUR_API_KEY_SECRET"
  - export DD_ENV="staging-tests"
  - export DD_TAGS="layer:api,team:intake,key:value"
  - eval $(LANGUAGES="js" SITE="datadoghq.com" bash <(curl -s https://raw.githubusercontent.com/ManuelPalenzuelaDD/test-visibility-gitlab-script/master/script.sh))
  - npm run test
```

## Limitations

### Tracing vitest tests

ℹ️ This section is only relevant if you're running tests with [vitest](https://github.com/vitest-dev/vitest).

To use this script with [vitest](https://vitest.dev/) you need to modify the NODE_OPTIONS environment variable adding the `--import` flag with the value of the `DD_TRACE_ESM_IMPORT` environment variable.

TODO: Change script url
 ```yaml
 test_node_vitest:
  image: node:latest
  script:
  - eval $(LANGUAGES="js" SITE="datadoghq.com" API_KEY="YOUR_API_KEY_SECRET" bash <(curl -s https://raw.githubusercontent.com/ManuelPalenzuelaDD/test-visibility-gitlab-script/master/script.sh))
  - export NODE_OPTIONS="$NODE_OPTIONS --import $DD_TRACE_ESM_IMPORT"
  - npm run test
 ```

**Important**: `vitest` and `dd-trace` require Node.js>=18.19 or Node.js>=20.6 to work together.

TODO: Make release with script artifact and add sha to release
