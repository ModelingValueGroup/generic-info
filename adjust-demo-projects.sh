#!/bin/bash
set -ue

#
# this script will take the build files from the master branch of the demo-lib & demo-lib projects
# and copy them over to the experiment & plugh & develop branches
#

cd ..
for p in demo-lib demo-app; do
    echo
    echo ============================================ $p
    read x
    (   cd $p
        git config pull.rebase false
        if git status | fgrep -q 'nothing to commit, working tree clean'; then
            echo ========================== checkout master, fetch, pull
            git checkout master
            git fetch
            git pull

            echo ========================== run master...
            if [[ $p == demo-lib ]]; then
                ./gradlew clean build publish
            else
                ./gradlew clean build run
            fi | egrep '^>'
            echo ========================== prepare...
            rm -rf /tmp/tomtomtom
            mkdir /tmp/tomtomtom
            if [[ -d app ]]; then
                d=app
            fi
            if [[ -d lib ]]; then
                d=lib
            fi
            cp build.gradle.kts             /tmp/tomtomtom
            cp settings.gradle.kts          /tmp/tomtomtom
            cp gradle.properties            /tmp/tomtomtom
            cp $d/build.gradle.kts          /tmp/tomtomtom/sub-build.gradle.kts
            cp .github/workflows/build.yaml /tmp/tomtomtom/build.yaml

            echo ========================== push...
            git fetch
            git push

            echo
            for b in experiment plugh develop; do
                echo ========================== checkout $b...
                git checkout $b
                git pull
                echo ========================== cp...
                cp /tmp/tomtomtom/settings.gradle.kts   .
                cp /tmp/tomtomtom/build.gradle.kts      .
                cp /tmp/tomtomtom/gradle.properties     .
                cp /tmp/tomtomtom/sub-build.gradle.kts  $d/build.gradle.kts
                cp /tmp/tomtomtom/build.yaml            .github/workflows/build.yaml
                rm -f $d/xxx xxx

                if git status | fgrep -q 'nothing to commit, working tree clean'; then
                    echo ========================== uptodate...
                else
                    echo ========================== add/commit/push...
                    git add .
                    git commit -m "sync"
                    git push
                fi
                echo ========================== run $b...
                if [[ $p == demo-lib ]]; then
                    ./gradlew clean build publish
                else
                    ./gradlew clean build run
                fi | egrep '^>'
                echo ========================== done...
            done

            echo ========================== back to master...
            git checkout master
        fi
    )
done
