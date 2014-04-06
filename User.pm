package User;

use strict;

use MovieSuggest::Schema;

use Data::Dumper;

sub new {
	my $class = shift;
	my $self = {};

	bless $self, $class;

	return $self;
}

sub create_user {
	my $self = shift;
	my $username = shift;
	my $region = shift; #Country/US-State
	my $city = shift; #City
	my $preferred_genres = shift;

	my $schema = MovieSuggest::Schema->get_schema;
	my $user_rs = $schema->resultset('User');
	my $location_rs = $schema->resultset('Location');
	my $genre_rs = $schema->resultset('Genres');
	my $user_genre_rs = $schema->resultset('UserGenres');

	#First check username does not already exists
	my $user = $user_rs->search( { username => $username}, {rows => 1})->single;
	if ($user) {
		return "user already exists";
	}

	#Check location is already populated, get or create it
	my $location = $location_rs->search({region => $region, city => $city},{ rows => 1})->single;
	if (!$location) {
		$location = $location_rs->create({region => $region, city => $city});
	}

	#Create user
	my $user = $user_rs->create(
		{ username => $username, location => $location->id }
	);

	#Check genres, get ids or create them
	foreach my $preferred_genre (@$preferred_genres) {
		my $genre = $genre_rs->find_or_create(
			{description => $preferred_genre}, {key => "description"}
		);

		$user_genre_rs->create({user_id => $user->id, genre_id => $genre->id});
	}

	return 1;
}


1;