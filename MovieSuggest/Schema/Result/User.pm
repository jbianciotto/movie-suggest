package MovieSuggest::Schema::Result::User;


use base qw/DBIx::Class::Core/;

__PACKAGE__->table('user');
__PACKAGE__->add_columns(qw/ id username location /);
__PACKAGE__->set_primary_key('id');
__PACKAGE__->add_unique_constraint( username => [ qw/username/ ] );

#Location table relation
__PACKAGE__->belongs_to( location, "MovieSuggest::Schema::Result::Location", "location");

#UserGenre table relation
__PACKAGE__->has_many(user_genres, "MovieSuggest::Schema::Result::UserGenres", "user_id" );
__PACKAGE__->many_to_many(genres, user_genres, "genre" );

1;