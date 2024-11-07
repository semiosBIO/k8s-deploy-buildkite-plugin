#!/usr/bin/env bats

load "$BATS_PLUGIN_PATH/load.bash"

setup() {
    export BUILDKITE_PLUGIN_K8S_DEPLOY_CHART="test-chart"
    export BUILDKITE_PLUGIN_K8S_DEPLOY_CHART_VERSION="0.1.14"
    export BUILDKITE_PLUGIN_K8S_DEPLOY_RELEASE="test-release"
    export BUILDKITE_PLUGIN_K8S_DEPLOY_TAG="a932ae5ee92598f76edae9a476cfc7f9e574a679"
    export BUILDKITE_PLUGIN_K8S_DEPLOY_ACTION="helmDeploy"
}

teardown() {
  unstub helm
}

@test "exits if release is in wrong status" {
    stub helm \
         "repo update : echo 'helm repo update called'" \
         "status \* \* \* : echo 'STATUS: pending-upgrade'"

    run "$PWD/hooks/command"

    assert_failure
    assert_output --partial "is in the wrong status 'pending-upgrade'"
}

@test "exits if helm upgrade fails" {
    stub helm \
         "repo update : echo 'helm repo update called'" \
         "status \* \* \* : echo 'STATUS: deployed'" \
         "upgrade \*  \*  \*  \*  \*  \*  \*  \*  \*  \*  \*  \*  \*  \*  \*  \* : echo \${15}; exit 1"
    run "$PWD/hooks/command"

    assert_failure
    assert_output --partial "Failed to update test-release of test-chart with version 0.1.14"
}

@test "outputs message if release is not found and will be created" {
    stub helm \
         "repo update : echo 'helm repo update called'" \
         "status \* \* \* : echo 'Not found'" \
         "upgrade \*  \*  \*  \*  \*  \*  \*  \*  \*  \*  \*  \*  \*  \*  \*  \* : echo \${15}; exit 0"

    run "$PWD/hooks/command"

    assert_success
    assert_output --partial "Release test-release not found, creating"
}

@test "calls helm upgrade with chart version" {
    stub helm \
         "repo update : echo 'helm repo update called'" \
         "status \* \* \* : echo 'STATUS: deployed'" \
         "upgrade \*  \*  \*  \*  \*  \*  \*  \*  \*  \*  \*  \*  \*  \*  \*  \* : echo \${15}; exit 0"

    run "$PWD/hooks/command"

    assert_success
    assert_output --partial "0.1.14"
}
