package MovieSuggest::Schema::Result::MovieSet;


use base qw/DBIx::Class::Core/;

__PACKAGE__->table('movie_set');
__PACKAGE__->add_columns(qw/movie_set_id movie_id/);
__PACKAGE__->set_primary_key(qw/movie_set_id movie_id/);

__PACKAGE__->belongs_to(movie, "MovieSuggest::Schema::Result::Movie", "movie_id");
__PACKAGE__->belongs_to(history, "MovieSuggest::Schema::Result::History", "movie_set_id");

1;