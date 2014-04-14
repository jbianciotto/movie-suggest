use strict;

use Test::More tests => 1;
use Test::Deep;
use Test::MockModule;

use MovieSuggest::Schema;
use MovieSuggest::Suggestions; 
use MovieSuggest::Weather;
use MovieSuggest::RottenTomatoes;
use MovieSuggest::User;
use MovieSuggest::Movie;

use constant TEST_USERNAME => "testingUser";
use constant MOVIES_MOCK => [
	MovieSuggest::Movie->new({id => "5", title => "Movie N5", genres => ["Drama"]}),
	MovieSuggest::Movie->new({id => "9", title => "Movie N9", genres => ["Animation"]}),
	MovieSuggest::Movie->new({id => "7", title => "Movie N7", genres => ["Classics"]}),
	MovieSuggest::Movie->new({id => "2", title => "Movie N2", genres => ["Classics","Animation"]})
];

#Start mocking
my $weather_mock = Test::MockModule->new("MovieSuggest::Weather");
$weather_mock->mock('get_conditions', sub {
	return {weather => 'Clear', temperature => 'Hot'};
});
$weather_mock->mock('matching_genres', sub { return ("Animation"); });

my $rotten_mock = Test::MockModule->new("MovieSuggest::RottenTomatoes");
$rotten_mock->mock('get_all_movies', sub { return MOVIES_MOCK; });

*MovieSuggest::Suggestions::__save_history = sub { return; };
#End mocking

#Start testing
my $users = MovieSuggest::User->new;
my $user = $users->create_user(TEST_USERNAME, "fakeCountry", "fakeCity", ["Animation"]);

my $suggestions = MovieSuggest::Suggestions->new; 
my $got = $suggestions->get_suggestions(TEST_USERNAME);
my $expected = {
	conditions => { weather => 'Clear', temperature =>  'Hot' },
	matched_genres => bag("Animation"),
	results => {
		count => 2,
		movies => [
            {
				movie_id => '9',
                genres => bag('Animation'),
				title => 'Movie N9'
			},
            {
            	movie_id => '2',
            	genres => bag('Animation', 'Classics'),
                title => 'Movie N2'
            }
		]
	}
};

cmp_deeply($got, $expected, "Movie suggestions list test");
#End testing

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