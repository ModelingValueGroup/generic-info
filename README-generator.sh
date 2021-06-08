#!/bin/bash
##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
## (C) Copyright 2018-2019 Modeling Value Group B.V. (http://modelingvalue.org)                                        ~
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

    genLink "" "https://github.com/$MVG/$repo/workflows/$action/badge.svg?branch=$branch"
}
genLastCommitBadge() {
    local repo="$1"; shift

    genLink "GitHub last commit" "https://img.shields.io/github/last-commit/$MVG/$repo?style=plastic"
}
genRepo() {
    local category="$1"; shift
    local     repo="$1"; shift
    local   action="$1"; shift

    local col2 col3 col4
    col2="$(genLink "!$(genLastCommitBadge "$repo"                    )"            "https://github.com/$MVG/$repo"        )"
    col3="$(genLink "!$(genStatusBadge     "$repo" "$action" "master" )"            "https://github.com/$MVG/$repo/actions")"
    col4="$(genLink "!$(genStatusBadge     "$repo" "$action" "develop")"            "https://github.com/$MVG/$repo/actions")"
    col5="$(genLink "!$(genStatusBadge     "$repo" "$action" "gradle-candidate")"   "https://github.com/$MVG/$repo/actions")"

    echo "| $category | $repo | $col2 | $col3 | $col4 | $col5 |"
}
gen() {
    local category="$1"; shift

    local i r
    for i in "$@"; do
        if [[ "${r:-}" == "" ]]; then
            r="$i"
        else
            genRepo "$category" "$r" "$i"
            r=
            category=
        fi
    done
}
cat <<EOF
|       | repository | last commit  | master | develop | gradle-candidate |
|-------|------------|--------------|--------|---------|------------------|
$(gen dclare   "${repoListDclare[@]}")
|       |            |              |        |         |                  |
$(gen examples "${repoListExamples[@]}")
|       |            |              |        |         |                  |
$(gen support  "${repoListSupport[@]}")
|       |            |              |        |         |                  |
$(gen aux      "${repoListAux[@]}")
EOF
