rm -f $1s.fits $1.psf $1.ap $1.als $1.lst $1.coo lista*

echo " * Beginning DAOPhot * "
echo "Processing $1.fits."
fit_rad=$(grep "fitt" $1.opt | sed -r 's/.* ([0-9]+\.*[0-9]*).*?/\1/')

./daophot > stdouterr.txt 2>&1 << EOF
opt
$1.opt


at $1
fi
1,1

$1.coo
y

ph


$1.coo
$1.ap



pick
$1.ap
30,18
$1.lst

psf
$1.ap
$1.lst
$1.psf

EOF

grep -v '?' lista.dat > lista2.dat
grep -v '*' lista2.dat > $1.lst
rm -f $1.psf

./daophot > stdouterr.txt 2>&1 << EOF
opt
$1.opt


at $1
psf
$1.ap
$1.lst
$1.psf

EOF

echo "Beginning allstar. fitting radius is: $fit_rad"
./allstar > stdouterr.txt 2>&1 << EOF
fi=$fit_rad

$1.fits
$1.psf
$1.ap
$1.als



EOF

echo "* * * * * * * * * *"

