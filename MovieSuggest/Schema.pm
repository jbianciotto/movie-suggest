package MovieSuggest::Schema;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Schema';

__PACKAGE__->load_namespaces;


# Created by DBIx::Class::Schema::Loader v0.07010 @ 2014-04-03 16:28:11
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:InXPMiOlbZWBBQ+NVbTr9w

# You can replace this text with custom code or comments, and it will be preserved on regeneration
use constant CONF_FILE => "/home/javier/workspace/movie-suggest/conf/movie-suggest.conf";
my $schema;

sub get_schema {
	my $class = shift;
	if (!$schema) {
		my $conf = $class->__read_conf();
		$schema = MovieSuggest::Schema->connect("dbi:mysql:movie_suggest", $conf->{db_user}, $conf->{db_password}); 
	}
	return $schema;
}

sub __read_conf {
	my $class = shift;

	open(my $fh, '<', CONF_FILE) || die "Cant open configuration file : $!"; 
	my @lines = <$fh>;
	close($fh);

	my %conf;
	chomp(@lines);
	foreach my $line (@lines) {
		my ($key, $value) = split '=', $line;
		$conf{$key}=$value;
	}

	return \%conf;
}


1;
