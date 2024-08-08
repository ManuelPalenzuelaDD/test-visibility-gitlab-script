# <img height="25" src="logos/test_visibility_logo.png" />  Datadog Test Visibility GitLab Script

Bash script that installs and configures [Datadog Test Visibility](https://docs.datadoghq.com/tests/)for GitLab. 
Supported languages are .NET, Java, Javascript, and Python.

## About Datadog Test Visibility

[Test Visibility](https://docs.datadoghq.com/tests/) provides a test-first view into your CI health by displaying important metrics and results from your tests. 
It can help you investigate and mitigate performance problems and test failures that are most relevant to your work, focusing on the code you are responsible for, rather than the pipelines which run your tests.

## Usage

1. Execute this script in your GitLab CI's job YAML before running the tests. Set the language, service name, api key and [site](https://docs.datadoghq.com/getting_started/site/) parameters: 

TODO: Change script url (tagged?) as well as be more explicit with DD_SITE and DD_API_KEY
   ```yaml
   test_node:
    image: node:latest
    script:
    - eval $(LANGUAGES="js" SITE="datadoghq.com" API_KEY="YOUR_API_KEY_SECRET" bash <(curl -s https://raw.githubusercontent.com/ManuelPalenzuelaDD/test-visibility-gitlab-script/master/script.sh))
    - npm run test
   ```

## Configuration

The script takes in the following parameters: TODO: Make the parameters like this (shorter)

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

For security reasons Github [does not allow](https://github.blog/changelog/2023-10-05-github-actions-node_options-is-now-restricted-from-github_env/) actions to alter the `NODE_OPTIONS` environment variable, so you'll have to pass it manually.

### Tracing JS tests (except `vitest`)

If you're running tests with [vitest](https://github.com/vitest-dev/vitest), go to [Tracing vitest tests](#tracing-vitest-tests).

To work around the `NODE_OPTIONS` limitation, the action provides a separate `DD_TRACE_PACKAGE` variable that needs to be appended to `NODE_OPTIONS` manually:

```yaml
- name: Run tests
  shell: bash
  run: npm run test-ci
  env:
    NODE_OPTIONS: -r ${{ env.DD_TRACE_PACKAGE }}
```

### Tracing vitest tests TODO

ℹ️ This section is only relevant if you're running tests with [vitest](https://github.com/vitest-dev/vitest).

To work around the `NODE_OPTIONS` limitation, the action provides a separate `DD_TRACE_PACKAGE` and `DD_TRACE_ESM_IMPORT` variables that need to be appended to `NODE_OPTIONS` manually:

```yaml
- name: Run tests
  shell: bash
  run: npm run test:vitest
  env:
    NODE_OPTIONS: -r ${{ env.DD_TRACE_PACKAGE }} --import ${{ env.DD_TRACE_ESM_IMPORT }}
```

**Important**: `vitest` and `dd-trace` require Node.js>=18.19 or Node.js>=20.6 to work together.
