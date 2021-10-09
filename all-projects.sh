#!/usr/bin/env bash
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

forAllProjects() {
    local fun="$1"; shift

    local i repo action branch
    for i in "${repoList[@]}"; do
        if [[ "${repo:-}" == "" ]]; then
            repo="$i"
        elif [[ "${action:-}" == "" ]]; then
            action="$i"
        else
            branch="$i"
            "$fun" "$repo" "$action" "$branch"
            branch=
            action=
            repo=
        fi
    done
}
numLines() {
    wc -l | sed 's/ //g;s/^0$/-/'
}
prepProject() {
    local repo="$1"; shift
    local a="$1"; shift
    local b="$1"; shift

    if [[ ! -d "../$repo" ]]; then
        printf "   %-32s cloning...\n" "$repo"
        git clone "https://github.com/ModelingValueGroup/$repo.git" "../$repo" 2>&1 >/dev/null
    else
        printf "   %-32s fetching...\n" "$repo"
        (   cd "../$repo"
            echo "      fetching..."
            git fetch origin | sed 's/^/       >/'
            echo "      pulling..."
            git pull         | sed '/^Already /d;s/^/       >/'
            for br in $(git branch | sed '/\*/d;s/..//'); do
                echo "      $br"
                git fetch origin $br:$br || :
            done
        ) # 2>&1 >/dev/null
    fi
}
projectInfo() {
    local repo="$1"; shift
    local a="$1"; shift
    local b="$1"; shift

    (   cd ../$repo
        local  branch="$(git status | egrep "^On branch "                | sed 's/On branch //')"
        local   dirty="$(git status | egrep '^\t(new file|modified):   ' | numLines)"
        local updates="$(git log HEAD..origin/$branch --oneline          | numLines)"
        local version="-"

        printf "   %-30s %-16s %6s %6s %10s\n" "$repo" "$branch" "$updates" "$dirty" "$version"
    )
}
gather() {
    local repo="$1"; shift
    local a="$1"; shift
    local b="$1"; shift

    local version="-"
    info[$repo]="$version"
}
main() {
    . ./info.sh
    declare -A info
    forAllProjects gather

    echo
    echo "############################################ prep projects:"
    #forAllProjects prepProject

    echo
    echo "############################################ project info:"
    echo "   repos-name                     branch           behind  dirty    version"
    echo "   ------------------------------------------------------------------------"
    forAllProjects projectInfo

    echo
    echo "############################################ current versions:"
    for r in "${!info[@]}"; do
        if [[ "${info[$r]}" != '-' ]]; then
            printf "   %-30s = %s\n" "$r" "${info[$r]}"
        fi
    done | sort

    echo
    echo "############################################ unrelated projects:"
    (cd ..; eval "ls $(printf " | fgrep -v '%s'" ${!info[@]})")
}


main
