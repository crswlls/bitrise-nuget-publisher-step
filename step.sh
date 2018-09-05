#!/bin/bash

# exit if a command fails
set -e

if [ -z "${nuget_source_path_or_url}" ] ; then
  echo " [!] Missing required input: nuget_source_path_or_url"
  exit 1
fi

if [ -z "${nuget_api_key}" ] ; then
  echo " [!] Missing required input: nuget_api_key"
  exit 1
fi

if [ -z "${nuspec_pattern}" ] ; then
  nuspec_pattern="^\.\/[^/]+.nuspec"
fi

if [ -z "${nupkg_pattern}" ] ; then
  nupkg_pattern="^\.\/[^/]+.nupkg"
fi

echo "source:    ${nuget_source_path_or_url}"
echo "api key:   ${nuget_api_key}"
echo "nuspecs:   ${nuspec_pattern}"
echo "nupkgs:    ${nupkg_pattern}"
echo "test mode: ${test_mode}"
echo ""

if [ ! -f "./nuget.exe" ]; then
  echo "Installing latest nuget.exe..."
  curl -O -L https://dist.nuget.org/win-x86-commandline/latest/nuget.exe
fi

nuget="mono ./nuget.exe"

echo " (i) Packaging specs matching pattern ${nuspec_pattern}"

# find nuspecs matching pattern
find -E . -type f -iregex "${nuspec_pattern}" | while read i; do
	echo " (i) Packaging ${i}..."
	${nuget} pack "${i}" -noninteractive -verbosity "detailed"
	echo " (i) Done"
done

echo " (i) Package creation finished"



echo " (i) Pushing packages matching pattern ${nupkg_pattern}"

# find packages matching pattern
find -E . -type f -iregex "${nupkg_pattern}" | while read i; do
	echo " (i) Pushing ${i}..."
	echo Executing: ${nuget} push "${i}" -source "${nuget_source_path_or_url}" -apikey ${nuget_api_key} -noninteractive -verbosity "detailed"
	
	if [[ "${test_mode}" == "no" ]] ; then
		${nuget} push "${i}" -source "${nuget_source_path_or_url}" -apikey ${nuget_api_key} -noninteractive -verbosity "detailed"
	fi
	echo " (i) Done"
done

echo " (i) Package push finished"

exit 0
