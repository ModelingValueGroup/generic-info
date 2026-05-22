#!/usr/bin/env bash
##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
##  (C) Copyright 2018-2026 Modeling Value Group B.V. (http://modelingvalue.org)                                         ~
##                                                                                                                       ~
##  Licensed under the GNU Lesser General Public License v3.0 (the 'License'). You may not use this file except in       ~
##  compliance with the License. You may obtain a copy of the License at: https://choosealicense.com/licenses/lgpl-3.0   ~
##  Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on  ~
##  an 'AS IS' BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the   ~
##  specific language governing permissions and limitations under the License.                                           ~
##                                                                                                                       ~
##  Maintainers:                                                                                                         ~
##      Wim Bast, Tom Brus                                                                                               ~
##                                                                                                                       ~
##  Contributors:                                                                                                        ~
##      Ronald Krijgsheld ✝, Arjan Kok, Carel Bast                                                                       ~
## --------------------------------------------------------------------------------------------------------------------- ~
##  In Memory of Ronald Krijgsheld, 1972 - 2023                                                                          ~
##      Ronald was suddenly and unexpectedly taken from us. He was not only our long-term colleague and team member      ~
##      but also our friend. "He will live on in many of the lines of code you see below."                               ~
##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#set -x
set -euo pipefail

INTENDED_PROJECT_VERSION="6.0.0"
 INTENDED_GRADLE_VERSION="9.5.1"
   INTENDED_JAVA_VERSION="21"
repoSeq=(
    sync-proxy
    mvg-json
    immutable-collections
    dclare
    dclareForJava
    dclareForMPS
    cdm
    cds-runtime
    cdm-generator
)

###########################################################################################################################
if ((BASH_VERSINFO[0] < 4)); then
    OTHER_BASH='/opt/local/bin/bash'
    if [[ -x "$OTHER_BASH" ]] && (( $("$OTHER_BASH" <<<'echo $BASH_VERSION'|sed 's/[.].*//') >= 4 )); then
        echo "INFO: restarting with "$OTHER_BASH" because this bash is too old but that one is new enough."
        exec "$OTHER_BASH" "$0" "$@"
    fi
    echo "ERROR: bash 4.0 or newer is required"
    exit 1
fi

trap "onError" ERR

