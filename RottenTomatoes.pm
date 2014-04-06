package RottenTomatoes;

use strict;

use JSON::Syck;
use Data::Dumper;


use Request;
use Movie;


use constant ROTTEN_TOMATO_KEY => "22p76ydnu5kngebtqt9zpm47";
use constant ROTTEN_TOMATO_MOVIE_BASE_URL => 
	"http://api.rottentomatoes.com/api/public/v1.0/movies/";
use constant ROTTEN_TOMATO_MOVIES_BASE_URL => 
	"http://api.rottentomatoes.com/api/public/v1.0/lists/movies/";


sub new {
	my $class = shift;
	my $self = {};

	bless $self, $class;

	return $self;
}


#TODO: paginar los request, solo devuelve hasta 50
sub get_all_movies {
	my $self = shift;

	my @movies;

	my $movies_json = $self->all_movies_request;
	foreach my $movie_json (@{$movies_json->{movies}}) {

		my $movie_info = $self->single_movie_request($movie_json->{id});

		my $movie = Movie->new($movie_info);

		push @movies, $movie;
		print Dumper($movie);
#		last;
	}

	return \@movies;
}

sub single_movie_request {
	my $self = shift;
	my $movie_id = shift;

	my $url = ROTTEN_TOMATO_MOVIE_BASE_URL;
	$url .= $movie_id.".json?apikey=".ROTTEN_TOMATO_KEY;

	my $response = Request->new->do_request($url);
	if ($response !~ /^ERROR/) {
		$response = JSON::Syck::Load($response);
	}

	return $response;
}

sub all_movies_request {
	my $self = shift;

	my $url = ROTTEN_TOMATO_MOVIES_BASE_URL;
	$url .= "in_theaters.json?apikey=".ROTTEN_TOMATO_KEY."&page_limit=50";

	my $response = Request->new->do_request($url);
	if ($response !~ /^ERROR/) {
		$response = JSON::Syck::Load($response);
	}

	return $response;
}

1;