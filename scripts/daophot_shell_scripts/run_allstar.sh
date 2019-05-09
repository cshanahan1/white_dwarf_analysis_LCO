rm $1.als
./allstar > stdouterr.txt 2>&1 << EOF

$1
$1.psf
$1.ap
$1.als
$1s


EOF
