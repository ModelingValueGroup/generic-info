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
