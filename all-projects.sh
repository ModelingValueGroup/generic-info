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

INTENDED_GRADLE_VERSION="7.6"
INTENDED_JAVA_MAJOR_VERSION="11"
repoSeq=(
    sync-proxy
    mvg-json
    immutable-collections
    dclare
    dclareForJava
    dclareForMPS
    cds-runtime
    cdm
    cdm-generator
)

###########################################################################################################################
LATEST_GRADLE_VERSION="$(curl --silent https://raw.githubusercontent.com/gradle/gradle/master/released-versions.json| jq -r '.finalReleases[0].version'|| :)"
JAVA_MAJOR_VERSION="$(java  -version 2>&1 | awk -F '"' '/version/ {gsub(/[.].*/,"");print $2}')"
trap "onError" ERR
checkIntendedJavaVersion() {
    if [[ "$INTENDED_JAVA_MAJOR_VERSION" != "$JAVA_MAJOR_VERSION" ]]; then
        if [[ -x "/usr/libexec/java_home" ]]; then
            local oldVersion="$JAVA_MAJOR_VERSION"
            export JAVA_HOME=`/usr/libexec/java_home -v $INTENDED_JAVA_MAJOR_VERSION`
            JAVA_MAJOR_VERSION="$(java  -version 2>&1 | awk -F '"' '/version/ {gsub(/[.].*/,"");print $2}')"
            if [[ "$INTENDED_JAVA_MAJOR_VERSION" != "$JAVA_MAJOR_VERSION" ]]; then
                echo "ERROR: can not select correct java version ($INTENDED_JAVA_MAJOR_VERSION) with /usr/libexec/java_home"
                exit 55
            fi
            echo "INFO: switched java version from $oldVersion to $JAVA_MAJOR_VERSION"
        else
            echo "ERROR: incorrect java version active $JAVA_MAJOR_VERSION i.s.o. $INTENDED_JAVA_MAJOR_VERSION"
        fi
    else
        echo "INFO: correct java version installed: $INTENDED_JAVA_MAJOR_VERSION"
    fi
}
playSound() {
    afplay "done.wav" & sleep 0.3
    afplay "done.wav" & sleep 0.3
    afplay "done.wav" & sleep 0.3
}
onError() {
    playSound
}
numLines() {
    wc -l | sed 's/ //g;s/^0$/ /'
}
sec() {
    date +%s
}

        all=012345678
 doOverview=012345678
   doGradle=_123456__
     doPull=_12_456__
    doClean=__234_6__
  doPublish=___3456__
     doTest=______6__
      doLog=_______7_
   doToDate=________8
    doTimes=__23456__

