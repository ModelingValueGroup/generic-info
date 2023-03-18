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

rm -f /tmp/*-list /tmp/o-*
cd ../cdm
find . -name \*.mps -type f ! -name \*.migration.mps -exec cat {} + \
    | sed -E 's/ (id|role|node|concept|index|flags|to|ref)="[^"]*"/ /g' \
    | sed -E 's/[A-Z][a-z]/ &/g' \
    | sed -E 's/[^a-zA-Z]/\n/g' \
    | sed -E '/^.*([A-Z].*[a-z]|[a-z].*[A-Z]).*$/y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/' \
    | egrep -v '^[0-9]' \
    | sort -u \
    > /tmp/$$-list

aspell -l en list < /tmp/$$-list > /tmp/$$-non-en-list
aspell -l nl list < /tmp/$$-list > /tmp/$$-non-nl-list

comm -23 /tmp/$$-non-en-list /tmp/$$-non-nl-list  >/tmp/o-$$-nl
comm -13 /tmp/$$-non-en-list /tmp/$$-non-nl-list  >/tmp/o-$$-en
comm -12 /tmp/$$-non-en-list /tmp/$$-non-nl-list  >/tmp/o-$$-other

ls -l /tmp/o-*
rm -f /tmp/*-list

less /tmp/o-$$-nl
