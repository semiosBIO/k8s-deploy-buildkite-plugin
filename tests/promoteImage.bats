#!/usr/bin/env bats

load "$BATS_PLUGIN_PATH/load.bash"

setup() {
    export BUILDKITE_PLUGIN_K8S_DEPLOY_SOURCEIMAGE_REPOSITORYURL="552375026182.dkr.ecr.ap-southeast-2.amazonaws.com"
    export BUILDKITE_PLUGIN_K8S_DEPLOY_SOURCEIMAGE_IMAGE="website:test_tag"
    export BUILDKITE_PLUGIN_K8S_DEPLOY_DESTINATIONIMAGES_0_REPOSITORYURL="587935219773.dkr.ecr.ap-southeast-2.amazonaws.com"
    export BUILDKITE_PLUGIN_K8S_DEPLOY_DESTINATIONIMAGES_0_IMAGE="website:test_tag"
    export BUILDKITE_PLUGIN_K8S_DEPLOY_DESTINATIONIMAGES_0_REGION="ap-southeast-2"
    export BUILDKITE_PLUGIN_K8S_DEPLOY_ACTION="promoteImage"
}

teardown() {
  unstub docker
}

@test "calls docker pull with the source image" {
    stub docker \
         "inspect \* \* : exit 0" \
         "pull \* : echo \$2 > /tmp/docker-pull-image" \
         "tag \* \* : exit 0" \
         "push \* : exit 0" \
         "rmi \* : exit 0" \

    run "$PWD/hooks/command"

    assert_success
    pull_image="$(cat /tmp/docker-pull-image)"
    assert_equal "${pull_image}" "552375026182.dkr.ecr.ap-southeast-2.amazonaws.com/website:test_tag"
}

@test "calls docker tag, push, rmi with correct destination" {
    stub docker \
         "inspect \* \* : exit 0" \
         "pull \* : exit 0" \
         "tag \* \* : echo \$2 > /tmp/docker_tag" \
         "push \* : echo \$2 > /tmp/docker_push" \
         "rmi \* : echo \$2 > /tmp/docker_rmi" \

         run "$PWD/hooks/command"

    assert_success
    docker_tag="$(cat /tmp/docker_tag)"
    docker_push="$(cat /tmp/docker_push)"
    docker_rmi="$(cat /tmp/docker_rmi)"
    assert_equal "${docker_tag}" "552375026182.dkr.ecr.ap-southeast-2.amazonaws.com/website:test_tag"
    assert_equal "${docker_push}" "587935219773.dkr.ecr.ap-southeast-2.amazonaws.com/website:test_tag"
    assert_equal "${docker_rmi}" "587935219773.dkr.ecr.ap-southeast-2.amazonaws.com/website:test_tag"
    assert_output --partial "Image promotion success"
}

@test "promoteImage fails if image cannot be pulled" {
    stub docker \
         "inspect \* \* : exit 0" \
         "pull \* : exit 1" \

         run "$PWD/hooks/command"

    assert_failure
    assert_output --partial "Failed to pull source image"
}

@test "promoteImage fails if image cannot be pushed" {
    stub docker \
         "inspect \* \* : exit 0" \
         "pull \* : exit 0" \
         "tag \* \* : exit 0" \
         "push \* : exit 1" \
         "rmi \* : exit 0" \

         run "$PWD/hooks/command"

    assert_failure
    assert_output --partial "Promotion failed"
}

@test "cleans up image if it did not exist on host" {
    stub docker \
         "inspect \* \* : exit 1" \
         "pull \* : exit 0" \
         "tag \* \* : exit 0" \
         "push \* : exit 0" \
         "rmi \* : exit 0" \
         "image rm \* : echo 'image rm called'"

    run "$PWD/hooks/command"

    assert_success
    assert_output --partial "image rm called"
}

@test "does not clean up image if it did exist on host" {
    stub docker \
         "inspect \* \* : exit 0" \
         "pull \* : exit 0" \
         "tag \* \* : exit 0" \
         "push \* : exit 0" \
         "rmi \* : exit 0"

    run "$PWD/hooks/command"

    assert_success
    refute_output --partial "image rm called"
}
