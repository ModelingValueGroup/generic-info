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
    generic-info
    upload-maven-package-action
    buildTools
    immutable-collections
    dclare
)
genLink() {
    local name="$1"; shift
    local  url="$1"; shift

    printf "[%s](%s)" "$name" "$url"
}
genStatusBadge() {
    local repo="$1"; shift

    genLink "Actions Status" "https://github.com/$MVG/$repo/workflows/check/badge.svg"
}
genLastCommitBadge() {
    local repo="$1"; shift

    genLink "GitHub last commit" "https://img.shields.io/github/last-commit/$MVG/$repo?style=plastic"
}
genRepo() {
    local repo="$1"; shift

    local col2="$(genLink "!$(genStatusBadge "$repo")" "https://github.com/$MVG/$repo/actions")"
    local col3="$(genLink "!$(genLastCommitBadge "$repo")" "https://github.com/$MVG/$repo")"

    echo "| $repo | $col2 | $col3 |"
}
cat <<EOF
| repos | build status | last commit |
|-------|--------------|-------------|
$(
    for r in "${repoList[@]}"; do
        genRepo "$r"
    done
)
|-------|--------------|-------------|
|generic-info|[![Actions Status](https://github.com/ModelingValueGroup/generic-info/workflows/check/badge.svg)](https://github.com/ModelingValueGroup/generic-info/actions)|![GitHub last commit](https://img.shields.io/github/last-commit/ModelingValueGroup/generic-info?style=plastic)|
|upload-maven-package-action|[![Actions Status](https://github.com/ModelingValueGroup/upload-maven-package-action/workflows/test/badge.svg)](https://github.com/ModelingValueGroup/upload-maven-package-action/actions)|![GitHub last commit](https://img.shields.io/github/last-commit/ModelingValueGroup/upload-maven-package-action?style=plastic)|
|buildTools|[![Actions Status](https://github.com/ModelingValueGroup/buildTools/workflows/build%20and%20test/badge.svg)](https://github.com/ModelingValueGroup/buildTools/actions)|![GitHub last commit](https://img.shields.io/github/last-commit/ModelingValueGroup/buildTools?style=plastic)|
|immutable-collections|[![Actions Status](https://github.com/ModelingValueGroup/immutable-collections/workflows/build%20and%20test/badge.svg)](https://github.com/ModelingValueGroup/immutable-collections/actions)|![GitHub last commit](https://img.shields.io/github/last-commit/ModelingValueGroup/immutable-collections?style=plastic)|
|dclare|[![Actions Status](https://github.com/ModelingValueGroup/dclare/workflows/build%20and%20test/badge.svg)](https://github.com/ModelingValueGroup/dclare/actions)|![GitHub last commit](https://img.shields.io/github/last-commit/ModelingValueGroup/dclare?style=plastic)|
EOF
