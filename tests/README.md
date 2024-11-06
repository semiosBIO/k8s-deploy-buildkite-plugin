## Testing this plugin

Follow the guidelines in the [Buildkite plugins documentation](https://buildkite.com/docs/plugins/writing#step-5-add-a-test).

The easist way to run these tests is with Docker using this command in the top
level directory, where the docker-compose.yml file is.

```sh
docker compose run --rm tests
```

Take a look at the [plugin test documentation](https://github.com/buildkite-plugins/buildkite-plugin-tester) to find out how to use assertions, mocks etc.

### Debugging Stubs

This is explained in the docs as well but is very useful. If you are stubbing an
executable like docker, then you can debug it by adding a matching ENV variable
like this:

```
@test "cleans up image if it did not exist on host" {
    stub docker \
         "inspect \* \* : exit 1"

    export DOCKER_STUB_DEBUG=3

```

When you run the tests you will see in the output exactly what is happening in the stub.