getJavaProjectMajorVersion() {
    local v=''
    declare -A repo2version version2repo
    for repo in "${repoSeq[@]}"; do
        v="$(egrep '^version_java[ =]' ../$repo/gradle.properties 2>/dev/null | sed 's/.*= *//')"
        if [[ "$v" != "" ]]; then
            repo2version["$repo"]="$v"
            version2repo["$v"]+="$repo"
        fi
    done
    case "${#version2repo[@]}" in
    0)  echo "ERROR: java version can not be determined" 1>&2;;
    1)  echo "${!version2repo[@]}";;
    *) 
        echo "ERROR: java versions do not match accross projects:" 1>&2
        for repo in "${repoSeq[@]}"; do
            printf "   - %-24s: %s\n" "$repo" "${repo2version[$repo]}" 1>&2
        done
    esac
}
getJavaActiveMajorVersion() {
    java -version 2>&1 \
        | awk -F '"' '/version/ {gsub(/[.].*/,"");print $2}'
}
switchToCorrectJavaVersion() {
    local projectVersion="$(getJavaProjectMajorVersion)"
    local  activeVersion="$(getJavaActiveMajorVersion)"
    if [[ "$projectVersion" == "" ]]; then
        exit 89
    fi
    if [[ "$projectVersion" != "$activeVersion" ]]; then
        if [[ -x "/usr/libexec/java_home" ]]; then
            local oldVersion="$activeVersion"
            export JAVA_HOME="$(/usr/libexec/java_home -v $projectVersion)"
            activeVersion="$(getJavaActiveMajorVersion)"
            if [[ "$projectVersion" != "$activeVersion" ]]; then
                echo "ERROR: can not select correct java version (need $projectVersion but active is $activeVersion, JAVA_HOME=$JAVA_HOME) with '/usr/libexec/java_home -v $projectVersion'"
                exit 55
            fi
            echo "INFO: switched java version from $oldVersion to $activeVersion"
        else
            echo "ERROR: incorrect java version active $activeVersion i.s.o. $projectVersion"
        fi
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

             all=012345678dtv
      doOverview=012345678__v
 doGradleVersion=_123456____v
   doJavaVersion=_123456____v
doProjectVersion=_123456____v
          doPull=_12_456_____
         doClean=__234_6_____
       doPublish=___3456_____
          doTest=______6_____
           doLog=_______7____
        doToDate=________8___
         doTimes=__23456_____

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
    d - dev extra's
    t -                  test
    v - check and update versions

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
getProperty() {
    local file="$1"; shift
    local  key="$1"; shift
    touch "$file"
    sed -n "s/^${key} *= *//p" "$file"
}
setProperty() {
    local  file="$1"; shift
    local   key="$1"; shift
    local value="$1"; shift
    touch "$file"
    if grep -q "^${key} *= *" "$file" 2>/dev/null; then
        sed -i.bak -e "s|^\(${key} *= *\).*|\1${value}|" "$file"
        rm -f "$file.bak"
    else
        echo "${key}=${value}" >> "$file"
    fi
}
###########################################################################################################################
cloneFetchAll() {
    echo
    printf "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ clone/fetch\n"
    forAllProjects cloneFetch

	# filter out all projects that could not be cloned (probably private):
    local copy=()
    for repo in "${repoSeq[@]}"; do
        if [[ -d ../$repo/.git ]]; then
            copy+=($repo)
        fi
    done
    repoSeq=(${copy[@]})

    local copy=()
    for repo in "${repoName[@]}"; do
        if [[ -d ../$repo/.git ]]; then
            copy+=($repo)
        fi
    done
    repoName=(${copy[@]})
}
cloneFetch() {
    local repo="$1"; shift
    (
        if [[ ! -d ".git" ]]; then
            printf "# %-30s - cloning...\n" "$repo"
            rm -rf TMP_GIT
            GIT_TERMINAL_PROMPT=0 git clone https://github.com/ModelingValueGroup/$repo.git TMP_GIT >/dev/null 2>&1 || :
            if [[ -d "TMP_GIT/.git" ]]; then
                cp -R TMP_GIT/. .
                rm -rf TMP_GIT
                if [[ "$(listRemoteBranches | tr ' ' '\n' | egrep '^d$')" ]]; then
                    printf "# %-30s - switching to develop branch...\n" "$repo" 1>&2
                    git checkout develop >/dev/null 2>&1 || :
                fi
            fi
        fi
        if [[ ! -d ".git" ]]; then
            printf "# %-30s - not available\n" "$repo" 1>&2
        else
            git fetch --progress --prune --all >/dev/null 2>&1
            printf "# %-30s - done\n" "$repo" 1>&2
        fi
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

    if [[ "$repo" == "" ]] || [[ "$repo" == dclareForMPS ]] || [[ "$repo" == cdm-generator ]]; then
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
    local unrelated="$(showUnrelated)"
    if [[ -n "$unrelated" ]]; then
        echo "$unrelated"
        projectInfoSeparator
    fi
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
                printf "   %-30s NO GIT PROJECT\n" "$repo"
            fi
        fi
    done
}
upgradeProjectAll() {
    printf "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ UPGRADE PROJECT CHECK\n"
    printf "  requested project version = %s\n" "$INTENDED_PROJECT_VERSION"
    numUpgraded=0
    forAllProjects upgradeProject
    if [[ $numUpgraded == 0 ]]; then
        echo "  ok: all projects were already using the requested project version"
    else
        echo "  ok: all projects are now using the requested project version ($numUpgraded upgraded)"
    fi
}
upgradeProject() {
    local propFile="gradle.properties"
    local      key="version"
    if [[ -f "$propFile" ]]; then
        PROJECT_PROJECT_VERSION="$(getProperty "$propFile" "$key")"
        if [[ "$PROJECT_PROJECT_VERSION" != "" && "$PROJECT_PROJECT_VERSION" != $INTENDED_PROJECT_VERSION ]]; then
            echo "  upgrading project: $PROJECT_PROJECT_VERSION => $INTENDED_PROJECT_VERSION: for project $1"
            setProperty "$propFile" "$key" "$INTENDED_PROJECT_VERSION"
            ((numUpgraded++))
        fi
    fi
}
upgradeJavaAll() {
    printf "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ UPGRADE JAVA CHECK\n"
    printf "  requested java    version = %s\n" "$INTENDED_JAVA_VERSION"
    numUpgraded=0
    forAllProjects upgradeJava
    if [[ $numUpgraded == 0 ]]; then
        echo "  ok: all projects were already using the requested java version"
    else
        echo "  ok: all projects are now using the requested java version ($numUpgraded upgraded)"
    fi
}
upgradeJava() {
    local propFile="gradle.properties"
    local      key="version_java"
    if [[ -f "$propFile" ]]; then
        PROJECT_JAVA_VERSION="$(getProperty "$propFile" "$key")"
        if [[ "$PROJECT_JAVA_VERSION" != "" && "$PROJECT_JAVA_VERSION" != $INTENDED_JAVA_VERSION ]]; then
            echo "  upgrading java: $PROJECT_JAVA_VERSION => $INTENDED_JAVA_VERSION: for project $1"
            setProperty "$propFile" "$key" "$INTENDED_JAVA_VERSION"
            ((numUpgraded++))
        fi
    fi
}
upgradeGradleAll() {
    LATEST_GRADLE_VERSION="$(curl --silent https://raw.githubusercontent.com/gradle/gradle/master/released-versions.json | sed -n '1,/finalReleases/d;/version/p' | head -1 | sed 's/.*: "//;s/".*//' || :)"
    printf "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ UPGRADE GRADLE CHECK\n"
    printf "  requested gradle  version = %s\n" "$INTENDED_GRADLE_VERSION"
    printf "  latest    gradle  version = %s\n" "$LATEST_GRADLE_VERSION"
    numUpgraded=0
    forAllProjects upgradeGradle
    if [[ $numUpgraded == 0 ]]; then
        echo "  ok: all projects were already using the requested gradle version"
    else
        echo "  ok: all projects are now using the requested gradle version ($numUpgraded upgraded)"
    fi
}
upgradeGradle() {
    if [[ -f gradlew ]]; then
        local preCrc="$(cat gradlew gradlew.bat gradle/wrapper/gradle-wrapper.jar gradle/wrapper/gradle-wrapper.properties | cksum)"
        ./gradlew wrapper --gradle-version $INTENDED_GRADLE_VERSION
        local pstCrc="$(cat gradlew gradlew.bat gradle/wrapper/gradle-wrapper.jar gradle/wrapper/gradle-wrapper.properties | cksum)"
        if [[ "$preCrc" != "$pstCrc" ]]; then
            ((numUpgraded++)) || :
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
            printf "    _-_-_ (cd %s; ./gradlew clean)\n" "$(pwd)"
            ./gradlew clean || :
            find . -type d -name classes_gen -exec rm -rf {} +
            find . -type d -name source_gen  -exec rm -rf {} +
            find . -type d -name source_gen.caches -exec rm -rf {} +
            rm -rf build
            printf "<<<<=========================== CLEAN  : %s ===========================\n\n\n\n\n" "$(basename "$(pwd)")"
        )&
    done
    wait
    for repo in "${repoSeq[@]}"; do
        (   cd ../$repo
            if [[ -d build ]]; then
                rm -rf build
            fi
            local ign="$(git status --ignored --untracked-files=all \
                | egrep '^	' \
                | fgrep -v '	modified:   ' \
                | fgrep -v '.DS_Store'  \
                | fgrep -v '	.idea'  \
                | fgrep -v '	.mps'  \
                | fgrep -v '	.gradle' \
                || :)"
            if [[ "$ign" != "" ]]; then
                echo "================ ignored in $repo:"
                echo "$ign"
            fi
        )
    done
}
publishAll() {
    printf "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ BUILD\n"
    for repo in "${repoSeq[@]}"; do
        (   cd ../$repo
            printf ">>>>=========================== PUBLISH: %s ===========================\n" "$(basename "$(pwd)")"
            if [[ -f mps_build.xml ]]; then
                printf "    _-_-_ (cd %s; ./gradlew download-MPS)\n" "$(pwd)"
                ./gradlew download-MPS
            fi
            printf "    _-_-_ (cd %s; ./gradlew publish)\n" "$(pwd)"
            ./gradlew publish
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
                echo "   - no plugin file at: $f"
            fi
        done
        local allZip=~/Downloads/"cdm-all-$(date '+%Y%m%d-%H%M').zip"
        zip -j "$allZip" ~/Downloads/DclareForMPS.zip ~/Downloads/CDM.zip ~/Downloads/cdm-generator.zip
        echo "   => $allZip"
        echo
    fi
}
testAll() {
    printf "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ TEST\n"
    for repo in "${repoSeq[@]}"; do
        (   cd ../$repo
            printf ">>>>=========================== TEST   : %s ===========================\n" "$(basename "$(pwd)")"
            ./gradlew --status
            ./gradlew --stop
            ./gradlew --status
            ./gradlew test
            printf "<<<<=========================== TEST   : %s ===========================\n\n\n\n\n" "$(basename "$(pwd)")"
        ) #&
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

    if [[ $whattodo =~ [$doJavaVersion] ]]; then
        upgradeJavaAll
    fi
    if [[ $whattodo =~ [$doGradleVersion] ]]; then
        upgradeGradleAll
    fi
    if [[ $whattodo =~ [$doProjectVersion] ]]; then
        upgradeProjectAll
    fi

    switchToCorrectJavaVersion

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
    if [[ $whattodo =~ [$doTest] ]] || [[ $whattodo == t ]]; then
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
    if [[ $whattodo == d ]]; then
        printf "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ DEV EXTRAS...\n"
        printf "for repo in %s; do (cd \"../\$repo\";echo \"====== \$repo\"); done\n" "${repoSeq[*]}"
    fi
    printf "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ DONE\n"
}

###########################################################################################################################
main "$@"
