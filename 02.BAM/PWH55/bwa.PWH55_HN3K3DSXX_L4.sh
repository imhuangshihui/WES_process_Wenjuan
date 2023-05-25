cd /mnt/hwstor9k_data1/ccgmtest/work/PWHA55pedigree/02.BAM/PWH55
date '+--- BWA MEM Start %y-%m-%d %H:%M:%S' >PWH55_HN3K3DSXX_L4.bwa.log
####Allowable options are ILLUMINA,SLX,SOLEXA,SOLID,454,LS454,COMPLETE,PACBIO,IONTORRENT,CAPILLARY,HELICOS,UNKNOWN
####java -jar AddOrReplaceReadGroups.jar I=sample.dedup.realn.bam O=sample.dedup.realn.RG.bam SO=coordinate RGID=sample RGLB=sample RGPU=sample RGPL=ILLUMINA RGSM=sample
/mnt/hwstor9k_data1/ccgmtest/work/software/bwa-0.7.17/bwa mem -t 48 -M -R "@RG\tID:PWH55_HN3K3DSXX_L4\tSM:PWH55\tLB:PWH55\tPL:ILLUMINA" /mnt/hwstor9k_data1/ccgmtest/work/software/PubData/hg38/Homo_sapiens_assembly38.fasta /mnt/hwstor9k_data1/ccgmtest/work/PWHA55pedigree/01.cleanData/PWH55/PWH55_HN3K3DSXX_L4.paired_R1.fq.gz /mnt/hwstor9k_data1/ccgmtest/work/PWHA55pedigree/01.cleanData/PWH55/PWH55_HN3K3DSXX_L4.paired_R2.fq.gz | /mnt/hwstor9k_data1/ccgmtest/work/software/samtools-1.9/samtools view -bS -t /mnt/hwstor9k_data1/ccgmtest/work/software/PubData/hg38/Homo_sapiens_assembly38.fasta.fai -o PWH55_HN3K3DSXX_L4.bam - && 
date '+--- BWA MEM END %y-%m-%d %H:%M:%S' >>PWH55_HN3K3DSXX_L4.bwa.log
/mnt/hwstor9k_data1/ccgmtest/work/software/samtools-1.9/samtools sort -m 3000000000 PWH55_HN3K3DSXX_L4.bam -T /mnt/hwstor9k_data1/ccgmtest/work/PWHA55pedigree/02.BAM/PWH55/tmp -o PWH55_HN3K3DSXX_L4.sorted.bam 1>> PWH55_HN3K3DSXX_L4.bwa.log 2>&1 || exit 1
/mnt/hwstor9k_data1/ccgmtest/work/software/samtools-1.9/samtools index PWH55_HN3K3DSXX_L4.sorted.bam 1>> PWH55_HN3K3DSXX_L4.bwa.log 2>&1 || exit 1
rm -f PWH55_HN3K3DSXX_L4.bam
#rm -f /mnt/hwstor9k_data1/ccgmtest/work/PWHA55pedigree/01.cleanData/PWH55/PWH55_HN3K3DSXX_L4.paired_R1.fq.gz /mnt/hwstor9k_data1/ccgmtest/work/PWHA55pedigree/01.cleanData/PWH55/PWH55_HN3K3DSXX_L4.paired_R2.fq.gz 
date '+--- BAM sort END %y-%m-%d %H:%M:%S' >>PWH55_HN3K3DSXX_L4.bwa.log
echo 'PWH55 PWH55_HN3K3DSXX_L4  BWA Finished %y-%m-%d %H:%M:%S' >> /mnt/hwstor9k_data1/ccgmtest/work/PWHA55pedigree/02.BAM/bwa_finish.result

#sh gatk.sh 


