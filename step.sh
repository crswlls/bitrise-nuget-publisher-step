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

echo "source:  ${nuget_source_path_or_url}"
echo "api key: ${nuget_api_key}"
echo "nuspecs: ${nuspec_pattern}"
echo "nupkgs:  ${nupkg_pattern}"
echo ""

nuget="/Library/Frameworks/Mono.framework/Versions/Current/bin/nuget"

echo " (i) Packaging specs matching pattern ${nuspec_pattern}"

# find nuspecs matching pattern
count=0
find -E . -type f -iregex "${nuspec_pattern}" | while read i; do
	echo " (i) Packaging ${i}..."
	"${nuget}" pack "${i}" -noninteractive -verbosity "detailed"
	echo " (i) Done"
	count++
done

if [[ ${count} -eq 0 ]] ; then
	echo " (w) No nuspec files found, no packages created"
else
	echo " (i) Packages created successfully"
fi



echo " (i) Pushing packages matching pattern ${nupkg_pattern}"

# find packages matching pattern
count=0
find -E . -type f -iregex "${nupkg_pattern}" | while read i; do
	echo " (i) Pushing ${i}..."
	echo "${nuget}" push "${i}" -source "${nuget_source_path_or_url}" -apikey ${nuget_api_key} -noninteractive -verbosity "detailed"
	
	if [[ "${test_mode}" == "no" ]] ; then
		"${nuget}" push "${i}" -source "${nuget_source_path_or_url}" -apikey ${nuget_api_key} -noninteractive -verbosity "detailed"
	fi
	echo " (i) Done"
done

if [[ ${count} -eq 0 ]] ; then
	echo " (w) No nupkg files found, no packages pushed"
else
	echo " (i) Packages pushed successfully"
fi

exit 0