N.B. see below if you want to easily build the dclare stack from scratch

| repository | last commit  | master | develop |
|------------|--------------|--------|---------|
| :one: **`dclare`** |
| [dclareForMPS](https://github.com/ModelingValueGroup/dclareForMPS) | [![GitHub last commit](https://img.shields.io/github/last-commit/ModelingValueGroup/dclareForMPS/develop?style=for-the-badge)](https://github.com/ModelingValueGroup/dclareForMPS) | [![](https://github.com/ModelingValueGroup/dclareForMPS/actions/workflows/build.yaml/badge.svg?branch=master)](https://github.com/ModelingValueGroup/dclareForMPS/actions) | [![](https://github.com/ModelingValueGroup/dclareForMPS/actions/workflows/build.yaml/badge.svg?branch=develop)](https://github.com/ModelingValueGroup/dclareForMPS/actions) |
| [dclareForJava](https://github.com/ModelingValueGroup/dclareForJava) | [![GitHub last commit](https://img.shields.io/github/last-commit/ModelingValueGroup/dclareForJava/develop?style=for-the-badge)](https://github.com/ModelingValueGroup/dclareForJava) | [![](https://github.com/ModelingValueGroup/dclareForJava/actions/workflows/build.yaml/badge.svg?branch=master)](https://github.com/ModelingValueGroup/dclareForJava/actions) | [![](https://github.com/ModelingValueGroup/dclareForJava/actions/workflows/build.yaml/badge.svg?branch=develop)](https://github.com/ModelingValueGroup/dclareForJava/actions) |
| [dclare](https://github.com/ModelingValueGroup/dclare) | [![GitHub last commit](https://img.shields.io/github/last-commit/ModelingValueGroup/dclare/develop?style=for-the-badge)](https://github.com/ModelingValueGroup/dclare) | [![](https://github.com/ModelingValueGroup/dclare/actions/workflows/build.yaml/badge.svg?branch=master)](https://github.com/ModelingValueGroup/dclare/actions) | [![](https://github.com/ModelingValueGroup/dclare/actions/workflows/build.yaml/badge.svg?branch=develop)](https://github.com/ModelingValueGroup/dclare/actions) |
| [immutable-collections](https://github.com/ModelingValueGroup/immutable-collections) | [![GitHub last commit](https://img.shields.io/github/last-commit/ModelingValueGroup/immutable-collections/develop?style=for-the-badge)](https://github.com/ModelingValueGroup/immutable-collections) | [![](https://github.com/ModelingValueGroup/immutable-collections/actions/workflows/build.yaml/badge.svg?branch=master)](https://github.com/ModelingValueGroup/immutable-collections/actions) | [![](https://github.com/ModelingValueGroup/immutable-collections/actions/workflows/build.yaml/badge.svg?branch=develop)](https://github.com/ModelingValueGroup/immutable-collections/actions) |
| [mvg-json](https://github.com/ModelingValueGroup/mvg-json) | [![GitHub last commit](https://img.shields.io/github/last-commit/ModelingValueGroup/mvg-json/develop?style=for-the-badge)](https://github.com/ModelingValueGroup/mvg-json) | [![](https://github.com/ModelingValueGroup/mvg-json/actions/workflows/build.yaml/badge.svg?branch=master)](https://github.com/ModelingValueGroup/mvg-json/actions) | [![](https://github.com/ModelingValueGroup/mvg-json/actions/workflows/build.yaml/badge.svg?branch=develop)](https://github.com/ModelingValueGroup/mvg-json/actions) |
| [sync-proxy](https://github.com/ModelingValueGroup/sync-proxy) | [![GitHub last commit](https://img.shields.io/github/last-commit/ModelingValueGroup/sync-proxy/develop?style=for-the-badge)](https://github.com/ModelingValueGroup/sync-proxy) | [![](https://github.com/ModelingValueGroup/sync-proxy/actions/workflows/build.yaml/badge.svg?branch=master)](https://github.com/ModelingValueGroup/sync-proxy/actions) | [![](https://github.com/ModelingValueGroup/sync-proxy/actions/workflows/build.yaml/badge.svg?branch=develop)](https://github.com/ModelingValueGroup/sync-proxy/actions) |
|            |              |        |         |
| :two: **`support`** |
| [generic-info](https://github.com/ModelingValueGroup/generic-info) | [![GitHub last commit](https://img.shields.io/github/last-commit/ModelingValueGroup/generic-info/master?style=for-the-badge)](https://github.com/ModelingValueGroup/generic-info) | [![](https://github.com/ModelingValueGroup/generic-info/actions/workflows/build.yaml/badge.svg?branch=master)](https://github.com/ModelingValueGroup/generic-info/actions) | [![](https://github.com/ModelingValueGroup/generic-info/actions/workflows/build.yaml/badge.svg?branch=develop)](https://github.com/ModelingValueGroup/generic-info/actions) |
|            |              |        |         |
| :three: **`CDM`** |
| [cdm](https://github.com/ModelingValueGroup/cdm) | _private repo_ | [![](https://github.com/ModelingValueGroup/cdm/actions/workflows/build.yaml/badge.svg?branch=master)](https://github.com/ModelingValueGroup/cdm/actions) | [![](https://github.com/ModelingValueGroup/cdm/actions/workflows/build.yaml/badge.svg?branch=develop)](https://github.com/ModelingValueGroup/cdm/actions) |
| [cds-runtime](https://github.com/ModelingValueGroup/cds-runtime) | _private repo_ | [![](https://github.com/ModelingValueGroup/cds-runtime/actions/workflows/build.yaml/badge.svg?branch=master)](https://github.com/ModelingValueGroup/cds-runtime/actions) | [![](https://github.com/ModelingValueGroup/cds-runtime/actions/workflows/build.yaml/badge.svg?branch=develop)](https://github.com/ModelingValueGroup/cds-runtime/actions) |
| [cdm-generator](https://github.com/ModelingValueGroup/cdm-generator) | _private repo_ | [![](https://github.com/ModelingValueGroup/cdm-generator/actions/workflows/build.yaml/badge.svg?branch=master)](https://github.com/ModelingValueGroup/cdm-generator/actions) | [![](https://github.com/ModelingValueGroup/cdm-generator/actions/workflows/build.yaml/badge.svg?branch=develop)](https://github.com/ModelingValueGroup/cdm-generator/actions) |


## How to easily build the dclare stack from scratch
Our dclare stack is made out of multiple github repositories.
To easily build the whole stack do the following:
- find your github token that has the authority to access the github-package-registry or make a new token if you prefer (sorry, github requires this)
- add the following line to your `~/.gradle/gradle.properties` file:
```
ALLREP_TOKEN=<github-token>
```
- make a fresh directory somewhere that will contain all the projects
- clone the `generic-info` repo in this new directory
- cd to the new clone
- execute `./all-projects.sh` in a bash window
- you will get a CHUI choice of options, choose '3' to run a full build
- the script will run for a few minutes
  - it wil clone the needed projects
  - it will build them in the right order with gradle
  - ...and leave the projects build on your disk

BTW: this method will only build the `develop` branch.
