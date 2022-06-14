#!/bin/sh -e

export TOOLCHAINS="Swift Development Snapshot"
export SWIFT_DEPENDENCY_INJECTION_LOCAL_CLI_TOOLS=true
export REAL_SWIFT_SYNTAX_PARSER_LIB_SEARCH_PATH=/Library/Developer/Toolchains/swift-DEVELOPMENT-SNAPSHOT-2022-06-08-a.xctoolchain/usr/lib/swift/macosx/lib_InternalSwiftSyntaxParser.dylib
#export SWIFT_SYNTAX_PARSER_LIB_SEARCH_PATH=@executable_path/../lib_InternalSwiftSyntaxParser.dylib

OUT_FILE="$(pwd)/swift-dependency-injection.zip"

cd CLI

swift package create-artifact-bundle --package-version 1.0.1 --product swift-dependency-injection --archive-name swift-dependency-injection --copy-additional-files $REAL_SWIFT_SYNTAX_PARSER_LIB_SEARCH_PATH

rm -rf $OUT_FILE
cp .build/plugins/CreateArtifactBundle/outputs/swift-dependency-injection.zip $OUT_FILE