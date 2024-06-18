#!/bin/bash
##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
##  (C) Copyright 2018-2024 Modeling Value Group B.V. (http://modelingvalue.org)                                         ~
##                                                                                                                       ~
##  Licensed under the GNU Lesser General Public License v3.0 (the 'License'). You may not use this file except in       ~
##  compliance with the License. You may obtain a copy of the License at: https://choosealicense.com/licenses/lgpl-3.0   ~
##  Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on  ~
##  an 'AS IS' BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the   ~
##  specific language governing permissions and limitations under the License.                                           ~
##                                                                                                                       ~
##  Maintainers:                                                                                                         ~
##      Wim Bast, Tom Brus                                                                                               ~
##                                                                                                                       ~
##  Contributors:                                                                                                        ~
##      Ronald Krijgsheld ✝, Arjan Kok, Carel Bast                                                                       ~
## --------------------------------------------------------------------------------------------------------------------- ~
##  In Memory of Ronald Krijgsheld, 1972 - 2023                                                                          ~
##      Ronald was suddenly and unexpectedly taken from us. He was not only our long-term colleague and team member      ~
##      but also our friend. "He will live on in many of the lines of code you see below."                               ~
##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

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

