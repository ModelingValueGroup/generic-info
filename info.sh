#!/bin/bash
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

###########################################################################################################################
export MVG=ModelingValueGroup
###########################################################################################################################
# format below:
#   repo-name                       badge-workflow      badge-branch
###########################################################################################################################
export repoListDclare=(
    cdm                             build               develop
    cds-runtime                     build               develop
    dclareForMPS                    build               develop
    dclareForJava                   build               develop
    dclare                          build               develop
    immutable-collections           build               develop
    mvg-json                        build               develop
    sync-proxy                      build               develop
)
export repoListExamples=(
    ex-FlattenAndCopy               -                   master
    ex-NiamToOO                     -                   master
    ex-EntityClassJava              -                   master
    ex-Sudoku                       -                   master
)
export repoListSupport=(
    generic-info                    check               master
    gradlePlugins                   build               develop
    upload-maven-package-action     test                master
    upload-jetbrains-plugin-action  test                master
)
export repoListAux=(
    template-java                   build               master
    template-action                 build               master
    modelingvalue.nl                -                   master
)
export repoList=(
    "${repoListDclare[@]}"
    "${repoListExamples[@]}"
    "${repoListSupport[@]}"
    "${repoListAux[@]}"
)
###########################################################################################################################
