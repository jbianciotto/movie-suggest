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
		return { error => "An user with that username already exists"};
	}

	#Check location is already populated, get or create it
	my $location = $location_rs->search({region => $region, city => $city},{ rows => 1})->single;
	if (!$location) {
		$location = $location_rs->create({region => $region, city => $city});
	}

	my $error = $self->check_genres($genre_rs, $preferred_genres);
	return $error if ($error);
	
	#Create user
	my $user = $user_rs->create(
		{ username => $username, location => $location->id }
	);

	#Add genres
	foreach my $preferred_genre (@$preferred_genres) {
		my $genre = $genre_rs->find(
			{description => $preferred_genre}, {key => "description"}
		);
		$user->add_to_genres($genre);
	}

	return $self->get_user_info($user);
}

sub update_location {
	my $self = shift;
	my $username = shift;
	my $region = shift;
	my $city = shift;

	my $schema = MovieSuggest::Schema->get_schema;
	my $user_rs = $schema->resultset('User');
	my $user = $user_rs->find({username => $username},{key => "username"});

	my $location_rs = $schema->resultset('Location');

	#Check location is already populated, get or create it
	my $location = $location_rs->search({region => $region, city => $city},{ rows => 1})->single;
	if (!$location) {
		$location = $location_rs->create({region => $region, city => $city});
	}

	$user->location($location);
	$user->update();

	return $self->get_user_info($user);
}

sub update_genres {
	my $self = shift;
	my $username = shift;
	my $genres = shift;

	my $schema = MovieSuggest::Schema->get_schema;
	my $user_rs = $schema->resultset('User');
	my $genre_rs = $schema->resultset('Genres');

	my $user = $user_rs->search( { username => $username}, {rows => 1})->single;
	unless ($user) {
		return { error => "Invalid user provided"};
	}

	my $error = $self->check_genres($genre_rs, $genres);
	return $error if ($error);
	
	my @new_genres = $genre_rs->search({ description => { '-in' => $genres }});
	$user->set_genres(\@new_genres);

	return $self->get_user_info($user);
}


sub get_user_info {
	my $self = shift;
	my $user = shift;

	my $user_info = { 
		username => $user->username, 
		location => {
			"country/state" => $user->location->region,
			city => $user->location->city
		},
		preferred_genres => [ map {$_->description} $user->genres ]
	};

	return $user_info;
}

sub check_genres {
	my $self = shift;
	my $genre_rs = shift;
	my $genres = shift;

	#Check genres are valid
	foreach my $genre (@$genres) {
		my $genre_row = $genre_rs->find(
			{description => $genre}, {key => "description"}
		);
		if (!$genre_row) {
			return { 
				error => 'Invalid genre ("'.$genre.'") provided',
				valid_genres => [map {$_->description} $genre_rs->all]
			};
		}
	}

	return undef;
}

1;
