#!/bin/bash
##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
## (C) Copyright 2018-2023 Modeling Value Group B.V. (http://modelingvalue.org)                                        ~
##                                                                                                                     ~
## Licensed under the GNU Lesser General Public License v3.0 (the 'License'). You may not use this file except in      ~
## compliance with the License. You may obtain a copy of the License at: https://choosealicense.com/licenses/lgpl-3.0  ~
## Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on ~
## an 'AS IS' BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the  ~
## specific language governing permissions and limitations under the License.                                          ~
##                                                                                                                     ~
## Maintainers:                                                                                                        ~
##     Wim Bast, Tom Brus, Ronald Krijgsheld                                                                           ~
## Contributors:                                                                                                       ~
##     Arjan Kok, Carel Bast                                                                                           ~
##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

set -euo pipefail

###########################################################################################################################
. ./info.sh
###########################################################################################################################
genLink() {
    local name="$1"; shift
    local  url="$1"; shift

    printf "[%s](%s)" "$name" "$url"
}
genStatusBadge() {
    local   repo="$1"; shift
    local action="$1"; shift
    local branch="$1"; shift

    genLink "" "https://github.com/$MVG/$repo/actions/workflows/$action/badge.svg?branch=$branch"
}
genLastCommitBadge() {
    local   repo="$1"; shift
    local branch="$1"; shift

    genLink "GitHub last commit" "https://img.shields.io/github/last-commit/$MVG/$repo/$branch?style=for-the-badge"
}
genRepo() {
    local     repo="$1"; shift
    local   action="$1"; shift
    local   branch="$1"; shift

    local isPrivate="$(curl -f --silent "https://github.com/$MVG/$repo" -o /dev/null > /dev/null 2>&1 && echo false || echo true)"

    local col1="$(genLink "$repo"                                               "https://github.com/$MVG/$repo"         )"
    local col2="$(genLink "!$(genLastCommitBadge "$repo" "$branch"          )"  "https://github.com/$MVG/$repo"         )"
    local col3="$(genLink "!$(genStatusBadge     "$repo" "$action" "master" )"  "https://github.com/$MVG/$repo/actions" )"
    local col4="$(genLink "!$(genStatusBadge     "$repo" "$action" "develop")"  "https://github.com/$MVG/$repo/actions" )"

    if [[ "$isPrivate" == true ]]; then
        col2="_private repo_"
    fi
    if [[ "$action" == "-" ]]; then
        col3=""
        col4=""
    fi

    echo "| $col1 | $col2 | $col3 | $col4 |"
}
gen() {
    local category="$1"; shift

    echo "| $category |"

    local i repo action branch
    for i in "$@"; do
        if [[ "${repo:-}" == "" ]]; then
            repo="$i"
        elif [[ "${action:-}" == "" ]]; then
            action="$i"
        else
            branch="$i"
            genRepo "$repo" "$action" "$branch"
            branch=
            action=
            repo=
        fi
    done
}
cat <<"EOF"
N.B. see below if you want to easily build the dclare stack from scratch

EOF
cat <<EOF
| repository | last commit  | master | develop |
|------------|--------------|--------|---------|
$(gen ":one: **\`dclare\`**"        "${repoListDclare[@]}")
|            |              |        |         |
$(gen ":two: **\`examples\`**"      "${repoListExamples[@]}")
|            |              |        |         |
$(gen ":three: **\`support\`**"     "${repoListSupport[@]}")
|            |              |        |         |
$(gen ":four: **\`aux\`**"          "${repoListAux[@]}")
EOF
cat <<"EOF"


## How to easily build the dclare stack from scratch
Our dclare stack is made out of multiple github repositories.
To easily build the whole stack do the following:
- find your github token that has the authority to access the github-package-registry or make a new token if you prefer (sorry, github requires this)
- add the following line to your `~/.gradle/gradle.properties` file:
```
ALLREP_TOKEN=<github-token>
```
- make a fresh directory somewhere that will contain all the projects
- clone the `generic-info` repo in this new directory
- cd to the new clone
- execute `./all-projects.sh` in a bash window
- you will get a CHUI choice of options, choose '3' to run a full build
- the script will run for a few minutes
  - it wil clone the needed projects
  - it will build them in the right order with gradle
  - ...and leave the projects build on your disk

BTW: this method will only build the `develop` branch.

EOF
