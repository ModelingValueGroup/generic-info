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
#set -x

allRepoNames() {
    printf "%s%.s%.s\n" "${repoList[@]}" | sort
}
numLines() {
    wc -l | sed 's/ //g;s/^0$/./'
}
forAllProjects() {
    local fun="$1"; shift

    for repo in "${repoName[@]}"; do
        mkdir -p ../$repo
        ( cd "../$repo"; "$fun" "$repo" )
    done
    wait
}
getBranch() {
    printf "[%s]='%s' " "$1" "$(git status | egrep "^On branch " | sed 's/On branch //')"
}
getVersion() {
    printf "[%s]='%s' " "$1" "$( if [[ ! -f gradle.properties ]]; then echo ''; else egrep '^version[ =]' gradle.properties | sed 's/.*= *//'; fi )"
}
getNumAhead() {
    printf "[%s]='%s' " "$1" "$(git cherry | numLines)"
}
getNumBehind() {
    printf "[%s]='%s' " "$1" "$(git log HEAD..origin/${branchOf[$1]} --oneline | numLines)"
}
getNumDirty() {
    printf "[%s]='%s' " "$1" "$(git status | egrep '^\t(new file|modified):   ' | numLines || :)"
}
getNumDependabot() {
    printf "[%s]='%s' " "$1" "$(git branch -r | egrep "..origin/dependabot/" | numLines || :)"
}
fetch_pull() {
    local repo="$1"; shift

    (   git fetch origin
        git pull --ff-only
    ) >/dev/null 2>&1 &
}
prepProject() {
    local repo="$1"; shift

    printf "   %-s\n" "$repo"
    (
        if [[ ! -d ".git" ]]; then
            echo "cloning..."
            git clone "https://github.com/ModelingValueGroup/$repo.git" TMP_GIT 2>&1 >/dev/null
            cp -R TMP_GIT/. .
            rmdir TMP_GIT
        fi
        for br in $(git branch | sed 's/..//' | sort); do
            echo "    - $br"
        done
        for br in $(git branch -r | sed '/^  origin[/]HEAD/d;s|..origin/||' | sort); do
            echo "    = $br"
        done
    ) 2>&1 | sed 's/^/                                    # /' # 2>&1 >/dev/null
}
projectInfo() {
    local repo="$1"; shift

    printf "   %-30s %-16s %-10s %6s %6s %6s %6s\n" "$repo" "${branchOf[$repo]}" "${versionOf[$repo]}" "${aheadOf[$repo]}" "${behindOf[$repo]}" "${dirtyOf[$repo]}" "${dependabot[$repo]}"
}
showUnrelated() {
    first=false
    for repo in $(cd ..; eval "ls $(printf " | fgrep -v '%s'" ${repoName[@]})"); do
        if [[ -d ../$repo ]]; then
            if [[ -d ../$repo/.git ]]; then
                if [[ $first == false ]]; then
                    first=true
                    echo
                    echo "############################################ unrelated projects:"
                fi
                projectInfo $repo
            else
                echo "$repo: NO GIT PROJECT"
            fi
        fi
    done
}
main() {
    . ./info.sh
    declare -A workflowOf mainBranchOf branchOf versionOf aheadOf behindOf dirtyOf dependabot
    eval     "repoName=( $(printf "%s%.s%.s\n"  "${repoList[@]}" | sort) )"
    eval   "workflowOf=( $(printf "[%s]=%s%.s " "${repoList[@]}") )"
    eval "mainBranchOf=( $(printf "[%s]=%.s%s " "${repoList[@]}") )"
    eval     "branchOf=( $(forAllProjects getBranch       ) )"
    eval    "versionOf=( $(forAllProjects getVersion      ) )"
    eval      "aheadOf=( $(forAllProjects getNumAhead     ) )"
    eval     "behindOf=( $(forAllProjects getNumBehind    ) )"
    eval      "dirtyOf=( $(forAllProjects getNumDirty     ) )"
    eval   "dependabot=( $(forAllProjects getNumDependabot) )"

    echo
    echo "############################################ fetch/pull..."
    forAllProjects fetch_pull

    echo
    echo "############################################ prep projects:"
    forAllProjects prepProject

    echo
    echo "############################################ project info:"
    printf "   %-30s %-16s %-10s %-6s %-6s %-6s %-6s +\n" "+" "+" "+" "+" "+" "+" "+" | sed 's/ /-/g;s/^.../  /'
    printf "   %-30s %-16s %-10s %6s %6s %6s %6s\n" "repos-name" "branch" "version" "ahead" "behind" "dirty" "depbot"
    printf "   %-30s %-16s %-10s %-6s %-6s %-6s %-6s +\n" "+" "+" "+" "+" "+" "+" "+" | sed 's/ /-/g;s/^.../  /'
    forAllProjects projectInfo
    printf "   %-30s %-16s %-10s %-6s %-6s %-6s %-6s +\n" "+" "+" "+" "+" "+" "+" "+" | sed 's/ /-/g;s/^.../  /'

    showUnrelated
}


main
