#!/bin/sh
ls -AlR |
grep "^[-d]" |
sort -rn -k 5 |
awk '($1 ~ /^-/){ {total += $5} {file += 1}}
($1 ~ /^d/){dir += 1}
(NR < 6){print NR ": " $5 " " $9}
END{print "Dir num: " dir "\n" "File num: " file "\n" "total: " total }'
