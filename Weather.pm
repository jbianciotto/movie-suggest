package Weather;

use strict;

use Request;

use constant WHEATER_UNDERGROUND_KEY => "a3cd20ad7931f73f";
use constant WHEATER_CONDITION_BASE_URL => 
	"http://api.wunderground.com/api/".WHEATER_UNDERGROUND_KEY."/conditions";

use constant HOT_THRESHOLD => 29;
use constant COLD_THRESHOLD => 10;
use constant HOT => "Hot";
use constant REGULAR => "Regular";
use constant COLD => "Cold";
use constant CLEAR => "Clear";
use constant CLOUDY => "Cloudy";
use constant RAINY => "Rainy";
use constant SNOWY => "Snowy";

use constant CONDITIONS_MAPPING => {
	Clear => {
		Hot => ["Action & Adventure", "Art House & International", "Comedy"],
		Regular => ["Animation", "Drama", "Classics", "Science Fiction & Fantasy","Mystery & Suspense"],
		Cold => ["Action & Adventure", "Documentary", "Science Fiction & Fantasy"]
	},
	Cloudy => {
		Hot => ["Action & Adventure", "Comedy", "Kids & Family", ],
		Regular => ["Animation", "Classics", "Kids & Family", "Science Fiction & Fantasy"],
		Cold => ["Action & Adventure", "Horror", "Documentary", "Mystery & Suspense"]
	},
	Rainy => {
		Hot => [ "Action", "Comedy", "Drama"],
		Regular => ["Action", "Romantic", "Horror", "Classics", "Drama"],
		Cold => ["Romance", "Faith & Spirituality", "Drama", "Mystery & Suspense"]
	},
	Snowy => {
		Hot => [ "Action", "Comedy", "Musical & Performing Arts"],
		Regular => ["Action", "Art House & International", "Musical & Performing Arts"],
		Cold => ["Romance", "Faith & Spirituality", "Musical & Performing Arts"]
	}
};


sub new {
	my $class = shift;
	my $self = {};

	bless $self, $class;

	return $self;
}

#Method: get_conditions
#Arguments: $location
#Returns: \%conditions
#Queries WeatherUnderground API and returns the weather conditions
#in the provided location.
sub get_conditions {
	my $self = shift;
	my $location = shift;

	my $base_url = WHEATER_CONDITION_BASE_URL;
	my $url = $base_url . "/q/".$location->region ."/".$location->city.".json"; 

	my $response = Request->get($url);

	my $json_response = JSON::Syck::Load($response);
	if ($json_response->{response}->{results}) {
		#API returned more than 1 result for the location, get the 1st one
		$url = $base_url . $json_response->{response}->{results}->[0]->{l}.".json";
		$response = Request->get($url);
		$json_response = JSON::Syck::Load($response);
	}

	my $conditions;
	if ($json_response->{response}->{error}) {
		$conditions = "ERROR: ".$json_response->{response}->{error}->{description};
	} else {
		$conditions = $self->__format_conditions($json_response->{current_observation});
	}

	return $conditions;
}

#Method: __format_conditions
#Arguments: \%observation
#Returns: \%conditions
#Extracts weather conditions from a weather observation 
#obtained from WeatherUnderground API
sub __format_conditions {
	my $self = shift;
	my $observation = shift;

	my $conditions = {};
	
	#Temperature
	my $obs_temp = $observation->{temp_c};
	if ($obs_temp > HOT_THRESHOLD) {
		$conditions->{temperature} = HOT;
	} elsif ($obs_temp > COLD_THRESHOLD && $obs_temp <= HOT_THRESHOLD) {
		$conditions->{temperature} = REGULAR;
	} else {
		$conditions->{temperature} = COLD;
	}
	
	#Weather
	my $obs_weather = $observation->{weather};
	if ($obs_weather eq 'Clear') {
		$conditions->{weather} = CLEAR;
	} elsif ($obs_weather =~ /Cloud|Overcast/) {
		$conditions->{weather} = CLOUDY;
	} elsif ($obs_weather =~ /Rain|Thunderstorm|Drizzle/) {
		$conditions->{weather} = RAINY;
	} elsif ($obs_weather =~ /Snow|Ice/) {
		$conditions->{weather} = SNOWY;
	}

	return $conditions;
}

#Method: matching_genres
#Arguments: \%conditions
#Returns: \@genres
#Returns an array ref of genres related to the provided weather conditions
sub matching_genres {
	my $self = shift;
	my $conditions = shift;

	my $temperature = $conditions->{temperature};
	my $weather= $conditions->{weather};

	return @{CONDITIONS_MAPPING->{$weather}->{$temperature}};
}



1;