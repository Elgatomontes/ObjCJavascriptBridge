#!/bin/sh
xcodebuild -workspace ObjectiveCJavascriptIntegration.xcworkspace -scheme ObjectiveCJavascriptIntegration -configuration Debug ONLY_ACTIVE_ARCH=NO clean build SYMROOT=$(PWD)/build
rm -r ${PWD}/build