#!/bin/bash
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

###########################################################################################################################
export MVG=ModelingValueGroup
###########################################################################################################################
# format below:
#   repo-name                       badge-workflow      badge-branch
###########################################################################################################################
export repoListDclare=(
    cdm                             build.yaml          develop
    cdm-generator                   build.yaml          develop
    cds-runtime                     build.yaml          develop
    dclareForMPS                    build.yaml          develop
    dclareForJava                   build.yaml          develop
    dclare                          build.yaml          develop
    immutable-collections           build.yaml          develop
    mvg-json                        build.yaml          develop
    sync-proxy                      build.yaml          develop
)
export repoListExamples=(
    ex-FlattenAndCopy               -                   master
    ex-NiamToOO                     -                   master
    ex-EntityClassJava              -                   master
    ex-Sudoku                       -                   master
)
export repoListSupport=(
    generic-info                    build.yaml          master
    gradlePlugins                   build.yaml          develop
    upload-maven-package-action     test.yaml           master
    upload-jetbrains-plugin-action  test.yaml           master
)
export repoListAux=(
    template-java                   build.yaml          master
    template-action                 build.yaml          master
    modelingvalue.nl                -                   master
)
export repoList=(
    "${repoListDclare[@]}"
    "${repoListExamples[@]}"
    "${repoListSupport[@]}"
    "${repoListAux[@]}"
)
###########################################################################################################################
