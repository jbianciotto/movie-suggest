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

	my $schema = MovieSuggest::Schema->get_schema;
	my $movie_rs = $schema->resultset('Movie');
	my $genres_rs = $schema->resultset('Genres');

#TODO: cambiar nombre de movies_json
	my $movies_json = $self->all_movies_request;
	foreach my $movie_json (@{$movies_json->{movies}}) {
		my $movie_id = $movie_json->{id};
		my $movie_info;

		#Movie info lookup
		my $movie_row = $movie_rs->find({movie_id => $movie_id}, {key => "movie_id"});
		if ($movie_row) {
			#Info found
			my @genres = map {$_->description} $movie_row->genres;
			$movie_info = {
				id => $movie_row->movie_id, 
				title => $movie_row->title, 
				genres => \@genres
			};
		} else {
			#Info not found
			$movie_info = $self->single_movie_request($movie_id);

			#Store for future lookups
			$movie_row = $movie_rs->create({movie_id => $movie_info->{id}, title => $movie_info->{title}});

			foreach my $genre (@{$movie_info->{genres}}) {
				my $genre_row = $genres_rs->find_or_create({description => $genre},{key => "description"});
				$movie_row->add_to_genres($genre_row);
			}
		}


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