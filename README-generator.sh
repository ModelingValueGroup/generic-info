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

MVG=ModelingValueGroup
repoList=(
    generic-info                    check
    upload-maven-package-action     test
    buildTools                      build%20and%20test
    immutable-collections           build%20and%20test
    dclare                          build%20and%20test
)
genLink() {
    local name="$1"; shift
    local  url="$1"; shift

    printf "[%s](%s)" "$name" "$url"
}
genStatusBadge() {
    local   repo="$1"; shift
    local action="$1"; shift

    genLink "Actions Status" "https://github.com/$MVG/$repo/workflows/$action/badge.svg"
}
genLastCommitBadge() {
    local repo="$1"; shift

    genLink "GitHub last commit" "https://img.shields.io/github/last-commit/$MVG/$repo?style=plastic"
}
genRepo() {
    local   repo="$1"; shift
    local action="$1"; shift

    local col2="$(genLink "!$(genStatusBadge     "$repo" "$action")" "https://github.com/$MVG/$repo/actions")"
    local col3="$(genLink "!$(genLastCommitBadge "$repo"          )" "https://github.com/$MVG/$repo"        )"

    echo "| $repo | $col2 | $col3 |"
}
cat <<EOF
| repos | build status | last commit |
|-------|--------------|-------------|
$(
    for i in "${repoList[@]}"; do
        if [[ "${r:-}" == "" ]]; then
            r="$i"
        else
            genRepo "$r" "$i"
            r=
        fi
    done
)
EOF
