ref_file=$1
echo " * Beginning DAOMatch * "
echo "Reference file is $1.fits."

rm -f $ref_file.mch

./daomatch << EOF
$ref_file
$ref_file.mch


EOF

