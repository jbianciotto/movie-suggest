package MovieSuggest::Schema::Result::Movie;


use base qw/DBIx::Class::Core/;

__PACKAGE__->table('movie');
__PACKAGE__->add_columns(qw/ movie_id title/);
__PACKAGE__->add_unique_constraint( movie_id => [ qw/movie_id/ ] );
__PACKAGE__->set_primary_key('movie_id');

#MovieGenre table relation
__PACKAGE__->has_many(movie_genres, "MovieSuggest::Schema::Result::MovieGenre", "movie_id" );
__PACKAGE__->many_to_many(genres, movie_genres, "genre" );

#Historical table relation
__PACKAGE__->has_many(movie_sets, "MovieSuggest::Schema::Result::MovieSet", "movie_id" );
__PACKAGE__->many_to_many(historical, movie_sets, "history" );
1;