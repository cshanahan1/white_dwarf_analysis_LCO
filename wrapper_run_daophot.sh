#!/bin/bash

for filename in *e91.fits; do

	filename=${filename%.*}
	echo $filename
	
	fit_rad=$(grep "fitt" $filename.opt | sed -r 's/.* ([0-9]+\.*[0-9]*).*?/\1/')
	echo "fitting radius is: $fit_rad"
	
	./run_daophot.sh $filename $fit_rad

	
done