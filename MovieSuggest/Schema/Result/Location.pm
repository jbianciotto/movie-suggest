package MovieSuggest::Schema::Result::Location;


use base qw/DBIx::Class::Core/;

__PACKAGE__->table('location');
__PACKAGE__->add_columns(qw/ id region city/);
__PACKAGE__->set_primary_key('id');
#__PACKAGE__->add_unique_constraint( description => [ qw/description/ ] );
#__PACKAGE__->has_many( users, "MovieSuggest::Schema::Result::User", "location");


1;