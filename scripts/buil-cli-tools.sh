#!/bin/sh -e

export SWIFT_DEPENDENCY_INJECTION_LOCAL_CLI_TOOLS=true

OUT_FILE="$(pwd)/swift-dependency-injection.zip"

cd CLI

swift package create-artifact-bundle --package-version 1.0.1 --product swift-dependency-injection --archive-name swift-dependency-injection

rm -rf $OUT_FILE
cp .build/plugins/CreateArtifactBundle/outputs/swift-dependency-injection.zip $OUT_FILE