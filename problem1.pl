#!/usr/bin/perl -w


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
		print "Serial Number: $SYSTEMNUMBER\n";
	}
	elsif ($line =~ /FAS[0-9]{4}/ )
	{	
		my $model=$line;
		$model=~s/^.*(FAS[0-9]{4}).*/$1/;
		print "Model Name: $model\n";	
		#print $line;
	}
	elsif ($line =~ /slot [0-9]:/)
	{
		#print $line;
		($slot,$slotName)=(split ':',$line)[0,1];
		#print "$slot $slotName\n";
		$slot=~s/^\s+slot //;
		$subSlot=$slotName;
		$subSlot=~s/.*[0-9]+([a-z]) \(.*$/$1/;
		$slotName=~s/.*\(([^,]*),.*/$1/;
		$PCI{$slot}=$slotName;
		$name{$slot}{$subSlot} = $slotName;
		$curSlot=$slot;
	}
	elsif ($line =~ /[0-9]+  : NETAPP/)
	{
		#print $slot;
		$disks{$slot}{$subSlot}++;
	}
}

foreach $slot (sort keys %name)
{
	#print "PCI Slot: $slot [$PCI{$slot}]\n";
	foreach $subSlot (sort keys %{$name{$slot}})
	{
		if ($disks{$slot}{$subSlot})
		{
			#print "$slot$subSlot $name{$slot}{$subSlot} : $disks{$slot}{$subSlot} disks\n";
		}
		else
		{
			print "$slot$subSlot $name{$slot}{$subSlot}\n" if ($slot ne "slot 0");
		}
	}
}