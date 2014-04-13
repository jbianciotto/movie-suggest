package MovieSuggest::Schema::Result::Genres;


use base qw/DBIx::Class::Core/;

__PACKAGE__->table('genres');
__PACKAGE__->add_columns(qw/id description/);
__PACKAGE__->set_primary_key('id');
__PACKAGE__->add_unique_constraint( description => [ qw/description/ ] );

#Relationship to user
__PACKAGE__->has_many(user_genres, "MovieSuggest::Schema::Result::UserGenres", "genre_id" );
__PACKAGE__->many_to_many(users, user_genres, "user" );

#Relationship to movies
__PACKAGE__->has_many(movie_genres, "MovieSuggest::Schema::Result::MovieGenre", "genre_id" );
__PACKAGE__->many_to_many(movies, movie_genres, "movie" );

1;