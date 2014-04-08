package MovieSuggest::Schema::Result::History;


use base qw/DBIx::Class::Core/;

__PACKAGE__->table('suggestions_history');
__PACKAGE__->add_columns(qw/id user_id weather date/);
__PACKAGE__->set_primary_key('id');
#__PACKAGE__->add_unique_constraint( username => [ qw/username/ ] );

#Historical table relation
__PACKAGE__->has_many(movie_sets, "MovieSuggest::Schema::Result::MovieSet", "movie_set_id" );
__PACKAGE__->many_to_many(movies, movie_sets, "movie" );

1;