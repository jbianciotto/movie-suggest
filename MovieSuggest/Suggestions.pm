package  MovieSuggest::Suggestions;

use strict;

use MovieSuggest::Schema;
use MovieSuggest::Weather;
use MovieSuggest::RottenTomatoes;

sub new {
	my $class = shift;
	my $self = {};

	bless $self, $class;

	return $self;
}

#Method: get_suggestions
#Arguments: $username
#Return: \%movies_list
#Return the suggestions list for the username provided in a suitable format 
#for the top level handler
sub get_suggestions {
	my ($self, $username) = @_;

	my $schema = MovieSuggest::Schema->get_schema;
	my $user_rs = $schema->resultset('User');

	my $user = $user_rs->find({username => $username}, {key => "username"});
	return { error => "User does not exist" } unless ($user);

	#1) Get user location
	my $location = $user->location;

	#2) Grab user preferred genres
	my @user_genres = map {$_->description} $user->genres;

	#3) Grab weather conditions
	my $weather = MovieSuggest::Weather->new;
	my $conditions = $weather->get_conditions($location);
	return $conditions if ($conditions->{error});

	#4) Get matching genres for conditions
	my @condition_genres = $weather->matching_genres($conditions);

	#5) Intersect user and weather genres
	my %user_genres=map{$_ =>1} @user_genres;
	my @genres = grep( $user_genres{$_}, @condition_genres);

	#6) Get movies 
	my $movies_list = $self->__get_movies(\@genres);

	#7) Save historical data
  	$self->__save_history($user,$conditions,$movies_list);

  	#8) Return formatted suggestions
	return $self->__format_movies_response($movies_list, \@genres, $conditions);
}

#Method: get_history
#Arguments: $username
#Return value: \%history
#Return the history of request for the given username
sub get_history {
	my $self = shift;
	my $username = shift;

	my $schema = MovieSuggest::Schema->get_schema;

	my $user_rs = $schema->resultset('User');
	my $user = $user_rs->find({username => $username}, {key => "username"});
	return { error => "User does not exist" } unless ($user);

	my $history_rs = $schema->resultset('History');
	my $histories = $history_rs->search({ user_id => $user->id});

	my $rv = { 
		results => []
	};
	foreach my $history ($histories->all) {
		my $history_hash = {};
		$history_hash->{id} = $history->id;

		$history_hash->{conditions}->{weather} = $history->weather;
		$history_hash->{conditions}->{temperature} = $history->temperature;
		$history_hash->{date} = $history->date;
		$history_hash->{movies} = [];

		foreach my $movie ( $history->movies) {
			my $movie_info = MovieSuggest::Movie->new({
								id => $movie->movie_id, 
								title => $movie->title, 
								genres => [map {$_->description} $movie->genres]
			})->format_movie_info;
			
			push @{$history_hash->{movies}}, $movie_info;
		}
		$history_hash->{movie_count} = scalar @{$history_hash->{movies}};

		push @{$rv->{results}}, $history_hash;
	}
	$rv->{count} = scalar @{$rv->{results}};

	return $rv;
}

#Method: format_movies_response
#Arguments: \@movie_list, \@genres, \%conditions
#Return value: \%movies_list
#Gets the movie list, matched genres and weather conditions and formats them 
#into a structure suitable to be returned to the top level handler
sub __format_movies_response {
	my $self = shift;
	my $movie_list = shift;
	my $genres = shift;
	my $conditions = shift;

	my $response = {
		conditions => {
			temperature => $conditions->{temperature},
			weather => $conditions->{weather}
		},
		matched_genres => $genres,
		results => {
			count => scalar @$movie_list,
			movies => $movie_list
		}
	};

	return $response;
}

#Method: __get_movies
#Arguments: \@genres
#Returns: \@movies
#Gets an array ref of genres, fetches all movies from RottenTomatoes and 
#returns a movies array ref containing all the movies that match 
#any of the provided genres
sub __get_movies {
	my $self = shift;
	my $genres = shift;

	my $rotten = MovieSuggest::RottenTomatoes->new;
	my $movies = $rotten->get_all_movies;
	my $movies_list = $self->__filter_movies($movies, $genres);
	
	return $movies_list;
}

#Method: __filter_movies
#Arguments: \@movies, \@genres
#Return: \@movie_list
#Gets an array ref of movies and another one of genres 
#and returns all the movies in the movies array ref 
#that are at least of one of the provided genres
sub __filter_movies {
	my $self = shift;
	my $movies = shift;
	my $genres = shift;

	my @movie_list;

	MOVIE: foreach my $movie (@$movies) {
		foreach my $genre (@$genres) {
			if ( $movie->is_of_genre($genre) ) {
				push @movie_list, $movie->format_movie_info;
				next MOVIE;
			}
		}
	}

	return \@movie_list;
}

#Method: __save_history
#Arguments: $user, \%conditions, \@movie_list
#Returns: 1
#Gets the user object, weather conditions hashref and movie list array ref
#and saves the results into the historical table
sub __save_history {
	my $self = shift;
	my $user = shift;
	my $conditions = shift;
	my $movie_list = shift;

	my $schema = MovieSuggest::Schema->get_schema;
	my $history_rs = $schema->resultset('History');
	my $history_row = $history_rs->create({
		user_id => $user->id,
		weather => $conditions->{weather},
		temperature => $conditions->{temperature}
	});

	my $movie_rs = $schema->resultset('Movie');
	foreach my $movie (@$movie_list) {
		my $movie_row = $movie_rs->find_or_create($movie, {key => "movie_id"});
		$movie_row->add_to_histories($history_row);
	}

	return 1;
}



1;