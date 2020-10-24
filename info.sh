#!/bin/bash
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

###########################################################################################################################
export MVG=ModelingValueGroup
###########################################################################################################################
export repoListDclare=(
    immutable-collections           build
    dclare                          build
    dclareForJava                   build
    dclareForMPS                    build
)
export repoListExamples=(
    ex-FlattenAndCopy               notYetImplemented
    ex-NiamToOO                     notYetImplemented
    ex-EntityClassJava              notYetImplemented
    ex-Sudoku                       notYetImplemented
)
export repoListSupport=(
    generic-info                    check
    buildtools                      build
    upload-maven-package-action     test
    upload-jetbrains-plugin-action  test
    sync-s3-action                  test
)
export repoList=(
    "${repoListDclare[@]}"
    "${repoListExamples[@]}"
    "${repoListSupport[@]}"
)
###########################################################################################################################
