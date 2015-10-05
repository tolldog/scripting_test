#!/usr/bin/perl -w

use HTTP::Request;
use LWP::UserAgent; 
use Data::Dumper;
use JSON;

my %quotes;

for ($i=0; $i<=4; $i++)
{$symbols[$i]=$ARGV[$i] if $ARGV[$i];}

foreach my $symbol (@symbols)
{
	my $request=HTTP::Request->new(GET=> 'http://finance.yahoo.com/webservice/v1/symbols/'.$symbol.'/quote?format=json&view=detail');
	my $ua = LWP::UserAgent->new;
	my $response = $ua->request($request);

	my $hash_pt=decode_json ($response->{_content});
	my %hash=%$hash_pt;

	if ($hash{list})
	{
		$quotes{$symbol}{price}=$hash{list}{resources}[0]{resource}{fields}{price};
		$quotes{$symbol}{change}=$hash{list}{resources}[0]{resource}{fields}{change};
	}
}

foreach my $symbol (sort keys %quotes)
{
	if ($quotes{$symbol}{price})
	{
		print "$symbol $quotes{$symbol}{price} $quotes{$symbol}{change}\n";
	}
	else
	{
		print "$symbol N/A N/A\n";
	}
}