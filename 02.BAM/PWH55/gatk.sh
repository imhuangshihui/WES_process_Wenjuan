cd /mnt/hwstor9k_data1/ccgmtest/work/PWHA55pedigree/02.BAM/PWH55
mv  /mnt/hwstor9k_data1/ccgmtest/work/PWHA55pedigree/02.BAM/PWH55/PWH55_HN3K3DSXX_L4.sorted.bam PWH55.sorted.bam
mv  /mnt/hwstor9k_data1/ccgmtest/work/PWHA55pedigree/02.BAM/PWH55/PWH55_HN3K3DSXX_L4.sorted.bam.bai PWH55.sorted.bam.bai
cd /mnt/hwstor9k_data1/ccgmtest/work/PWHA55pedigree/02.BAM/PWH55
source /mnt/hwstor9k_data1/ccgmtest/work/software/miniconda3/bin/activate
conda deactivate
conda activate
date '+--- Mark Duplicate      %y-%m-%d %H:%M:%S' > gatk.log
/mnt/hwstor9k_data1/ccgmtest/work/software/miniconda3/bin/java -jar /mnt/hwstor9k_data1/ccgmtest/work/software/picard-2.20.8/picard.jar MarkDuplicates I=PWH55.sorted.bam O=PWH55.dedup.bam M=PWH55.dedup.metrics CREATE_INDEX=true VALIDATION_STRINGENCY=SILENT TMP_DIR=/mnt/hwstor9k_data1/ccgmtest/work/PWHA55pedigree/02.BAM/PWH55/tmp ASSUME_SORTED=true REMOVE_DUPLICATES=false 1>>gatk.log 2>&1 || exit 1
rm PWH55.sorted.bam  PWH55.sorted.bam.bai PWH55.dedup.metrics 
date '+--- Mark Duplicate  END    %y-%m-%d %H:%M:%S' >> gatk.log

date '+--- Base Score Recalibration %y-%m-%d %H:%M:%S' >> gatk.log
/mnt/hwstor9k_data1/ccgmtest/work/software/gatk-4.1.3.0/gatk --java-options "-Xms5g -Xmx32g"  BaseRecalibrator -R /mnt/hwstor9k_data1/ccgmtest/work/software/PubData/hg38/Homo_sapiens_assembly38.fasta --known-sites /mnt/hwstor9k_data1/ccgmtest/work/software/PubData/hg38/1000G_phase1.snps.high_confidence.hg38.vcf.gz --known-sites /mnt/hwstor9k_data1/ccgmtest/work/software/PubData/hg38/dbsnp_146.hg38.vcf.gz  -O recal.txt -I PWH55.dedup.bam  1>>gatk.log 2>&1  || exit 1
date '+--- Apply BQSR                %y-%m-%d %H:%M:%S' >> gatk.log
/mnt/hwstor9k_data1/ccgmtest/work/software/gatk-4.1.3.0/gatk --java-options "-Xms1g -Xmx5g" ApplyBQSR -R /mnt/hwstor9k_data1/ccgmtest/work/software/PubData/hg38/Homo_sapiens_assembly38.fasta --bqsr-recal-file recal.txt -I PWH55.dedup.bam -O PWH55.dedup.recal.bam  1>>gatk.log 2>&1  || exit 1
rm -f PWH55.dedup.bam PWH55.dedup.bai PWH55.dedup.metrics

date '+--- Base Score Recalibration   END %y-%m-%d %H:%M:%S' >> gatk.log

#date '+--- Running HaplotypeCaller         %y-%m-%d %H:%M:%S' >> gatk.log
#/mnt/hwstor9k_data1/ccgmtest/work/software/gatk-4.1.3.0/gatk --java-options "-Xms5g -Xmx32g" HaplotypeCaller -R /mnt/hwstor9k_data1/ccgmtest/work/software/PubData/hg38/Homo_sapiens_assembly38.fasta -ERC GVCF --output-mode EMIT_ALL_SITES -I PWH55.dedup.recal.bam -O PWH55.rmdup.recal.g.vcf.gz  1>>gatk.log 2>&1 || exit 1
#echo 'PWH55 GATK recal and GVCF Finished %y-%m-%d %H:%M:%S' >> /mnt/hwstor9k_data1/ccgmtest/work/PWHA55pedigree/02.BAM/gatk_finish.result

curtime=`perl -e '$s=time();print $s;'`
date '+--- $(($curtime-$pretime)) seconds elapsed %y-%m-%d %H:%M:%S'
date '+--- End execution %y-%m-%d %H:%M:%S'
rm -r /tmp/gatk_Wed_Oct_30_21:37:21_2019
conda deactivate


