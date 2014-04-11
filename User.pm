package User;

use strict;

use MovieSuggest::Schema;

sub new {
	my $class = shift;
	my $self = {};

	bless $self, $class;

	return $self;
}

#Method: create_iser
#Arguments: $username, $region, $city, \@genres
#Returns: \%user_info || \%error
#Creates a new user with the values provided
#Returns updated \%user_info structure or error hashref
sub create_user {
	my $self = shift;
	my $username = shift;
	my $region = shift; #Country/US-State
	my $city = shift; 
	my $preferred_genres = shift;

	my $schema = MovieSuggest::Schema->get_schema;
	my $user_rs = $schema->resultset('User');
	my $location_rs = $schema->resultset('Location');
	my $genre_rs = $schema->resultset('Genres');
	my $user_genre_rs = $schema->resultset('UserGenres');

	#1) Check username does not already exists
	my $user = $user_rs->search( { username => $username}, {rows => 1})->single;
	if ($user) {
		return { error => "An user with that username already exists"};
	}

	#2) Check location is already populated, get or create it
	my $location = $location_rs->search({region => $region, city => $city},{ rows => 1})->single;
	if (!$location) {
		$location = $location_rs->create({region => $region, city => $city});
	}

	#3) Check all preferred genres are valid
	my $error = $self->__check_genres($genre_rs, $preferred_genres);
	return $error if ($error);
	
	#4) Create user
	my $user = $user_rs->create(
		{ username => $username, location => $location->id }
	);

	#5) Add preferred genres
	foreach my $preferred_genre (@$preferred_genres) {
		my $genre = $genre_rs->find(
			{description => $preferred_genre}, {key => "description"}
		);
		$user->add_to_genres($genre);
	}

	#6) Return newly created user information
	return $self->__get_user_info($user);
}

#Method: update_location
#Arguments: $username, $region, $city
#Returns: \%user_info
#Updates location for the given username. 
#Returns updated \%user_info structure or error hashref
sub update_location {
	my $self = shift;
	my $username = shift;
	my $region = shift;
	my $city = shift;

	my $schema = MovieSuggest::Schema->get_schema;
	my $user_rs = $schema->resultset('User');
	my $user = $user_rs->find({username => $username},{key => "username"});

	my $location_rs = $schema->resultset('Location');

	my $location = $location_rs->search({region => $region, city => $city},{ rows => 1})->single;
	if (!$location) {
		$location = $location_rs->create({region => $region, city => $city});
	}

	$user->location($location);
	$user->update();

	return $self->__get_user_info($user);
}


#Method: update_genres
#Arguments: $username, \@genres
#Returns: \%user_info
#Updates preferred genres for the given username. 
#Returns updated \%user_info structure or error hashref
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

	my $error = $self->__check_genres($genre_rs, $genres);
	return $error if ($error);
	
	my @new_genres = $genre_rs->search({ description => { '-in' => $genres }});
	$user->set_genres(\@new_genres);

	return $self->__get_user_info($user);
}

#Method: __get_user_info
#Arguments: $user
#Returns: \%user_info
#Returns information of the provided user in an easy readable structure
sub __get_user_info {
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


#Method: __check_genres
#Arguments: $genre_rs, \@genres
#Returns: undef || \%error
#Checks that all the provided genres are valid.
#Returns undef in success or error hashref if failure
sub __check_genres {
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
