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
    cds-runtime
    cdm
    dclareForJava
)

main() {
    updateProjects
    showVersions
    newVersion="$(askForVersion "$1")"
    adjustVersions $newVersion
    showVersions
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
            echo "CLEAN"
        elif [[ "$localHash" == "$baseHash" ]]; then
            echo "NEED_PULL"
        elif [[ "$remoteHash" == "$baseHash" ]]; then
            echo "NEED-PUSH"
        else
            echo "DIVERGED"
        fi
    fi
}
pushAll() {
    local VERSION="$1"
    read -p "are you sure? [yes]: "
    echo
    echo "========================================> commit & push"
    if [[ "$REPLY" != yes ]]; then
        exit 99
    fi
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

exit

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

#set -x
set -euo pipefail

TO_USE_GRADLE_VERSION="7.5.1"
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
LATEST_GRADLE_VERSION="$(curl --silent https://raw.githubusercontent.com/gradle/gradle/master/released-versions.json| jq -r '.finalReleases[0].version')"
numLines() {
    wc -l | sed 's/ //g;s/^0$/ /'
}
sec() {
    date +%s
}
askWhatToDo() {
    REPLY="x"
    while ! [[ "$REPLY" =~ ^[0-6]$ ]]; do
        read -p "$(printf "\n  0 - overview only\n  1 - pull\n  2 - pull clean\n  3 - pull clean build\n  4 - pull       build\n  5 - pull clean build test\n  6 - list recent commits on develop\n\nwhat to do? [0] ")" -n 1 -r
        echo 1>&2
        if [[ "$REPLY" == "" ]]; then
            REPLY=0
        fi
    done
    echo -n "$REPLY"
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
    printf "[%s]='%s' " "$1" "$(listDependabotBranches | tr ' ' '\n' | numLines || :)"
}
listLocalBranches() {
    local raw="$(git branch | sed 's|..||' | sort)"
    local rst="$(egrep -v '^(master|develop)$' <<<"$raw")"

    if [[ "$(fgrep -x develop <<<"$raw")" ]]; then printf "d "; else printf ". "; fi
    if [[ "$(fgrep -x master  <<<"$raw")" ]]; then printf "m "; else printf ". "; fi
    printf "%s " $rst
}
listRemoteBranches() {
    local raw="$(git branch -r | sed '/^  origin[/]HEAD/d;s|..origin/||' | sort)"
    local rst="$(egrep -v '^(master|develop)$' <<<"$raw" | egrep -v '^dependabot/.*')"

    if [[ "$(fgrep -x develop <<<"$raw")" ]]; then printf "d "; else printf ". "; fi
    if [[ "$(fgrep -x master  <<<"$raw")" ]]; then printf "m "; else printf ". "; fi
    printf "%s " $rst
}
listDependabotBranches() {
    local raw="$(git branch -r | sed '/^  origin[/]HEAD/d;s|..origin/||' | sort)"
    local rst="$(egrep -v '^(master|develop)$' <<<"$raw" | egrep '^dependabot/.*' | sed 's|^dependabot/[^/]*/[^/]*/||')"

    if [[ "$rst" != "" ]]; then
        printf "%s " $rst
    fi
}
###########################################################################################################################
cloneFetchAll() {
    echo
    echo "############################################ clone/fetch..."
    forAllProjects cloneFetch
}
cloneFetch() {
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

        echo "# done: $repo" 1>&2
    )&
}
pullAll() {
    echo
    echo "############################################ pull..."
    forAllProjects pull
}
pull() {
    local repo="$1"; shift
    (
        git pull --all --ff-only 2>&1 | egrep "(file changed|insertions|deletions)" | sed "s/^/$repo: /" || :
    )&
}
projectInfoSeparator() {
    : $((INFO_LINE_NUM++))
    if [[ $INFO_LINE_NUM == 5 ]] || [[ "${1:-}" != "" ]]; then
        INFO_LINE_NUM=0
        printf "$INFO_FORMAT +\n" "+" "+" "+" "+" "+" "+" "+" "+" "+" | sed 's/ /-/g;s/^.../  /'
    fi
}
projectInfoAll() {
    INFO_FORMAT="   %-30s %-16s %-10s %-6s %-6s %-6s %-6s %-50s %-50s"
    INFO_LINE_NUM="0"

    declare -A branchOf versionOf aheadOf behindOf dirtyOf dependabot
    eval     "branchOf=( $(forAllProjects getBranch       ) )"
    eval    "versionOf=( $(forAllProjects getVersion      ) )"
    eval      "aheadOf=( $(forAllProjects getNumAhead     ) )"
    eval     "behindOf=( $(forAllProjects getNumBehind    ) )"
    eval      "dirtyOf=( $(forAllProjects getNumDirty     ) )"
    eval   "dependabot=( $(forAllProjects getNumDependabot) )"

    echo
    projectInfoSeparator force
    printf "$INFO_FORMAT\n" "repos-name" "branch" "version" "ahead" "behind" "dirty" "depbot" "local-branches" "remote-branches"
    projectInfoSeparator force
    forAllProjects projectInfo
    projectInfoSeparator force
    showUnrelated
    projectInfoSeparator force
    echo
}
projectInfo() {
    local repo="$1"; shift

    printf "$INFO_FORMAT\n" \
        "$repo" \
        "${branchOf[$repo]:-?}" \
        "${versionOf[$repo]:-?}" \
        "${aheadOf[$repo]:-?}" \
        "${behindOf[$repo]:-?}" \
        "${dirtyOf[$repo]:-?}" \
        "${dependabot[$repo]:-?}" \
        "$(listLocalBranches)" \
        "$(listRemoteBranches)"
    if [[ "${dependabot[$repo]:- }" != " " ]]; then
        printf "                                                                                                                                                 %s\n" $(listDependabotBranches)
    fi
    projectInfoSeparator
}
showUnrelated() {
    for repo in $(cd ..; eval "ls $(printf " | fgrep -v '%s'" ${repoName[@]})"); do
        if [[ -d ../$repo ]]; then
            if [[ -d ../$repo/.git ]]; then
                projectInfo $repo
            else
                echo "$repo: NO GIT PROJECT"
            fi
        fi
    done
}
upgradeGradleAll() {
    printf "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ UPGRADE GRADLE CHECK\n"
    printf "  latest gradle version    = %s\n" "$LATEST_GRADLE_VERSION"
    printf "  requested gradle version = %s\n" "$TO_USE_GRADLE_VERSION"
    forAllProjects upgradeGradle
}
upgradeGradle() {
    if [[ -f gradlew ]]; then
        PROJECT_GRADLE_VERSION="$(./gradlew --version 2>&1 | egrep '^Gradle' | sed 's/.* //' || echo "unknown")"
        if [[ -f gradlew ]] && [[ "$PROJECT_GRADLE_VERSION" != $TO_USE_GRADLE_VERSION ]]; then
            echo "  upgrading gradle: $PROJECT_GRADLE_VERSION => $TO_USE_GRADLE_VERSION: for project $1"
            ./gradlew wrapper --gradle-version $TO_USE_GRADLE_VERSION
        fi
    fi
}
cleanAll() {
    printf "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ CLEAN\n"
    for dir in \
            ~/.m2/repository/snapshots/ \
            ~/.gradle/caches/modules-2/files-2.1/snapshots.org.modelingvalue/ \
        ; do
        if [[ -d "$dir" ]]; then
            local numJars="$(find $dir -name \*.jar ! -name \*sources\* ! -name \*javadoc\* | wc -l | sed 's/ //g')"
            if (( $numJars > 0 )); then
                echo "DELETING '$dir'..."
                rm -rf "$dir"
            fi
        fi
    done
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
                printf "\n\n!!!!!!!!!!!!!!! WARNING: build dir in $repo was not properly cleaned, deleting it now\n"
                rm -rf build
            fi
        )
    done
}
publishAll() {
    printf "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ BUILD\n"
    for repo in "${repoSeq[@]}"; do
        (   cd ../$repo
            printf ">>>>=========================== PUBLISH: %s ===========================\n" "$(basename "$(pwd)")"
            if [[ -f bootstrap.gradle.kts ]]; then
                ./gradlew --build-file bootstrap.gradle.kts
            fi
            ./gradlew publish
            for d in $(find * -name '*.kts' -exec egrep -q "register.*gatherRuntimeJars" {} \; -print | sed 's|/[^/]*$||'); do
                printf "    =========================== GATHER: %s ==========================\n" "$d:gatherRuntimeJars"
                ./gradlew ${d/*.kts/}:gatherRuntimeJars
            done
            printf "<<<<=========================== PUBLISH: %s ===========================\n" "$(basename "$(pwd)")"
        )
    done
    if [[ "$USER" == tom ]]; then
        echo
        echo "to copy the plugins to your downloads folder:"
        echo "     cp ../cdm/build/artifacts/CDM/CDM.zip ../dclareForMPS/build/artifacts/DclareForMPS/DclareForMPS.zip ~/Downloads"
        echo
    fi
}
testAll() {
    printf "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ TEST\n"
    for repo in "${repoSeq[@]}"; do
        (   cd ../$repo
            printf ">>>>=========================== TEST   : %s ===========================\n" "$(basename "$(pwd)")"
            ./gradlew test
            printf "<<<<=========================== TEST   : %s ===========================\n\n\n\n\n" "$(basename "$(pwd)")"
        )&
    done
    wait
    ls -l ../cdm/build/artifacts/CDM/CDM.zip ../dclareForMPS/build/artifacts/DclareForMPS/DclareForMPS.zip
}
logAll() {
    printf "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ LOG\n"
    rm -f /tmp/generic-info-log-*
    for repo in "${repoSeq[@]}"; do
        (   cd ../$repo
            logOne $repo | fgrep -v '|automation|'> /tmp/generic-info-log-$repo
        )&
    done
    wait
    cat /tmp/generic-info-log-* | sort | tr '|\n' '\0\0' | xargs -0 -n 6 printf "%.s%s %s - %-25s %-25s %s\n"
    rm -f /tmp/generic-info-log-*
}
logOne() {
    local repo="$1"; shift

    git log origin/develop --since="2 weeks ago" --first-parent --no-merges --date=format:"%s|%Y-%m-%d|%H:%M:%S" --pretty=tformat:"%cd|$repo|%an|%s"
}
###########################################################################################################################
main() {
    whattodo="$(askWhatToDo)"

    . ./info.sh
    declare -A workflowOf mainBranchOf
    eval     "repoName=( $(printf "%s%.s%.s\n"  "${repoList[@]}" | sort) )"
    eval   "workflowOf=( $(printf "[%s]=%s%.s " "${repoList[@]}") )"
    eval "mainBranchOf=( $(printf "[%s]=%.s%s " "${repoList[@]}") )"

    cloneFetchAll
    if [[ $whattodo =~ [12345] ]]; then
        pullAll
    fi

    projectInfoAll

    upgradeGradleAll

    if [[ $whattodo =~ [2345] ]]; then
        local T0="$(sec)"
        if [[ $whattodo =~ [235] ]]; then
            local c0="$(sec)"
            cleanAll
            local c1="$(sec)"
        fi
        if [[ $whattodo =~ [345] ]]; then
            local p0="$(sec)"
            publishAll
            local p1="$(sec)"
        fi
        if [[ $whattodo =~ [5] ]]; then
            local t0="$(sec)"
            testAll
            local t1="$(sec)"
        fi
        local T1="$(sec)"

        if [[ $whattodo =~ [2345] ]]; then
            printf "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@\n"
            if [[ $whattodo =~ [235] ]]; then
                printf "  clean   time: %4d sec\n" "$((c1-c0))"
            fi
            if [[ $whattodo =~ [345] ]]; then
                printf "  publish time: %4d sec\n" "$((p1-p0))"
            fi
            if [[ $whattodo =~ [5] ]]; then
                printf "  test    time: %4d sec\n" "$((t1-t0))"
            fi
            printf "  TOTAL   time: %4d sec\n" "$((T1-T0))"
            printf "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ DONE\n"
        fi
    fi
    if [[ $whattodo =~ [6] ]]; then
        logAll
    fi
}

###########################################################################################################################
main "$@"
