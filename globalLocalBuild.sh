#!/usr/bin/env bash
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

forAllProjects() {
    local fun="$1"; shift

    local  i=''
    local ii=''
    for i in "${repoList[@]}"; do
        if [[ "$ii" == '' ]]; then
            ii="$i"
        else
            "$fun" "$ii" "$i"
            ii=''
        fi
    done
}
numLines() {
    wc -l | sed 's/ //g;s/^0$/-/'
}
prepProject() {
    local repo="$1"; shift

    if [[ ! -d "../$repo" ]]; then
        printf "   %-32s cloning...\n" "$repo"
        git clone "https://github.com/ModelingValueGroup/$repo.git" ../$repo 2>&1 >/dev/null
    else
        printf "   %-32s fetching...\n" "$repo"
        (cd "../$repo"; git fetch origin 2>&1 >/dev/null)
    fi
}
projectInfo() {
    local repo="$1"; shift

    (   cd ../$repo
        local  branch="$(git status | egrep "^On branch "                | sed 's/On branch //')"
        local   dirty="$(git status | egrep '^\t(new file|modified):   ' | numLines)"
        local updates="$(git log HEAD..origin/$branch --oneline          | numLines)"
        local version
        if [[ -f "../$repo/project.sh" ]]; then
            . "../$repo/project.sh"
            read a g version e f <<< "${artifacts[0]}"
        else
            version="-"
        fi
        printf "   %-30s %-16s %6s %6s %10s\n" "$repo" "$branch" "$updates" "$dirty" "$version"
    )
}
versionConsistency() {
    declare -A info
    gather() {
        local repo="$1"; shift

        if [[ -f "../$repo/project.sh" ]]; then
            . "../$repo/project.sh"
            read a g version e f <<<"${artifacts[0]}"
        else
            local version="-"
        fi
        info[$repo]="$version"
    }
    forAllProjects gather

    echo
    echo "############################################ current versions:"
    for r in "${!info[@]}"; do
        if [[ "${info[$r]}" != '-' ]]; then
            printf "   %-30s = %s\n" "$r" "${info[$r]}"
        fi
    done | sort

    check() {
        local repo="$1"; shift

        if [[ -f "../$repo/project.sh" ]]; then
            . "../$repo/project.sh"
            for dep in "${dependencies[@]}"; do
                if [[ "$dep" =~ jars@* ]]; then
                    : # ignore jars dependencies here
                else
                    read a g v e f <<<"$dep"
                    if [[ "${info[$g]:-}" != "" ]]; then
                        if [[ "$v" != "${info[$g]:-}" ]]; then
                            printf "   %-30s <- %-30s   =>  but working on %s\n" "$repo" "$g:$v" "${info[$g]:-}"
                        else
                            printf "   %-30s <- %-30s  (ok)\n" "$repo" "$g:$v"
                        fi
                    fi
                fi
            done | sort
        fi
    }

    echo
    echo "############################################ checking dependencies:"
    forAllProjects check
}
fillLibFolder() {
    local repo="$1"; shift

    (   cd "../$repo"
        if [[ -f pom.xml ]]; then
            printf "   %-30s : " "$repo"
            rm -rf lib
            mvn -q dependency:copy-dependencies -Dmdep.stripVersion=true -DoutputDirectory=lib
            mvn -q dependency:copy-dependencies -Dmdep.stripVersion=true -DoutputDirectory=lib -Dclassifier=javadoc
            mvn -q dependency:copy-dependencies -Dmdep.stripVersion=true -DoutputDirectory=lib -Dclassifier=sources
            if [[ -d lib ]]; then
                printf "%3d jars\n" "$(ls lib | numLines)"
            else
                printf "no libs\n"
            fi
        fi
    )
}
main() {
    . ./info.sh

    echo
    echo "############################################ prep projects (creating if needed):"
    forAllProjects prepProject

    echo
    echo "############################################ project info:"
    echo "   repos-name                     branch           behind  dirty    version"
    echo "   ------------------------------------------------------------------------"
    forAllProjects projectInfo

    versionConsistency

    echo
    echo "############################################ fill lib folders:"
    forAllProjects fillLibFolder
}
main
