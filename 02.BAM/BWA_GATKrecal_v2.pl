#!/usr/bin/perl
use warnings;
use Getopt::Long;
my $help =<<qq;
****************************************************************************************************
                                 wenjuan.zhu\@link.cuhk.edu.hk    2018.12.13
****************************************************************************************************
perl $0 -fqlist fq.list -projectID CATwiwR -platform ILLUMINA
Options:    
   -fqlist     :each line shoule like this, Samplename\\sfq1\\sfq2 [File] (necessary)
   -platform   :PL,Allowable options are [ILLUMINA,SLX,SOLEXA,SOLID,454,LS454,COMPLETE,PACBIO,IONTORRENT,CAPILLARY,HELICOS,UNKNOWN]  (necessary)
   -bed        :Target Regions
   -QSUBinfo   :the commond how you run your script; such as "sbatch -p RM -t 48:00:00"
   -o          : outdir

1:This procedure used b37 as reference genome. All GATK bundle of b37 version had been download from GATK website. 
2:If you want to use hg19 or hg38, You can download this files from website or /ifshk1/pub/database/ftp.broadinstitute.org/gsapubftp-anonymous/bundle

qq

my ($fqlist,$bed,$platform,$QSUBinfo,$outdir);
GetOptions(
    "fqlist:s" => \$fqlist,    
    "bed:s" => \$bed,
    "platform:s" => \$platform,
    "QSUBinfo:s" => \$QSUBinfo,
    "o:s" => \$outdir,    
);
$outdir   ||= $ENV{'PWD'};
$QSUBinfo ||= "qsub -cwd -l vf=60G";
die $help if(!$fqlist);
my $time=localtime;$time=~tr/ /_/;my $PWD="/tmp/gatk_$time";if(! -e $PWD) {mkdir $PWD;}

#==software prepare===========
my $softwaredir='/mnt/hwstor9k_data1/ccgmtest/work/software';
my $bwa        ="$softwaredir/bwa-0.7.17/bwa";
my $gatk       ="$softwaredir/gatk-4.1.3.0/gatk";
my $samtools   ="$softwaredir/samtools-1.9/samtools";
my $picard     ="$softwaredir/picard-2.20.8/picard.jar";
my $java       ="$softwaredir/miniconda3/bin/java";
my $nct=20;
#====GATK bundle=====
my $GATK_bundle="/mnt/hwstor9k_data1/ccgmtest/work/software/PubData/hg38";
my $ref        ="$GATK_bundle/Homo_sapiens_assembly38.fasta";
my $dict       ="$GATK_bundle/Homo_sapiens_assembly38.dict";
my $Mills      ="$GATK_bundle/Mills_and_1000G_gold_standard.indels.hg38.vcf.gz";
my $KG_indel   ="$GATK_bundle/1000G_phase1.snps.high_confidence.hg38.vcf.gz";
my $dbsnp      ="$GATK_bundle/dbsnp_146.hg38.vcf.gz";
my $hapmap     ="$GATK_bundle/hapmap_3.3.hg38.vcf.gz";
my $kg_omni    ="$GATK_bundle/1000G_omni2.5.hg38.vcf.gz";
##=============================

