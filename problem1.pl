#!/usr/bin/perl -w

use Data::Dumper;
use JSON;
my %data;

-f $ARGV[0] || die "$ARGV[0] is not a file\n";

open $fh,$ARGV[0] || die "Unable to open $ARGV[0] for reading\n";
my $curSlot="";
#print "$fh, $ARGV[0] \n";
while (my $line=<$fh>)
{
	chomp $line;
	if ($line =~ /System Serial Number/)
	{
		#print "Found Number\n";
		my $SYSTEMNUMBER=(split ':',$line)[1];
		$SYSTEMNUMBER=~s/^ //;
		$data{data}{serialNumber}=$SYSTEMNUMBER;
		#print "Serial Number: $SYSTEMNUMBER\n";
	}
	elsif ($line =~ /FAS[0-9]{4}/ )
	{	
		my $model=$line;
		$model=~s/^.*(FAS[0-9]{4}).*/$1/;
		#print "Model Name: $model\n";	
		#print $line;
		$data{data}{modelNumber}=$model;
	}
	elsif ($line =~ /slot [0-9]:/)
	{
	#slot 0:  FC Host Adapter 0g (Dual-channel, QLogic 2322 rev. 3, 64-bit, L-port, <OFFLINE (hard)>)
	#slot 1:  NVRAM (NVRAM VI)
	#slot 2:  SAS Host Adapter 2a (PMC-Sierra PM8001 rev. C, SAS, <UP>)
		if ($line =~ /[0-9][a-z]/)
		{
			#print $line."\n";
			my ($slotnum,$slotname,$subslot)=$line=~/slot ([0-9]): (.*) ([0-9][a-z])/;
			$curSlot=$subslot;
			#print $subslot."\n";
			$data{data}{PCI}{slot}{$subslot}{name}=$slotname if ($slotnum != 0);
		}
		else
		{
			#print $line."\n";
			my ($slotnum,$slotname)=$line=~/slot ([0-9]): ([^\(]*) /;
			#print "$slotnum $slotname\n";
			$curSlot=$slotnum;
			$data{data}{PCI}{slot}{$curSlot}{name}=$slotname if ($slotnum != 0);
		}
	}
	elsif ($line =~ /[0-9]+  : NETAPP/)
	{
		#print $slot;
		$data{data}{disks}{slot}{$curSlot}{count}++;
	}
}

$json = JSON->new->allow_nonref;

my $json_txt=$json->pretty->encode(\%data);


print $json_txt;

#print Dumper %data;