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

repoSeq=(
    sync-proxy
    mvg-json
    immutable-collections
    dclare
    dclareForJava
    dclareForMPS
    cds-runtime
    cdm
)

###########################################################################################################################
numLines() {
    wc -l | sed 's/ //g;s/^0$/./'
}
ask() {
    local msg="$1"; shift

    echo
    REPLY="x"
    while ! [[ "$REPLY" =~ ^[YyNn]$ || "$REPLY" == "" ]]; do
        read -p "$msg? (N/y) " -n 1 -r
        echo
    done
    [[ "$REPLY" =~ ^[Yy]$ ]]
}
forAllProjects() {
    local fun="$1"; shift
    local here="$PWD"

    for repo in "${repoName[@]}"; do
        mkdir -p ../$repo
        cd "../$repo"
        "$fun" "$repo"
        cd "$here"
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
    printf "[%s]='%s' " "$1" "$(listRemoteBranches | tr ' ' '\n' | egrep "^dependabot/" | numLines || :)"
}
listLocalBranches() {
    local raw="$(git branch | sed 's|..||' | sort)"
    local rst="$(egrep -v '^(master|develop)$' <<<"$raw")"

    if [[ "$(fgrep -x develop <<<"$raw")" ]]; then printf "develop "; fi
    if [[ "$(fgrep -x master  <<<"$raw")" ]]; then printf "master " ; fi
    printf "%s " $rst
}
listRemoteBranches() {
    local raw="$(git branch -r | sed '/^  origin[/]HEAD/d;s|..origin/||' | sort)"
    local rst="$(egrep -v '^(master|develop)$' <<<"$raw")"

    if [[ "$(fgrep -x develop <<<"$raw")" ]]; then printf "develop "; fi
    if [[ "$(fgrep -x master  <<<"$raw")" ]]; then printf "master " ; fi
    printf "%s " $rst
}
###########################################################################################################################
cloneFetchPull() {
    local repo="$1"; shift
    (
        if [[ ! -d ".git" ]]; then
            printf "cloning %s..." "$repo"
            (
                git clone "https://github.com/ModelingValueGroup/$repo.git" TMP_GIT 2>&1 >/dev/null
                cp -R TMP_GIT/. .
                rm -rf TMP_GIT
                if [[ "$(listRemoteBranches | tr ' ' '\n' | egrep '^develop$')" ]]; then
                    git checkout develop
                fi
            ) 2>&1 | sed 's/^/                                    # /' # 2>&1 >/dev/null
        fi
        git fetch --progress --prune --all >/dev/null 2>&1
        git pull --all --ff-only 2>&1 | egrep "(file changed|insertions|deletions)" | sed "s/^/$repo: /" || :

        echo "# done: $repo" 1>&2
    )&
}
projectInfo() {
    local repo="$1"; shift

    printf "   %-30s %-16s %-10s %6s %6s %6s %6s %-50s %-50s\n" \
        "$repo" \
        "${branchOf[$repo]}" \
        "${versionOf[$repo]}" \
        "${aheadOf[$repo]}" \
        "${behindOf[$repo]}" \
        "${dirtyOf[$repo]}" \
        "${dependabot[$repo]}" \
        "$(listLocalBranches)" \
        "$(listRemoteBranches)"
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
clearSnapshotsFromMaven() {
    local numJars="$(find ~/.m2/repository/snapshots/ -name \*.jar ! -name \*sources\* ! -name \*javadoc\* | wc -l | sed 's/ //g')"
    if (( $numJars > 0 )) && ask "do you want to remove all published snapshots ($numJars) from the maven repo"; then
        local d=~/.m2/repository/snapshots/
        echo "DELETING '$d'..."
        rm -rf "$d"
    fi
}
cleanPublishTest() {
    if ask "do you want to clean - publish - test"; then
        date
        for repo in "${repoSeq[@]}"; do
            (   cd ../$repo
                printf "\n=========================== CLEAN  : %s ===========================\n" "$(basename "$(pwd)")"
                ./gradlew clean
            )
        done
        for repo in "${repoSeq[@]}"; do
            (   cd ../$repo
                printf "\n=========================== PUBLISH: %s ===========================\n" "$(basename "$(pwd)")"
                ./gradlew publish
            )
        done
        for repo in "${repoSeq[@]}"; do
            (   cd ../$repo
                printf "\n=========================== TEST   : %s ===========================\n" "$(basename "$(pwd)")"
                ./gradlew test
            )
        done
        date
    fi
}
###########################################################################################################################
main() {
    . ./info.sh
    declare -A workflowOf mainBranchOf
    eval     "repoName=( $(printf "%s%.s%.s\n"  "${repoList[@]}" | sort) )"
    eval   "workflowOf=( $(printf "[%s]=%s%.s " "${repoList[@]}") )"
    eval "mainBranchOf=( $(printf "[%s]=%.s%s " "${repoList[@]}") )"

    echo
    echo "############################################ clone/fetch/pull..."
    forAllProjects cloneFetchPull

    echo
    printf "   %-30s %-16s %-10s %-6s %-6s %-6s %-6s %-50s %-50s +\n" "+" "+" "+" "+" "+" "+" "+" "+" "+" | sed 's/ /-/g;s/^.../  /'
    printf "   %-30s %-16s %-10s %6s %6s %6s %6s %-50s %-50s\n" "repos-name" "branch" "version" "ahead" "behind" "dirty" "depbot" "local-branches" "remote-branches"
    printf "   %-30s %-16s %-10s %-6s %-6s %-6s %-6s %-50s %-50s +\n" "+" "+" "+" "+" "+" "+" "+" "+" "+" | sed 's/ /-/g;s/^.../  /'
    declare -A branchOf versionOf aheadOf behindOf dirtyOf dependabot
    eval     "branchOf=( $(forAllProjects getBranch       ) )"
    eval    "versionOf=( $(forAllProjects getVersion      ) )"
    eval      "aheadOf=( $(forAllProjects getNumAhead     ) )"
    eval     "behindOf=( $(forAllProjects getNumBehind    ) )"
    eval      "dirtyOf=( $(forAllProjects getNumDirty     ) )"
    eval   "dependabot=( $(forAllProjects getNumDependabot) )"

    forAllProjects projectInfo
    printf "   %-30s %-16s %-10s %-6s %-6s %-6s %-6s %-50s %-50s +\n" "+" "+" "+" "+" "+" "+" "+" "+" "+" | sed 's/ /-/g;s/^.../  /'

    showUnrelated
    clearSnapshotsFromMaven
    cleanPublishTest
}

###########################################################################################################################
main "$@"
