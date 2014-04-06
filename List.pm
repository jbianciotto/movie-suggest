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
	my ($self, $user) = @_;
	print "Fetching suggestions for user: $user\n";

	my $schema = MovieSuggest::Schema->get_schema;
	my $user_rs = $schema->resultset('User');

	my $list = {};

	my $user = $user_rs->find({username => $user}, {key => "username"});

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
				$list->{$movie->id} = $movie->title;
				next;
			}
		}
	}
 
 print "LIST:".Dumper($list);
	return $list;
}

1;