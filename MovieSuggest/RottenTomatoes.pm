package MovieSuggest::RottenTomatoes;

use strict;

use JSON::Syck;

use MovieSuggest::Request;
use MovieSuggest::Movie;

use constant ROTTEN_TOMATO_KEY => "22p76ydnu5kngebtqt9zpm47";
use constant ROTTEN_TOMATO_MOVIE_BASE_URL => 
	"http://api.rottentomatoes.com/api/public/v1.0/movies/";
use constant ROTTEN_TOMATO_MOVIES_BASE_URL => 
	"http://api.rottentomatoes.com/api/public/v1.0/lists/movies/in_theaters.json?page_limit=50&country=us";


sub new {
	my $class = shift;
	my $self = {};

	bless $self, $class;

	return $self;
}

#Method: get_all_movies
#Arguments: none
#Returns: \@movies
#This method grabs in theaters movie list from RottenTomatoes API and either
#gets their genres from DB or RottenTomatoes API and then return a formatted 
#movies list
sub get_all_movies {
	my $self = shift;

	my @movies;

	my $schema = MovieSuggest::Schema->get_schema;
	my $movie_rs = $schema->resultset('Movie');
	my $genres_rs = $schema->resultset('Genres');

	my $raw_movies = $self->__all_movies_request;
	foreach my $movie (@$raw_movies) {
		my $movie_id = $movie->{id};
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
			$movie_info = $self->__single_movie_request($movie_id);

			#Store for future lookups
			$movie_row = $movie_rs->create({movie_id => $movie_info->{id}, title => $movie_info->{title}});

			foreach my $genre (@{$movie_info->{genres}}) {
				my $genre_row = $genres_rs->find_or_create(
						{description => $genre},{key => "description"}
				);
				$movie_row->add_to_genres($genre_row);
			}
		}

		push @movies, MovieSuggest::Movie->new($movie_info);
	}

	return \@movies;
}

#Method: __single_movie_request
#Arguments: $movie_id
#Returns \%movie_json
#Makes a request to RottenTomatoes to get a single movie data and returns 
#a hash ref with its information
sub __single_movie_request {
	my $self = shift;
	my $movie_id = shift;

	my $url = ROTTEN_TOMATO_MOVIE_BASE_URL;
	$url .= $movie_id.".json?apikey=".ROTTEN_TOMATO_KEY;

	my $response = MovieSuggest::Request->get($url);
	$response = JSON::Syck::Load($response);

	return $response;
}

#Method: __all_movies_request
#Arguments: none
#Returns [ \%movie_json, \%movie_json, ... ]
#Makes a request to RottenTomatoes to get all movies in theaters data and returns 
#an array of hash refs with each movie information
sub __all_movies_request {
	my $self = shift;

	my @movies;
	
	my $url = ROTTEN_TOMATO_MOVIES_BASE_URL;

	do {

		$url .= "&apikey=".ROTTEN_TOMATO_KEY;

		my $response = MovieSuggest::Request->get($url);
		$response = JSON::Syck::Load($response);

		push @movies, @{$response->{movies}};

		$url =  $response->{links}->{next};

	} while ($url); 

	return \@movies;
}

1;