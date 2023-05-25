ls /mnt/hwstor9k_data1/ccgmtest/work/PWHA55pedigree/00.data/raw_data/*/*.gz >fqlist
perl Fastq_QC_shell.pl fqlist /mnt/hwstor9k_data1/ccgmtest/work/PWHA55pedigree/01.cleanData
ls */*.log >list 
perl stat.pl list cleanFQ.stat.xls
