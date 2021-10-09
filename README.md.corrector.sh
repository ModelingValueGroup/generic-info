#!/bin/bash
##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
## (C) Copyright 2018-2021 Modeling Value Group B.V. (http://modelingvalue.org)                                        ~
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

    local col2="$(genLink "!$(genLastCommitBadge "$repo" "$branch"                   )"   "https://github.com/$MVG/$repo"        )"
    if [[ "$action" != "-" ]]; then
        local col3="$(genLink "!$(genStatusBadge     "$repo" "$action" "master"          )"   "https://github.com/$MVG/$repo/actions")"
        local col4="$(genLink "!$(genStatusBadge     "$repo" "$action" "develop"         )"   "https://github.com/$MVG/$repo/actions")"
    else
        local col3=""
        local col4=""
    fi

    echo "| $repo | $col2 | $col3 | $col4 |"
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
