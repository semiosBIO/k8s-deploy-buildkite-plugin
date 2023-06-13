## Testing this plugin

Follow the guidelines in the [Buildkite plugins documentation](https://buildkite.com/docs/plugins/writing#step-5-add-a-test). The easist way to run these tests is with Docker using this command:

```sh
docker run -it --rm -v "$PWD:/plugin:ro" buildkite/plugin-tester
```

Take a look at the [plugin test documentation](https://github.com/buildkite-plugins/buildkite-plugin-tester) to find out how to use assertions, mocks etc.
