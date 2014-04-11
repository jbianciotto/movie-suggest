package MovieSuggestHandler;

use strict;
use warnings; 
  
use lib "/home/javier/workspace/movie-suggest/";

use Apache2::RequestRec ();
use Apache2::RequestIO ();

use Apache2::Const -compile => qw(OK);

use URL::Encode qw(url_params_mixed);

use URL::Encode qw(url_params_mixed);

use Data::Dumper;
use JSON::Syck;
use List;
use User;


sub handler {
  	my $r = shift;

  	my $response;

  	my $uri = $r->uri;
  	my $args = url_params_mixed($r->args);
    print STDERR Dumper($args);

  	if ($uri =~ /\/createuser$/) {
  		$response = create_user($args);
  	} elsif ($uri =~ /\/update\_location$/) {
  		$response = "Change location";
    } elsif ($uri =~ /\/update\_genres$/) {
        $response = update_genres($args);
  	} elsif ($uri =~ /\/suggest$/) {
  		$response = get_suggestions($args);
	} elsif ($uri =~ /\/history$/) {
        $response = get_history($args);
    } else {
        $response = {error => "Invalid API method"};
    }
  
    my $now = DateTime->now(time_zone => "-0300");
    $response->{date} = $now->dmy." ".$now->hms;

	$r->content_type('application/json');
	print JSON::Syck::Dump($response);

	return Apache2::Const::OK;
}

sub create_user {
    my $args = shift;

    my $username = $args->{username};
    my $region = $args->{region};
    my $city = $args->{city};
    my $genres = $args->{genre};
    $genres = [$genres] if (!ref($genres));

    return { error => "You must provide an username" } unless $username;
    return { error => "You must provide a country/US state" } unless $region;
    return { error => "You must provide a city" } unless $city;
    return { error => "You must provide at least one preferred genre" } unless (scalar @$genres > 0);

    my $user = User->new;
    my $response = $user->create_user($username, $region, $city, $genres);
    return $response;
}

sub get_history {
    my $args = shift;

    my $username = $args->{username};
    return { error => "You must provide an username" } unless $username;

    my $list = List->new;
    my $response = $list->get_history($username);

    return $response;
}

sub get_suggestions {
	my $args = shift;

    my $username = $args->{username};
    return { error => "You must provide an username" } unless $username;

	my $list = List->new;
	my $response = $list->get_suggestions($username);

    return $response;
}

sub update_genres {
    my $args = shift;

    my $username = $args->{username};
    my $genres = $args->{genre};
    $genres = [$genres] if (!ref($genres));

    return { error => "You must provide an username" } unless $username;
    return { error => "You must provide at least one preferred genre" } unless (scalar @$genres > 0);

    my $user = User->new;
    my $response = $user->update_genres($username, $genres);
    return $response;
}

1;
