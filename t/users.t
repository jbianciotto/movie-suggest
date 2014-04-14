use strict;

use Test::More tests => 4;
use Test::Deep;

use MovieSuggest::Schema;
use MovieSuggest::User; 

use constant TEST_USERNAME => "testingUser";

my $users = MovieSuggest::User->new;

# Test #1
my $user = $users->create_user(TEST_USERNAME, "fakeCountry", "fakeCity", ["Animation", "Drama"]);
my $expected = {
    location => {
        city => "fakeCity",
        "country/state" => "fakeCountry"
    },
    preferred_genres => bag("Animation","Drama"),
    username => "testingUser", 
};
cmp_deeply($user,$expected, "User creation test");

# Test #2
$user = $users->create_user(TEST_USERNAME, "fakeCountry", "fakeCity", ["Animation", "Drama"]);
$expected = { error => "An user with that username already exists" };
cmp_deeply($user,$expected, "Existent user test");

# Test #3
$user = $users->update_location(TEST_USERNAME, "fakeCountry2", "fakeCity2");
$expected = {
    location => {
        city => "fakeCity2",
        "country/state" => "fakeCountry2"
    },
    preferred_genres => bag("Animation","Drama"),
    username => "testingUser", 
};
cmp_deeply($user,$expected, "Update location");

# Test #4
$user = $users->update_genres(TEST_USERNAME, ["Classics"]);
$expected = {
    location => {
        city => "fakeCity2",
        "country/state" => "fakeCountry2"
    },
    preferred_genres => bag("Classics"),
    username => "testingUser", 
};
cmp_deeply($user,$expected, "Update genres");

clean_up();


sub clean_up {
	my $schema = MovieSuggest::Schema->get_schema;
	$user = $schema->resultset('User')->find(
			{username => TEST_USERNAME}, {key => "username"}
		);
	$user->delete_related("user_genres");
	$user->delete;
	$user->location->delete;

	$schema->resultset('Location')->search(
		{region => "fakeCountry", city => "fakeCity"} 
	)->delete;
}
