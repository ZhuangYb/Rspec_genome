#This script is used for extract orthogroup DNAs using Proteinorth out put
#togehter with the original fasta file, each orthgroup will be piled into one 
#single fasta file, which could be used for sequence alignment.
#header should be uniqe to species,  using speces_TR_XXX important!
# example command used for changing header:
# perl -i -ne 'BEGIN{$a=1}if($_=~/>/){print ">elegan_TR","$a","\n";$a++}else{print $_}' elegan_c.fasta
#put all fasta file into same dir as the script

#!/usr/bin/perl -w
use strict;
my($fasta_file,$orth_file,$orth_line,$index,$orth_line_sub,$name,$fasta_line,$max,$header);
my($key,$value);

my(@fasta_file,@orth_file,@orth_line,@orth_line_sub);

my(%fasta_name,%orth_name,%fasta_all,%fasta_db,%fasta_db_length);

BEGIN
{
		`rm Orth_group.*`;
}
`cat *.fasta >combined.fasta`;

#build hash for all fasta entries
open (FASTA,"combined.fasta"); 
foreach $fasta_line(<FASTA>)
{
	if($fasta_line=~/>(.+)\s+/)
	{
		chomp $fasta_line;
		$fasta_db{$1}="";
		$header=$1;	
	}
	else
	{
		chomp $fasta_line;
		$fasta_db{$header}=$fasta_db{$header}.$fasta_line;
	}
}

#store length of each entry into another hash
while (($key,$value)= each %fasta_db)
{
	$fasta_db_length{$key}=length $value;
}

#while (($key,$value)= each %fasta_db)
#{
#	print $key,"    ",$value,"\n";
#}


#readin orth file
$orth_file=shift @ARGV;
open(ORTH,"$orth_file");
@orth_file=<ORTH>;
#print @orth_file;
$index=1;

foreach $orth_line(@orth_file)
{	
	open(OUTPUT,">Orth_group.$index.fasta");
	@orth_line=split(" ",$orth_line);
	foreach $orth_line_sub(@orth_line[3..$#orth_line])
	{
		#print $orth_line_sub,"\n";
		$orth_line_sub=~/(.+?)_TR/;
		$name=$1;
		if($orth_line_sub=~/,/)
		{
			@orth_line_sub=split(",",$orth_line_sub);
			$orth_name{$name}=1;
			foreach $max(@orth_line_sub)
			{
				$orth_name{$name}= $max if $fasta_db_length{$max} > $orth_name{$name};
			}
		}
		else
		{
			$orth_name{$name}=$orth_line_sub;
			
		}
		
	}
	foreach $value (sort values %orth_name)
	{
		print OUTPUT ">",$value,"\n";
		print OUTPUT $fasta_db{$value},"\n";
	}	
	undef %orth_name;
	$index++;
	close OUTPUT;
}








