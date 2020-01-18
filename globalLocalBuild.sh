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
cloneProject() {
    local repo="$1"; shift

    if [[ ! -d "../$repo" ]]; then
        echo "###### clone $repo..."
        git clone "https://github.com/ModelingValueGroup/$repo.git" ../$repo >/dev/null
    fi
}
projectInfo() {
    local repo="$1"; shift

    (   cd ../$repo
        local branch="$(git status| egrep "^On branch " | sed 's/On branch //')"
        local    num="$(git status | egrep '^\t(new file|modified):   ' | wc -l | sed 's/ //g;s/^0$/-/')"
        local version
        if [[ -f "../$repo/project.sh" ]]; then
            . "../$repo/project.sh"
            read a g version e f <<< "${artifacts[0]}"
        else
            version="-"
        fi
        printf "   %-30s %-16s %4s %10s\n" "$repo" "$branch" "$num" "$version"
    )
}
isAllUptodate() {
    isUptodate "jdclare/org.modelingvalue.collections/src"            "immutable-collections/immutable-collections/src" | fgrep -v 'StructGenerator.java'
    isUptodate "jdclare/org.modelingvalue.collections.test/src"       "immutable-collections/immutable-collections/tst"

    isUptodate "jdclare/org.modelingvalue.dclare/src"                 "dclare/dclare/src"
    isUptodate "jdclare/org.modelingvalue.dclare.test/src"            "dclare/dclare/tst"

    isUptodate "jdclare/org.modelingvalue.jdclare/src"                "dclareForJava/dclareForJava/src"
    isUptodate "jdclare/org.modelingvalue.jdclare.test/src"           "dclareForJava/dclareForJava/tst"

    isUptodate "jdclare/org.modelingvalue.jdclare.examples/src"       "dclareForJava/examples/tst"                      | egrep -v ' (workbench|swing)$'
    isUptodate "jdclare/org.modelingvalue.jdclare.swing.examples/src" "dclareForJava/examples/tst"                      | egrep -v ' (examples|workbench)$'
    isUptodate "jdclare/org.modelingvalue.jdclare.workbench/src"      "dclareForJava/examples/tst"                      | egrep -v ' (examples|swing)$'

    isUptodate "jdclare/org.modelingvalue.jdclare.swing/src"          "dclareForJava/ext/src"                           | egrep -v ' syntax$'
    isUptodate "jdclare/org.modelingvalue.jdclare.syntax/src"         "dclareForJava/ext/src"                           | egrep -v ' swing$'
    isUptodate "jdclare/org.modelingvalue.jdclare.syntax.test/src"    "dclareForJava/ext/tst"
}
isUptodate() {
    local src="$1"; shift
    local trg="$1"; shift

    if ! diff_ "../$src" "../$trg" >/dev/null; then
        echo "#### $trg"
        diff_ "../$src" "../$trg" | sed 's/Files/   cp/;s/ and / /;s/ differ//' || :
    fi
#    echo "=========== $src"
#    f="$(find ../$src -name \*.java | head -1 | sed 's|.*/||')"
#    find .. ! -path \*/ARCHIVE/\* -name "$f" ! -path "../$src/*"
}
diff_() {
    diff -rq --ignore-matching-lines='import.*' --ignore-matching-lines='//.*~' --ignore-all-space --ignore-tab-expansion --ignore-blank-lines "$@"
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

    echo "#### current versions:"
    for r in "${!info[@]}"; do
        if [[ "${info[$r]}" != '-' ]]; then
            printf "       %-30s = %s\n" "$r" "${info[$r]}"
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
                            printf "       %-30s <- %-30s   =>  but working on %s\n" "$repo" "$g:$v" "${info[$g]:-}"
                        else
                            printf "       %-30s <- %-30s  (ok)\n" "$repo" "$g:$v"
                        fi
                    fi
                fi
            done | sort
        fi
    }
    echo "#### checking dependencies:"
    forAllProjects check
}
fillLibFolder() {
    local repo="$1"; shift

    (   cd "../$repo"
        if [[ -f pom.xml ]]; then
            rm -rf lib
            mvn dependency:copy-dependencies -Dmdep.stripVersion=true -DoutputDirectory=lib
            mvn dependency:copy-dependencies -Dmdep.stripVersion=true -DoutputDirectory=lib -Dclassifier=javadoc
            mvn dependency:copy-dependencies -Dmdep.stripVersion=true -DoutputDirectory=lib -Dclassifier=sources
        fi
    )
}
main() {
    . ./info.sh

    echo "###################### clone projects if needed:"
    forAllProjects cloneProject

    echo "###################### project info:"
    forAllProjects projectInfo

    echo "###################### compare with old jdclare project:"
    isAllUptodate

    echo "###################### version consistency:"
    versionConsistency

    echo "###################### fill lib folders:"
    #forAllProjects fillLibFolder
}
main
