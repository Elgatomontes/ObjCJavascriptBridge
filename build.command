#!/bin/sh

# Declare vars.
workspacename="ObjectiveCJavascriptIntegration" # The name of the workspace
scheme=$workspacename # The workspace scheme.
workspace_dir=$(dirname $0) # The direction of the workspace folder (The current direction).
build_location=$workspace_dir/build # The direction of the folder to save the build.
workspace_configuration="Debug" # The configuration to compile in "debug" mode o "release" mode.
onlyactivarch="NO" # Compile only to the current valid architecture?.

# Change to workspace folder.
cd $workspace_dir
echo "Se cambio hacia la ruta: $workspace_dir"

# Compile workspace. This is going to create a .app file.
xcodebuild -workspace $workspacename.xcworkspace -scheme $scheme -configuration $workspace_configuration ONLY_ACTIVE_ARCH=$onlyactivarch clean build SYMROOT=$build_location

# Check if build succeeded.
if [ $? != 0 ]
then
	echo "Error al compilar el workspace.\n"
	rm -r build/
  	exit 1
fi
echo "El WorkSpace se compiló correctamente.\n"

if [[ $workspace_configuration == "Debug" ]]; then
	echo "NO HAY QUE GENERAR UN .IPA\n"
	rm -r build/
	exit 0
fi

# Generate .ipa file.
xcrun -sdk iphoneos PackageApplication -v "$build_location/$workspace_configuration-iphoneos/$workspacename.app" -o "$workspace_dir/$workspacename.ipa"

# Check if .ipa generation succeeded.
if [ $? != 0 ]
then
	echo "Error al generar el .ipa el workspace.\n"
	rm -r build/
  	exit 1
fi
echo "El .ipa del workspace se generó correctamente.\n"

rm -r build/
