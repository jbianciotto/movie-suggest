package MovieSuggest::Schema::Result::UserGenres;


use base qw/DBIx::Class::Core/;

__PACKAGE__->table('user_genres');
__PACKAGE__->add_columns(qw/ user_id genre_id/);
__PACKAGE__->set_primary_key(('user_id','genre_id'));


1;