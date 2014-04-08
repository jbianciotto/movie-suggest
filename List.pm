package List;

use strict;

use MovieSuggest::Schema;
use Weather;
use RottenTomatoes;

use Data::Dumper;

sub new {
	my $class = shift;
	my $self = {};

	bless $self, $class;

	return $self;
}


sub get_suggestions {
	my ($self, $username) = @_;
	print "Fetching suggestions for user: $username\n";

	my $schema = MovieSuggest::Schema->get_schema;
	my $user_rs = $schema->resultset('User');

	my @list;

	my $user = $user_rs->find({username => $username}, {key => "username"});

	#1) Get user location
	my $location = $user->location;

	#2) Grab user preferred genres
	my @user_genres = map {$_->description} $user->genres;
	print "user genres:".Dumper(\@user_genres);

	#3) Grab weather conditions
	my $conditions = Weather->new->get_conditions($location);
	print "Condition:".Dumper($conditions);

	#4) Get matching genres for conditions
	my @condition_genres = Weather->matching_genres($conditions);
	print "conditions genres:".Dumper(\@condition_genres);

	#5) Intersect user and weather genres
	my %user_genres=map{$_ =>1} @user_genres;
	my @genres = grep( $user_genres{$_}, @condition_genres);
	print "matching genres:".Dumper(\@genres);

	#6) Get movies in theaters
	my $movies = RottenTomatoes->new->get_all_movies;

	#7) Filter movies that match user genres
	foreach my $genre (@genres) {
		foreach my $movie (@$movies) {
			if ( $movie->is_of_genre($genre) ) {
				push @list, {movie_id => $movie->id, title => $movie->title};
				next;
			}
		}
	}
 
  	$self->save_history($user,$conditions,\@list);
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
		username => $username,
		history => []
	};
	foreach my $history ($histories->all) {
		my $hash = {};
		$hash->{id} = $history->id;
		$hash->{weather} = $history->weather;
		$hash->{date} = $history->date;
		$hash->{movies} = [];

#		print Dumper($history->movies);
		foreach my $movie ( $history->movies) {
			push @{$hash->{movies}}, {id =>$movie->movie_id, title => $movie->title};
		}

		push @{$rv->{history}}, $hash;
	}

	return $rv;
}

sub save_history {
	my $self = shift;
	my $user = shift;
	my $conditions = shift;
	my $list = shift;

	my $weather = $conditions->{weather}."/".$conditions->{temperature};
#print Dumper([$user, $conditions, $list]);
	my $schema = MovieSuggest::Schema->get_schema;
	my $history_rs = $schema->resultset('History');
	my $history_row = $history_rs->create({
		user_id => $user->id,
		weather => $weather,
	});

	my $movie_rs = $schema->resultset('Movie');
	foreach my $movie (@$list) {
		my $movie_row = $movie_rs->find_or_create($movie, {key => "movie_id"});
		$movie_row->add_to_historical($history_row);
	}

	return;
}



1;