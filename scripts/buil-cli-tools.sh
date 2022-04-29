#!/bin/sh -e

OUT_FILE="$(pwd)/swift-dependency-injection.zip"
cd ../swift-dependency-injection-cli

swift package create-artifact-bundle --package-version 1.0.1 --archive-name swift-dependency-injection

ditto .build/plugins/CreateArtifactBundle/outputs/swift-dependency-injection.zip $OUT_FILE