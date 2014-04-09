package Weather;

use strict;

use Request;

use Data::Dumper;

use constant WHEATER_UNDERGROUND_KEY => "a3cd20ad7931f73f";
use constant WHEATER_CONDITION_BASE_URL => 
	"http://api.wunderground.com/api/".WHEATER_UNDERGROUND_KEY."/conditions/q/";

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
		Regular => ["Animation", "Drama", "Classics", "Science Fiction & Fantasy"],
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

sub get_conditions {
	my $self = shift;
	my $location = shift;

	my $conditions = $self->weather_request($location);

	return $conditions;
}


#TODO: check lo que pasa con mas de un resultado (ejemplo: BuenosAires)
sub weather_request {
	my $self = shift;
	my $location = shift;

	print "Fetching weather conditions in ".$location->region."/".$location->city."\n";

	my $url = WHEATER_CONDITION_BASE_URL;
	$url .= $location->region ."/".$location->city.".json"; 

	my $response = Request->new->do_request($url);

	my $conditions;
	if ($response !~ /^ERROR/) {
		my $json_response = JSON::Syck::Load($response);
		# print Dumper($json_response);
		if ($json_response->{response}->{error}) {
			$conditions = "ERROR: ".$json_response->{response}->{error}->{description};
		} else {
			$conditions = $self->format_conditions($json_response->{current_observation});
		}

	} else {
		$conditions = $response;
	}

	return $conditions;
}

sub format_conditions {
	my $self = shift;
	my $observation = shift;

	my $conditions = {};
	
	#Temperature
	my $obs_temp = $observation->{temp_c};
	if ($obs_temp > 29) {
		$conditions->{temperature} = HOT;
	} elsif ($obs_temp > 10 && $obs_temp <= 29) {
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

sub matching_genres {
	my $self = shift;
	my $conditions = shift;

	my $temperature = $conditions->{temperature};
	my $weather= $conditions->{weather};

	return @{CONDITIONS_MAPPING->{$weather}->{$temperature}};
}



1;