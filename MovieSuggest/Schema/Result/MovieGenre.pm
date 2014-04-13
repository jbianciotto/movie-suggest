package MovieSuggest::Schema::Result::MovieGenre;


use base qw/DBIx::Class::Core/;

__PACKAGE__->table('movie_genres');
__PACKAGE__->add_columns( qw/movie_id genre_id/);
__PACKAGE__->set_primary_key( qw/movie_id genre_id/);

__PACKAGE__->belongs_to(movie, "MovieSuggest::Schema::Result::User", "movie_id");
__PACKAGE__->belongs_to(genre, "MovieSuggest::Schema::Result::Genres", "genre_id");

1;