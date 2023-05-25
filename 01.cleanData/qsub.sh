rm xx_*
split -l 1 run.sh xx_
ls xx_* > xx.list
#less xx.list|perl -e 'while(<>) {chomp;print "sh $_ &\n";}'
less xx.list|perl -e 'while(<>) {chomp;`qsub -cwd -l vf=20G $_`;}' 
rm xx.list 

