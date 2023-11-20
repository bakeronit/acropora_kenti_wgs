#!/usr/bin/perl

#use strict;
use warnings;
use Getopt::Long;

my $pop1maf;
my $pop2maf;
my $minInd;

&GetOptions( 'pop1maf=s' => \$pop1maf,
             'pop2maf=s' => \$pop2maf,
             'minInd=i' => \$minInd,
			 );

my $usage = <<_EOUSAGE_;
#########################################################################################
# getDxy.pl --pop1maf <FILE> --pop2maf <FILE> --nInd <Integer>
# Required:
#  --pop1maf        a text maf file output from ANGSD with apporpriate filtering for Population 1
#  --pop2maf        a text maf file output from ANGSD with apporpriate filtering for Population 2
#  --minInd         minimum number of individuals required per population
#
#This script assumes equal and corresponding lines in the two maf files. User needs to filter for variable sites using the SNP pval before running this script.
#
#
#Following columns need to be present:
#
#chromo	position	major	minor	ref	knownEM	unknownEM	nInd
#
#
#Dxy is reported only for the sites included in the MAF file. While calculating the value per window, the correct number of sites has to be used.
#
#Example command to run the script
#perl getDxy.pl --pop1maf pop1.pop1_pop2.genotypes.mafs.txt --pop2maf pop2.pop1_pop2.genotypes.mafs.txt --minInd 5
###########################################################################################
_EOUSAGE_

	;
 
if (! defined $pop1maf) {print $usage;exit;}
if (! defined $pop2maf) {print $usage;exit;}
if (! defined $minInd) {print $usage;exit;}

open POP1MAF, $pop1maf or die $!;
open POP2MAF, $pop2maf or die $!;

my $line1;
my $line2;

my $dxy=0;
#read in the header and do nothing
my $header1=<POP1MAF>;my $header2=<POP2MAF>;

print "chromo\tposition\tDxy\n";

while($line1=<POP1MAF>){
        #read in maf from pop1
        chomp $line1;my @parts=split('\t',$line1);
        
        #read in maf from pop2
        $line2=<POP2MAF>;chomp $line2;my @parts2=split('\t',$line2);
        
#        print $parts[0]," ",$parts[1]," ",$parts[2]," ",$parts[3]," ",$parts[4]," ",$parts[5]," ",$parts[6]," ",$parts[7],"\n";
#		print $parts2[0]," ",$parts2[1]," ",$parts2[2]," ",$parts2[3]," ",$parts2[4]," ",$parts2[5]," ",$parts2[6]," ",$parts2[7],"\n";

		if(($parts[7]>=$minInd)&&($parts2[7]>=$minInd)){#use only sites that are covered by atleast $minInd individuals in each population


                if(($parts[2]=~/$parts2[2]/)&&($parts[3]=~/$parts2[3]/)){#check if the major and minor allele are matching

                $dxy=$parts[6]*(1-$parts2[6])+($parts2[6]*(1-$parts[6]));

                print "$parts[0]\t$parts[1]\t$dxy\n"; # print scaffold, position and per site dxy

                }

                if(($parts[2]=~/$parts2[3]/)&&($parts[3]=~/$parts2[2]/)){#check if the major and minor allele are NOT matching

                $dxy=($parts[6]*$parts2[6])+((1-$parts2[6])*(1-$parts[6]));

                print "$parts[0]\t$parts[1]\t$dxy\n";# print scaffold, position and per site dxy

                }

}}
close POP1MAF;
close POP2MAF;