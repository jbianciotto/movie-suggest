package Request;

use strict;

use HTTP::Request;
use LWP::UserAgent;
use JSON::Syck;

sub get {
	my $class = shift;
	my $url = shift;
	my $method = shift || "GET";

	my $request = HTTP::Request->new($method => $url);

	my $ua = LWP::UserAgent->new();
	my $response = $ua->request ($request);

    if ($response->is_success) {
        $response = $response->decoded_content;
    } else {
        $response = '{"response":{"error":"'.$response->status_line.'"}}';
    }

	return $response;
}

1;