askWhatToDo() {
    REPLY="x"
    while ! [[ "$REPLY" =~ ^[$all]$ ]]; do
        cat <<EOF >&2

    0 - overview only
    1 - pull
    2 - pull clean
    3 -      clean build
    4 - pull clean build
    5 - pull       build
    6 - pull clean build test
    7 - list recent commits on develop
    8 - move to a date, after reset & develop [CAUTION will trash any changes in workdir]

EOF
        read -p "what to do? [0] " -n 1 -r
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
    printf "[%s]='%s' " "$1" "$(git rev-parse --abbrev-ref HEAD)"
}
getVersion() {
    printf "[%s]='%s' " "$1" "$(if [[ ! -f gradle.properties ]]; then echo ''; else egrep '^version[ =]' gradle.properties | sed 's/.*= *//'; fi)"
}
getNumAhead() {
    printf "[%s]='%s' " "$1" "$(if ! git cherry &>/dev/null; then echo "-"; else git cherry | numLines; fi)"
}
getNumBehind() {
    printf "[%s]='%s' " "$1" "$(if ! git log HEAD..origin/${branchOf[$1]} --oneline &>/dev/null; then echo "-"; else git log HEAD..origin/${branchOf[$1]} --oneline | numLines; fi)"
}
getNumDirty() {
    printf "[%s]='%s' " "$1" "$(git status --porcelain | numLines || :)"
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
            printf "cloning %s...\n" "$repo"
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
    local repo="${1:-}"

    if [[ "$repo" == "" ]] || [[ "$repo" == cdm-generator ]] || [[ "$repo" == ex-Sudoku ]]; then
        printf "$INFO_FORMAT +\n" "+" "+" "+" "+" "+" "+" "+" "+" "+" | sed 's/ /-/g;s/^.../  /'
    fi
}
projectInfoAll() {
    INFO_FORMAT="   %-30s %-16s %-10s %-6s %-6s %-6s %-6s %-50s %-50s"

    declare -A branchOf versionOf aheadOf behindOf dirtyOf dependabot
    eval     "branchOf=( $(forAllProjects getBranch       ) )"
    eval    "versionOf=( $(forAllProjects getVersion      ) )"
    eval      "aheadOf=( $(forAllProjects getNumAhead     ) )"
    eval     "behindOf=( $(forAllProjects getNumBehind    ) )"
    eval      "dirtyOf=( $(forAllProjects getNumDirty     ) )"
    eval   "dependabot=( $(forAllProjects getNumDependabot) )"

    echo
    projectInfoSeparator
    printf "$INFO_FORMAT\n" "repos-name" "branch" "version" "ahead" "behind" "dirty" "depbot" "local-branches" "remote-branches"
    projectInfoSeparator
    forAllProjects projectInfo
    projectInfoSeparator
    showUnrelated
    projectInfoSeparator
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
    projectInfoSeparator "$repo"
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
    printf "  latest    gradle version = %s\n" "$LATEST_GRADLE_VERSION"
    printf "  requested gradle version = %s\n" "$INTENDED_GRADLE_VERSION"
    anyUpgraded=0
    forAllProjects upgradeGradle
    if [[ $anyUpgraded == 0 ]]; then
        echo "  ok: all projects use the requested gradle version"
    fi
}
upgradeGradle() {
    if [[ -f gradlew ]]; then
        PROJECT_GRADLE_VERSION="$(./gradlew --version 2>&1 | egrep '^Gradle' | sed 's/.* //' || echo "unknown")"
        if [[ "$PROJECT_GRADLE_VERSION" != $INTENDED_GRADLE_VERSION ]]; then
            echo "  upgrading gradle: $PROJECT_GRADLE_VERSION => $INTENDED_GRADLE_VERSION: for project $1"
            ./gradlew wrapper --gradle-version $INTENDED_GRADLE_VERSION
            anyUpgraded=1
        #elif [[ $LATEST_GRADLE_VERSION != $INTENDED_GRADLE_VERSION ]]; then
            #echo "  scanning gradle for upgrade: $PROJECT_GRADLE_VERSION => $LATEST_GRADLE_VERSION: for project $1"
            #./gradlew help --scan
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
    if [[ -d ~/Downloads ]]; then
        echo
        echo "INFO: copying the plugins to your ~/Downloads folder:"
        for f in \
                "../dclareForMPS/build/artifacts/DclareForMPS/DclareForMPS.zip" \
                "../cdm/build/artifacts/CDM/CDM.zip" \
                "../cdm-generator//build/artifacts/cdm-generator/cdm-generator.zip" \
                ; do
            if [[ -f "$f" ]]; then
                cp "$f" ~/Downloads
                echo "   - $(basename "$f")"
            else
                echo "   - ERROR: missing plugin file: $f"
            fi
        done
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
toDateAll() {
    local unclean=()
    for repo in "${repoSeq[@]}"; do
        local output=$(cd ../$repo; git status --porcelain)
        if ! [[ -z "$output" ]]; then
            unclean+=($repo)
        fi
    done
    if [[ ${#unclean[@]} != 0 ]]; then
        printf "PROBLEM: the following repos are dirty (clean them first):\n"
        printf " - %s\n" "${unclean[@]}"
    else
        REPLY=
        while ! [[ $REPLY =~ 20[0-9][0-9]-[0-9][0-9]-[0-9][0-9]\ [0-9][0-9]:[0-9][0-9] ]]; do
            read -p "to what date are we going to time-travel: " -r
            echo 1>&2
        done
        theDate="$REPLY"

        for repo in "${repoSeq[@]}"; do
            (   cd ../$repo
                printf "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ moving %-24s to %s\n" "$repo" "$theDate"
                git checkout develop
                echo "===================="
                git checkout $(git rev-list --before "$theDate" --max-count=1 develop)
            )
        done
        wait
    fi
}
###########################################################################################################################
main() {
    checkIntendedJavaVersion

    whattodo="$(askWhatToDo)"

    . ./info.sh
    declare -A workflowOf mainBranchOf
    pattern="($(printf "%s|" "${repoSeq[@]}" | sed 's/|$//' | tr -d '\n'))"
    eval     "repoName=( "${repoSeq[@]}" $(printf "%s%.s%.s\n"  "${repoList[@]}" | egrep -v "$pattern" | sort) )"
    eval   "workflowOf=( $(printf "[%s]=%s%.s " "${repoList[@]}") )"
    eval "mainBranchOf=( $(printf "[%s]=%.s%s " "${repoList[@]}") )"

    cloneFetchAll

    if [[ $whattodo =~ [$doToDate] ]]; then
        toDateAll
    fi

    if [[ $whattodo =~ [$doPull] ]]; then
        pullAll
    fi

    if [[ $whattodo =~ [$doOverview] ]]; then
        projectInfoAll
    fi

    if [[ $whattodo =~ [$doGradle] ]]; then
        upgradeGradleAll
    fi

    local T0="$(sec)"
    if [[ $whattodo =~ [$doClean] ]]; then
        local c0="$(sec)"
        cleanAll
        local c1="$(sec)"
    fi
    if [[ $whattodo =~ [$doPublish] ]]; then
        local p0="$(sec)"
        publishAll
        local p1="$(sec)"
    fi
    if [[ $whattodo =~ [$doTest] ]]; then
        local t0="$(sec)"
        testAll
        local t1="$(sec)"
    fi
    local T1="$(sec)"

    if [[ $whattodo =~ [$doTimes] ]]; then
        printf "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ TIMING\n"
        if [[ $whattodo =~ [$doClean] ]]; then
            printf "  clean   time: %4d sec\n" "$((c1-c0))"
        fi
        if [[ $whattodo =~ [$doPublish] ]]; then
            printf "  publish time: %4d sec\n" "$((p1-p0))"
        fi
        if [[ $whattodo =~ [$doTest] ]]; then
            printf "  test    time: %4d sec\n" "$((t1-t0))"
        fi
        printf "  TOTAL   time: %4d sec\n" "$((T1-T0))"
    fi
    if [[ $whattodo =~ [$doLog] ]]; then
        printf "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ SCANNING GIT LOGS...\n"
        logAll
    fi
    printf "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ DONE\n"
}

###########################################################################################################################
main "$@"
