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
my $schema;

sub get_schema {
	my $class = shift;
	if (!$schema) {
		$schema = MovieSuggest::Schema->connect("dbi:mysql:movie_suggest", "root", "password"); 
	}
	return $schema;
}


1;