open LIST , "$fqlist" or die $!;
if(! -e $outdir) {
    mkdir $outdir;
}
my $BEDinfo="";
if($bed){$BEDinfo="-L $bed --interval-padding 100";}
#else{
#    $BEDinfo="-L $bed --interval-padding 100 ";
#}
open QSUB1, ">$outdir/qsub_s1_bwa.sh" or die $!;
my %samplename  =();
my %sumbam      =();
my %sumbai      =();
my %sumbaminput =();
while(<LIST>){
    chomp;
    my ($sample,$fq1,$fq2)=(split)[0,1,2];
    my $aaaaaa=(split(/\//,$fq1))[-1];
    my $bbbbbb=(split(/\./,$aaaaaa))[0];
    my $id=$bbbbbb;
    if($samplename{$sample}){$samplename{$sample}+=1;} else{$samplename{$sample}=1;}
    $sumbam{$sample}      .=" $outdir/$sample/$id.sorted.bam";
    $sumbai{$sample}      .=" $outdir/$sample/$id.sorted.bam.bai";
    $sumbaminput{$sample} .=" I=$outdir/$sample/$id.sorted.bam";
   
    my $rundir="$outdir/$sample";
    if(! -e $rundir) {mkdir $rundir;}
    if(! -e "$rundir/tmp") {mkdir "$rundir/tmp";}
#==========BWA: aligment===========================    
open OUT, ">$rundir/bwa.$id.sh" or die $!;
my $sh=<<Script;
cd $rundir
date '+--- BWA MEM Start \%y-\%m-\%d \%H:\%M:\%S' >$id.bwa.log
####Allowable options are ILLUMINA,SLX,SOLEXA,SOLID,454,LS454,COMPLETE,PACBIO,IONTORRENT,CAPILLARY,HELICOS,UNKNOWN
####java -jar AddOrReplaceReadGroups.jar I=sample.dedup.realn.bam O=sample.dedup.realn.RG.bam SO=coordinate RGID=sample RGLB=sample RGPU=sample RGPL=ILLUMINA RGSM=sample
$bwa mem -t 48 -M -R "\@RG\\tID:$id\\tSM:$sample\\tLB:$sample\\tPL:$platform" $ref $fq1 $fq2 | $samtools view -bS -t $ref.fai -o $id.bam - && \
date '+--- BWA MEM END \%y-\%m-\%d \%H:\%M:\%S' >>$id.bwa.log
$samtools sort -m 3000000000 $id.bam -T $outdir/$sample/tmp -o $id.sorted.bam 1>> $id.bwa.log 2>&1 || exit 1
$samtools index $id.sorted.bam 1>> $id.bwa.log 2>&1 || exit 1
rm -f $id.bam
#rm -f $fq1 $fq2 
date '+--- BAM sort END \%y-\%m-\%d \%H:\%M:\%S' >>$id.bwa.log
echo '$sample $id  BWA Finished \%y-\%m-\%d \%H:\%M:\%S' >> $outdir/bwa_finish.result

#sh gatk.sh 

Script
print OUT "$sh\n";
close OUT;
print QSUB1 "cd $rundir;$QSUBinfo bwa.$id.sh\n";
}
close QSUB1;
close LIST;

open QSUB2, ">$outdir/qsub_s2_gatk.sh" or die $!;
foreach my $sample (sort keys %samplename){
#========Picard: Merge bam files=====================    
open OUT, ">$outdir/$sample/gatk.sh" or die $!;
if(! -e "$outdir/$sample/tmp") {mkdir "$outdir/$sample/tmp";}
if($samplename{$sample}==1){
print OUT "cd $outdir/$sample\nmv $sumbam{$sample} $sample.sorted.bam\nmv $sumbam{$sample}.bai $sample.sorted.bam.bai\n";
}
else{
my $merge=<<Script;
cd $outdir/$sample
date '+--- Merge         \%y-\%m-\%d \%H:\%M:\%S' > merge.log    
$java -Xmx20g -Djava.io.tmpdir=$outdir/$sample/tmp -XX:MaxPermSize=512m -XX:-UseGCOverheadLimit -jar $picard MergeSamFiles O=$sample.sorted.bam $sumbaminput{$sample} TMP_DIR=$outdir/$sample/tmp SO=coordinate AS=true VALIDATION_STRINGENCY=SILENT 1>>merge.log 2>&1 || exit 1
rm -f $sumbam{$sample} $sumbai{$sample}
date '+--- Merge  END    \%y-\%m-\%d \%H:\%M:\%S' >> merge.log
Script
print OUT "$merge\n";    

}
#========GATK: Recalibrate base quality scores=======
$time=localtime;$time=~tr/ /_/;my $PWD="/tmp/gatk_$time";if(! -e $PWD) {mkdir $PWD;}
my $gatk_recal=<<Script;
cd $outdir/$sample
source /mnt/hwstor9k_data1/ccgmtest/work/software/miniconda3/bin/activate
conda deactivate
conda activate
date '+--- Mark Duplicate      \%y-\%m-\%d \%H:\%M:\%S' > gatk.log
$java -jar $picard MarkDuplicates I=$sample.sorted.bam O=$sample.dedup.bam M=$sample.dedup.metrics CREATE_INDEX=true VALIDATION_STRINGENCY=SILENT TMP_DIR=$outdir/$sample/tmp ASSUME_SORTED=true REMOVE_DUPLICATES=false 1>>gatk.log 2>&1 || exit 1
rm $sample.sorted.bam  $sample.sorted.bam.bai $sample.dedup.metrics 
date '+--- Mark Duplicate  END    \%y-\%m-\%d \%H:\%M:\%S' >> gatk.log

date '+--- Base Score Recalibration \%y-\%m-\%d \%H:\%M:\%S' >> gatk.log
$gatk --java-options "-Xms5g -Xmx32g"  BaseRecalibrator -R $ref --known-sites $KG_indel --known-sites $dbsnp $BEDinfo -O recal.txt -I $sample.dedup.bam  1>>gatk.log 2>&1  || exit 1
date '+--- Apply BQSR                \%y-\%m-\%d \%H:\%M:\%S' >> gatk.log
$gatk --java-options "-Xms1g -Xmx5g" ApplyBQSR -R $ref --bqsr-recal-file recal.txt -I $sample.dedup.bam -O $sample.dedup.recal.bam  1>>gatk.log 2>&1  || exit 1
rm -f $sample.dedup.bam $sample.dedup.bai $sample.dedup.metrics

date '+--- Base Score Recalibration   END \%y-\%m-\%d \%H:\%M:\%S' >> gatk.log

#date '+--- Running HaplotypeCaller         \%y-\%m-\%d \%H:\%M:\%S' >> gatk.log
#$gatk --java-options "-Xms5g -Xmx32g" HaplotypeCaller -R $ref -ERC GVCF --output-mode EMIT_ALL_SITES -I $sample.dedup.recal.bam -O $sample.rmdup.recal.g.vcf.gz $BEDinfo 1>>gatk.log 2>&1 || exit 1
#echo '$sample GATK recal and GVCF Finished \%y-\%m-\%d \%H:\%M:\%S' >> $outdir/gatk_finish.result

curtime=`perl -e '\$s=time();print \$s;'`
date '+--- \$((\$curtime-\$pretime)) seconds elapsed \%y-\%m-\%d \%H:\%M:\%S'
date '+--- End execution \%y-\%m-\%d \%H:\%M:\%S'
rm -r $PWD
conda deactivate

Script
print OUT "$gatk_recal\n";
close OUT;
print QSUB2 "cd $outdir/$sample;$QSUBinfo gatk.sh\n";

}
close QSUB2;
