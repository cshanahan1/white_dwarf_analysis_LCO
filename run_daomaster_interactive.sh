#!/bin/bash


rm -f $1.mag $1.cor $1.raw $1.tfr

echo " * Beginning DAOMaster * "
echo "Reference file is $1."
./daomaster_efo << EOF
$1
2,0,$2
0.5
20
5
5
5
5
5
4
4
4
4
4
3
3
3
3
3
2
2
2
2
2
2
1
1
1
1
1
0
n
y
$1.mag 
y
$1.cor
y
$1.raw
y
$1.mch
OVERWRITE
y
$1.tfr
n
n
EOF