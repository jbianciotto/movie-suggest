package MovieSuggest::Schema::Result::History;


use base qw/DBIx::Class::Core/;

__PACKAGE__->table('history');
__PACKAGE__->add_columns(qw/id user_id weather temperature date/);
__PACKAGE__->set_primary_key('id');

#Historical table relation
__PACKAGE__->has_many(movie_histories, "MovieSuggest::Schema::Result::HistoryMovies", "history_id" );
__PACKAGE__->many_to_many(movies, movie_histories, "movie" );

1;