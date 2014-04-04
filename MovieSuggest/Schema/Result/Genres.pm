package MovieSuggest::Schema::Result::Genres;


use base qw/DBIx::Class::Core/;

__PACKAGE__->table('genres');
__PACKAGE__->add_columns(qw/ id description/);
__PACKAGE__->set_primary_key('id');
__PACKAGE__->add_unique_constraint( description => [ qw/description/ ] );


1;