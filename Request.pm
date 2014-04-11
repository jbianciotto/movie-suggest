package Request;

use strict;

use HTTP::Request;
use LWP::UserAgent;
use JSON::Syck;

sub new {
	my $class = shift;
	my $self = {};

	bless $self, $class;

	return $self;
}


sub do_request {
	my $self = shift;
	my $url = shift || return;
	my $method = shift || "GET";

	print STDERR "Fetching $url\n";

	my $request = HTTP::Request->new($method => $url);

	my $ua = LWP::UserAgent->new();
	my $response = $ua->request ($request);

    if ($response->is_success) {
        $response = $response->decoded_content;
    } else {
    	print "ERROR: ".$response->status_line."\n";
        $response = "ERROR: ".$response->status_line."\n";
    }

	return $response;
}

1;