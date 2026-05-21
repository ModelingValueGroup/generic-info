# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

`generic-info` is the MVG (Modeling Value Group) "project-train" orchestrator. It is not a build target itself: it holds bash scripts that operate on a set of sibling repos that are expected to live next to this clone (`../sync-proxy`, `../dclare`, `../cdm`, etc.). The canonical list lives in `info.sh` (`repoList*` arrays); the build/release order lives in `repoSeq` inside `all-projects.sh` and `prepare-project-for-release.sh`.

There is no application code here. `build.gradle.kts` just applies the `org.modelingvalue.gradle.mvgplugin` and sets `mvgcorrect` as the default task; that task regenerates `README.md` from `README.md.corrector.sh` + `info.sh`. Do not hand-edit `README.md` - edit the generator or `info.sh` and re-run.

## Common commands

- `./all-projects.sh` - interactive menu (CHUI). Key options:
  - `0` overview only (status table across all sibling repos)
  - `3` clean + build (publishes to local maven via `./gradlew publish`)
  - `4` pull + clean + build
  - `6` pull + clean + build + test
  - `7` last 2 weeks of develop commits across all repos
  - `8` time-travel: reset all repos to a given date on develop (will trash working dirs)
  - `v` check/upgrade gradle, java, and project versions across all repos
- `./prepare-project-for-release.sh [X.Y.Z]` - bumps `version=` in every repo's `gradle.properties` and rewrites `:VERSION-BRANCHED` deps in `*.kts`, then commits/pushes "prepare for release X.Y.Z" to each repo.
- `./latest-version.sh <group:artifact>` - query Maven Central for the latest published version (needs `jq`).
- `./gradlew` (in this repo) - runs `mvgcorrect`, which regenerates `README.md`.

## Prerequisites

- Bash 4+ (`all-projects.sh` will exec `/opt/local/bin/bash` if the system bash is older; otherwise it exits).
- Java version comes from each sibling repo's `gradle.properties` (`version_java=`). `all-projects.sh` switches `JAVA_HOME` via `/usr/libexec/java_home -v <ver>` to match.
- `ALLREP_TOKEN` must be set (in `~/.gradle/gradle.properties` or env) - it is the GitHub PAT used to read the github-package-registry. CI passes it as both `ALLREP_TOKEN` and `TOKEN`.
- Intended versions are constants at the top of `all-projects.sh`: `INTENDED_PROJECT_VERSION`, `INTENDED_GRADLE_VERSION`, `INTENDED_JAVA_VERSION`. Bumping a version means editing these and running option `v`.

## How the multi-repo machinery works

- `forAllProjects <fn>` in `all-projects.sh` cds into `../$repo` for every repo in `repoName` and calls `<fn> $repo`. Many helpers (`getBranch`, `getVersion`, ...) print `[repo]='value'` lines that callers `eval` into associative arrays - if you add a helper, follow that exact `printf "[%s]='%s' "` pattern.
- `cloneFetchAll` clones missing repos via `https://github.com/ModelingValueGroup/$repo.git` with `GIT_TERMINAL_PROMPT=0`. Private repos (the CDM trio) silently drop out of `repoSeq`/`repoName` if the clone fails - downstream code must tolerate that.
- Build order in `repoSeq` is load-bearing: `sync-proxy -> mvg-json -> immutable-collections -> dclare -> dclareForJava -> dclareForMPS -> cdm -> cds-runtime -> cdm-generator`. Do not reorder without checking inter-project dep graphs.
- `cleanAll` deletes `~/.m2/repository/snapshots/` and `~/.gradle/caches/modules-2/files-2.1/snapshots.org.modelingvalue/` before invoking `./gradlew clean` in each repo - this is intentional, snapshot caches across repos otherwise mask staleness.
- `publishAll` runs `./gradlew publish` sequentially (not parallel) so downstream repos see upstream artifacts. For `dclareForMPS` / `cdm` / `cdm-generator` it also `download-MPS`'s and zips the resulting plugins into `~/Downloads` plus a combined `cdm-all-YYYYMMDD-HHMM.zip`.

## Release flow

See `HOWTO-release-new-version.md`. Short version: run `./all-projects.sh` option 3 to get clean develop checkouts, then `./prepare-project-for-release.sh X.Y.Z` to bump versions, then manually merge develop -> master per repo in the documented order.

## Conventions to preserve

- Every script begins with the MVG copyright header (the `~~~`/`##` block including "In Memory of Ronald Krijgsheld"). New scripts must include it verbatim.
- `set -euo pipefail` at the top of bash scripts; `trap onError ERR` (which plays `done.wav`) in `all-projects.sh`.
- README.md is generated - edit `README.md.corrector.sh` and `info.sh` instead.
