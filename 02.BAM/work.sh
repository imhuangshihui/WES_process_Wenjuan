ls /mnt/hwstor9k_data1/ccgmtest/work/PWHA55pedigree/01.cleanData/*/*.paired*.gz |perl -e 'while(<>){chomp;my $fq1=$_;chomp(my $fq2=<>);my $temp=(split(/\//,$fq1))[-1];my ($sample,$line,$l)=(split(/\_/,$temp))[0,1,2];print "$sample\t$fq1\t$fq2\n";}' >fqlist 
perl BWA_GATKrecal_v2.pl -fqlist fqlist -platform ILLUMINA -o /mnt/hwstor9k_data1/ccgmtest/work/PWHA55pedigree/02.BAM
