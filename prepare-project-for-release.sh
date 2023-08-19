#!/usr/bin/env bash
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

#set -x
set -euo pipefail

repoSeq=(
    sync-proxy
    mvg-json
    immutable-collections
    dclare
    dclareForMPS
    dclareForJava
    cdm
    cds-runtime
    cdm-generator
)

main() {
    updateProjects
    showVersions
    newVersion="$(askForVersion "$1")"
    adjustVersions $newVersion
    showVersions
    askSure
    pushAll $newVersion
    showVersions
}
askForVersion() {
    REPLY="$1"
    while ! [[ "$REPLY" =~ [0-9]+[.][0-9]+[.][0-9] ]]; do
        read -p "$(printf "new version: ")" -r 
        echo 1>&2
    done
    echo -n "$REPLY"
}
updateProjects() {
    local p
    for p in "${repoSeq[@]}"; do
        ( cd ../$p; git remote update )&
    done
    wait
}
showVersions() {
    echo
    showHeader
    local p
    for p in "${repoSeq[@]}"; do
        (   cd ../$p
            s="$(getProjectState)"
            v="$(egrep '^version *= *.*$' gradle.properties | sed 's/.*= *//')"
            printf " %-21s %-10s %-10s    " "$p" "$s" "$v"
            declare -A mv
            for f in $(find . -name \*.kts); do
                for dep in $(fgrep BRANCHED $f | sed 's/.*:\(.*\):\(.*\)-BRANCHED.*/\1:\2/' | sort -u || :); do
                    read m v <<<"${dep/:/ }"
                    mv[$m]=$v
                done
            done
            for pp in "${repoSeq[@]}"; do
                printf "%-21s " "${mv[$pp]:--}"
            done
            echo
        )
    done
    echo
}
showHeader() {
    printf "%-21s %-10s %-10s    " "PROJECT" "STATE" "VERSION"
    printf "%-21s " "${repoSeq[@]}"
    echo
}
adjustVersions() {
    local VERSION="$1"
    echo "========================================> $newVersion"
    local p
    for p in "${repoSeq[@]}"; do
        (   cd ../$p
            sed -i '' 's/^\(version *= *\).*$/\1'"$VERSION"'/' gradle.properties
            for f in $(find . -name \*.kts); do
                sed -i '' 's/^\(.*:.*:\)[^:]*\(-BRANCHED.*\)$/\1'"$VERSION"'\2/' $f
            done
        )
    done
}
getProjectState() {
    if output=$(git status --porcelain) && [[ "$output" != "" ]]; then
        echo "DIRTY"
    else
        local  localHash=$(git rev-parse @)
        local remoteHash=$(git rev-parse "@{u}")
        local   baseHash=$(git merge-base @ "@{u}")

        if [[ "$localHash" == "$remoteHash" ]]; then
            echo "clean"
        elif [[ "$localHash" == "$baseHash" ]]; then
            echo "NEED_PULL"
        elif [[ "$remoteHash" == "$baseHash" ]]; then
            echo "NEED-PUSH"
        else
            echo "DIVERGED"
        fi
    fi
}
askSure() {
    read -p "are you sure? [type 'yes']: "
    if [[ "$REPLY" != yes ]]; then
        exit 99
    fi
}
pushAll() {
    local VERSION="$1"
    echo
    echo "========================================> commit & push"
    local p
    for p in "${repoSeq[@]}"; do
        (   cd ../$p
            git add .
            git commit -m "prepare for release $VERSION"
            git push
        )
    done
}

main "${1:-}"
