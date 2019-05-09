echo " * Beginning Allframe * "
echo "Reference file is $1.fits."
./allframe > stdouterr.txt 2>&1 << EOF

$1.mch
$1.mag
EOF