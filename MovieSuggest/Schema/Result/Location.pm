package MovieSuggest::Schema::Result::Location;


use base qw/DBIx::Class::Core/;

__PACKAGE__->table('locations');
__PACKAGE__->add_columns(qw/ id region city/);
__PACKAGE__->set_primary_key('id');

1;