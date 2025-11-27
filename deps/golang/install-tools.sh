#!/bin/bash
set -o errexit -o nounset -o pipefail -o xtrace

# These seem to be commonly used when compiling Go tools, e.g.:
#   https://github.com/anchore/syft/blob/5b96d1d69d76098778be0f8556d1a63d1050239f/.goreleaser.yaml#L20-L21
#   https://github.com/mikefarah/yq/blob/588d0bb3dd6e3d2d8db66e4fc68761108d299abe/Makefile.variables#L10
# Their purpose is to reduce the size of the binaries by omitting debug info.
COMMON_LDFLAGS='-s -w'

install_tool() {
    local name=$1
    local version_attribute=${2:-}

    cd "$name"

    # 'go tool' also lists builtin tools, filter them out by looking for the '.' in domain names
    go tool | grep -F . | while read -r tool_pkg; do
        local ldflags=$COMMON_LDFLAGS
        if [[ -n "$version_attribute" ]]; then
            version=$(go list -f '{{.Module.Version}}' "$tool_pkg")
            ldflags+=" -X ${version_attribute}=${version#v}"
        fi

        go install -ldflags "$ldflags" "$tool_pkg"
    done

    cd ..
}

install_tool syft "main.version"

install_tool yq

install_tool tkn "github.com/tektoncd/cli/pkg/cmd/version.clientVersion"

install_tool cosign "sigs.k8s.io/release-utils/version.gitVersion"

install_tool oras "oras.land/oras/internal/version.BuildMetadata"

install_tool conftest "github.com/open-policy-agent/conftest/internal/version.Version"
