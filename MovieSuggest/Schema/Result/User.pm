package MovieSuggest::Schema::Result::User;


use base qw/DBIx::Class::Core/;

__PACKAGE__->table('user');
__PACKAGE__->add_columns(qw/ id username location /);
__PACKAGE__->set_primary_key('id');
__PACKAGE__->add_unique_constraint( username => [ qw/username/ ] );
#__PACKAGE__->belongs_to( location, "MovieSuggest::Schema::Result::Location", "id");

1;