#!/bin/bash

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    echo "jq could not be found. Please install jq to use this script."
    exit 1
fi

# Check for correct number of arguments
if [[ "$#" == 1 ]]; then
       GROUP_ID="$(sed 's/:.*//' <<<$1 )"
    ARTIFACT_ID="$(sed 's/.*://' <<<$1 )"
elif [[ "$#" == 2 ]]; then
       GROUP_ID="$1"
    ARTIFACT_ID="$2"
else
    echo "Usage: $0 <group-id> <artifact-id>"
    exit 1
fi

# URL encode the group ID and artifact ID
   GROUP_ID_ENCODED=$(echo $GROUP_ID | sed 's/\./%2E/g')
ARTIFACT_ID_ENCODED=$(echo $ARTIFACT_ID | sed 's/\./%2E/g')

# Construct the search URL
SEARCH_URL="https://search.maven.org/solrsearch/select?q=g:%22$GROUP_ID_ENCODED%22+AND+a:%22$ARTIFACT_ID_ENCODED%22&rows=1&wt=json"

S2="https://search.maven.org/solrsearch/select?q=g:%22$GROUP_ID_ENCODED%22+AND+a:%22$ARTIFACT_ID_ENCODED%22&rows=10&wt=json&core=gav&sort=version+desc"

curl -s "$S2"
echo

# Fetch the latest version using curl and parse it with jq
LATEST_VERSION=$(curl -s "$SEARCH_URL" | jq -r '.response.docs[0].latestVersion')

if [ "$LATEST_VERSION" = "null" ]; then
    echo "//Could not find the latest version for $GROUP_ID:$ARTIFACT_ID"
else
    echo "$GROUP_ID:$ARTIFACT_ID:$LATEST_VERSION"
fi

