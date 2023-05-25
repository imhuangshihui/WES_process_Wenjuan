#!/usr/bin/perl
use warnings;
use strict;

if (@ARGV !=2 ) {
	print "perl $0 <in1><outdir>\n";
	exit 0;
}
my ($in1,$outdir)=@ARGV;
if($in1=~/.gz/) {open IN1,"zcat $in1|" or die $!;}  else{open IN1,$in1 or die $!;}
open OUT,'>',"$outdir/run.sh" or die $!;
my %hash=();
while(<IN1>){
    chomp;
    my $fq1=$_;
    chomp(my $fq2=<IN1>); 
#    my $sample=(split(/\//,$fq1))[-2];
    my $temp=(split(/\//,$fq1))[-1]; 
    my ($sample,$line,$l)=(split(/\_/,$temp))[0,1,2];
    my $name="$sample"."_$line"."_$l";
    if(! -e "$outdir/$sample") {mkdir "$outdir/$sample";}
    my $trimmomatic="/mnt/hwstor9k_data1/ccgmtest/work/software/miniconda3/bin/java -jar /mnt/hwstor9k_data1/ccgmtest/work/software/Trimmomatic-0.39/trimmomatic-0.39.jar ";
    my $dapter="$outdir/Truseq_adapters.fa";
#    my $dapter='/mnt/hwstor9k_data1/ccgmtest/work/software/Trimmomatic-0.39/adapters/TruSeq3-PE-2.fa';
    print OUT "date;cd $outdir/$sample;$trimmomatic PE -threads 48 -trimlog trim.log $fq1 $fq2 $name.paired_R1.fq.gz $name.unpaired_R1.fq.gz $name.paired_R2.fq.gz $name.unpaired_R2.fq.gz ILLUMINACLIP:$dapter:2:30:10 LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36 1>trimmomatic.log 2>&1 || exit 1; rm trim.log ;echo $name Fastq QC Finished;date\n";
#    "cd /mnt/hwstor9k_data1/ccgmtest/work/PWHA55pedigree/02.BAM/$sample; sh bwa.$sample.sh\n".
#    "cd /mnt/hwstor9k_data1/ccgmtest/work/PWHA55pedigree/02.BAM/$sample; sh gatk.sh\n".
#    "cd /mnt/hwstor9k_data1/ccgmtest/work/PWHA55pedigree/04.SampleQC/Bamstat/$sample; sh Bamstat.$sample.sh\n";

}
close OUT;
close IN1;

#foreach my $key (sort keys %hash){
#    print "$hash{$key}\n";
#}

#foreach my $key1 (sort keys %hash){
#    foreach my $key2 (sort keys %{$hash{$key1}}){
#        print "$hash{$key}\n";
#    }
#}
