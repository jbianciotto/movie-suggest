package MovieSuggest::Config;

use constant CONFIG_VALUES => {
	DB_USER => "root",
	DB_PASSWORD => "password"
};

sub db_user {
	return CONFIG_VALUES->{DB_USER};
}

sub db_password {
	return CONFIG_VALUES->{DB_PASSWORD};
}

1;