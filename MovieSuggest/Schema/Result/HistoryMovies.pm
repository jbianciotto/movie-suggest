package MovieSuggest::Schema::Result::HistoryMovies;


use base qw/DBIx::Class::Core/;

__PACKAGE__->table('history_movies');
__PACKAGE__->add_columns(qw/history_id movie_id/);
__PACKAGE__->set_primary_key(qw/history_id movie_id/);

__PACKAGE__->belongs_to(movie, "MovieSuggest::Schema::Result::Movie", "movie_id");
__PACKAGE__->belongs_to(history, "MovieSuggest::Schema::Result::History", "history_id");

1;