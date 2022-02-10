#!/usr/bin/env bash
##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
## (C) Copyright 2018-2022 Modeling Value Group B.V. (http://modelingvalue.org)                                        ~
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
USE_GRADLE_VERSION=7.4

###########################################################################################################################
numLines() {
    wc -l | sed 's/ //g;s/^0$/ /'
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
cloneFetchPullAll() {
    echo
    echo "############################################ clone/fetch/pull..."
    forAllProjects cloneFetchPull
}
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
INFO_FORMAT="   %-30s %-16s %-10s %-6s %-6s %-6s %-6s %-50s %-50s"
INFO_LINE_NUM="0"
projectInfoSeparator() {
    : $((INFO_LINE_NUM++))
    if [[ $INFO_LINE_NUM == 5 ]] || [[ "${1:-}" != "" ]]; then
        INFO_LINE_NUM=0
        printf "$INFO_FORMAT +\n" "+" "+" "+" "+" "+" "+" "+" "+" "+" | sed 's/ /-/g;s/^.../  /'
    fi
}
projectInfoAll() {
    echo
    projectInfoSeparator force
    printf "$INFO_FORMAT\n" "repos-name" "branch" "version" "ahead" "behind" "dirty" "depbot" "local-branches" "remote-branches"
    projectInfoSeparator force
    forAllProjects projectInfo
    projectInfoSeparator
}
projectInfo() {
    local repo="$1"; shift

    printf "$INFO_FORMAT\n" \
        "$repo" \
        "${branchOf[$repo]}" \
        "${versionOf[$repo]}" \
        "${aheadOf[$repo]}" \
        "${behindOf[$repo]}" \
        "${dirtyOf[$repo]}" \
        "${dependabot[$repo]}" \
        "$(listLocalBranches)" \
        "$(listRemoteBranches)"
    projectInfoSeparator
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
upgradeGradle() {
    if [[ -f gradlew ]]; then
        CUR_GRADLE_VERSION="$(./gradlew --version | egrep '^Gradle' | sed 's/.* //')"
        if [[ -f gradlew ]] && [[ "$CUR_GRADLE_VERSION" != $USE_GRADLE_VERSION ]]; then
            echo "=============================== UPGRADE GRADLE: $CUR_GRADLE_VERSION => $USE_GRADLE_VERSION: $1 ========================"
            ./gradlew wrapper --gradle-version $USE_GRADLE_VERSION
        fi
    fi
}
upgradeGradleAll() {
    forAllProjects upgradeGradle
}
clearSnapshots() {
    for dir in \
            ~/.m2/repository/snapshots/ \
            ~/.gradle/caches/modules-2/files-2.1/snapshots.org.modelingvalue/ \
        ; do
        if [[ -d "$dir" ]]; then
            local numJars="$(find $dir -name \*.jar ! -name \*sources\* ! -name \*javadoc\* | wc -l | sed 's/ //g')"
            if (( $numJars > 0 )) && ask "do you want to remove $numJars published snapshot jars from the $dir"; then
                echo "DELETING '$dir'..."
                rm -rf "$dir"
            fi
        fi
    done
}
cleanPublishTestAll() {
    date
    printf "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@\n"
    if ask "do you want to clean"; then
        for repo in "${repoSeq[@]}"; do
            (   cd ../$repo
                printf ">>>>=========================== CLEAN  : %s ===========================\n" "$(basename "$(pwd)")"
                ./gradlew clean
                find . -type d -name classes_gen -exec rm -rf {} +
                find . -type d -name source_gen  -exec rm -rf {} +
                find . -type d -name source_gen.caches -exec rm -rf {} +
                printf "<<<<=========================== CLEAN  : %s ===========================\n\n\n\n\n" "$(basename "$(pwd)")"
            )&
        done
        wait
        for repo in "${repoSeq[@]}"; do
            (   cd ../$repo
                if [[ -d build ]]; then
                    printf "\n\n!!!!!!!!!!!!!!! WARNING: build dir in $repo was not properly cleaned, deleting it now"
                    rm -rf build
                fi
            )
        done
    fi
    if ask "do you want to publish and gather"; then
        printf "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@\n"
        for repo in "${repoSeq[@]}"; do
            (   cd ../$repo
                printf ">>>>=========================== PUBLISH: %s ===========================\n" "$(basename "$(pwd)")"
                ./gradlew publish
                for d in $(find * -name '*.kts' -exec egrep -q "register.*gatherRuntimeJars" {} \; -print | sed 's|/[^/]*$||'); do
                    printf "    =========================== GATHER: %s ==========================\n" "$d:gatherRuntimeJars"
                    ./gradlew ${d/*.kts/}:gatherRuntimeJars
                done
                printf "<<<<=========================== PUBLISH: %s ===========================\n" "$(basename "$(pwd)")"
            )
        done
        wait
    fi
    if ask "do you want to test"; then
        printf "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@\n"
        for repo in "${repoSeq[@]}"; do
            (   cd ../$repo
                printf ">>>>=========================== TEST   : %s ===========================\n" "$(basename "$(pwd)")"
                ./gradlew test
                printf "<<<<=========================== TEST   : %s ===========================\n\n\n\n\n" "$(basename "$(pwd)")"
            )&
        done
        wait
        ls -l ../cdm/build/artifacts/CDM/CDM.zip ../dclareForMPS/build/artifacts/DclareForMPS/DclareForMPS.zip
    fi
    printf "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@\n"
    date
}
###########################################################################################################################
main() {
    . ./info.sh
    declare -A workflowOf mainBranchOf
    eval     "repoName=( $(printf "%s%.s%.s\n"  "${repoList[@]}" | sort) )"
    eval   "workflowOf=( $(printf "[%s]=%s%.s " "${repoList[@]}") )"
    eval "mainBranchOf=( $(printf "[%s]=%.s%s " "${repoList[@]}") )"

    cloneFetchPullAll

    declare -A branchOf versionOf aheadOf behindOf dirtyOf dependabot
    eval     "branchOf=( $(forAllProjects getBranch       ) )"
    eval    "versionOf=( $(forAllProjects getVersion      ) )"
    eval      "aheadOf=( $(forAllProjects getNumAhead     ) )"
    eval     "behindOf=( $(forAllProjects getNumBehind    ) )"
    eval      "dirtyOf=( $(forAllProjects getNumDirty     ) )"
    eval   "dependabot=( $(forAllProjects getNumDependabot) )"

    projectInfoAll
    showUnrelated
    upgradeGradleAll
    clearSnapshots
    cleanPublishTestAll
}

###########################################################################################################################
main "$@"

echo "cp ../cdm/build/artifacts/CDM/CDM.zip ../dclareForMPS/build/artifacts/DclareForMPS/DclareForMPS.zip ~/Downloads"
