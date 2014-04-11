package List;

use strict;

use MovieSuggest::Schema;
use Weather;
use RottenTomatoes;
use DateTime;

use Data::Dumper;

sub new {
	my $class = shift;
	my $self = {};

	bless $self, $class;

	return $self;
}

sub get_suggestions {
	my ($self, $username) = @_;
	print STDERR "Fetching suggestions for user: $username\n";

	my $schema = MovieSuggest::Schema->get_schema;
	my $user_rs = $schema->resultset('User');


	my $user = $user_rs->find({username => $username}, {key => "username"});

	#1) Get user location
	my $location = $user->location;

	#2) Grab user preferred genres
	my @user_genres = map {$_->description} $user->genres;
	print STDERR "user genres:".Dumper(\@user_genres);

	#3) Grab weather conditions
	my $conditions = Weather->new->get_conditions($location);
	print STDERR "Condition:".Dumper($conditions);

	#4) Get matching genres for conditions
	my @condition_genres = Weather->matching_genres($conditions);
	print STDERR "conditions genres:".Dumper(\@condition_genres);

	#5) Intersect user and weather genres
	my %user_genres=map{$_ =>1} @user_genres;
	my @genres = grep( $user_genres{$_}, @condition_genres);
	print STDERR "matching genres:".Dumper(\@genres);

	#6) Get movies 
	my $movies_list = $self->get_movies(\@genres);

  	$self->save_history($user,$conditions,$movies_list);

	return $self->format_movies_response($movies_list, \@genres, $conditions);
}

sub format_movies_response {
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

sub get_movies {
	my $self = shift;
	my $genres = shift;

	my $rotten = RottenTomatoes->new;
	my $movies = $rotten->get_all_movies;
	my $movies_list = $self->filter_movies($movies, $genres);
	
	return $movies_list;
}


sub filter_movies {
	my $self = shift;
	my $movies = shift;
	my $genres = shift;

	my @list;

	foreach my $genre (@$genres) {
		foreach my $movie (@$movies) {
			if ( $movie->is_of_genre($genre) ) {
				push @list, $movie->format_movie_info;
				next;
			}
		}
	}

	return \@list;
}

sub get_history {
	my $self = shift;
	my $username = shift;

	my $schema = MovieSuggest::Schema->get_schema;

	my $user_rs = $schema->resultset('User');
	my $user = $user_rs->find({username => $username}, {key => "username"});

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
			my $movie_info = Movie->new({
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

sub save_history {
	my $self = shift;
	my $user = shift;
	my $conditions = shift;
	my $list = shift;

	my $schema = MovieSuggest::Schema->get_schema;
	my $history_rs = $schema->resultset('History');
	my $history_row = $history_rs->create({
		user_id => $user->id,
		weather => $conditions->{weather},
		temperature => $conditions->{temperature}
	});

	my $movie_rs = $schema->resultset('Movie');
	foreach my $movie (@$list) {
		my $movie_row = $movie_rs->find_or_create($movie, {key => "movie_id"});
		$movie_row->add_to_historical($history_row);
	}

	return;
}



1;