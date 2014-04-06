package Movie;

use strict;

sub new {
	my $class = shift;
	my $movie_info = shift;
	my $self = {};

	bless $self, $class;

	$self->init($movie_info);

	return $self;
}

sub init {
	my $self = shift;
	my $movie_info = shift;

	$self->{ID} = $movie_info->{id};
	$self->{TITLE} = $movie_info->{title};
	$self->{GENRES} = $movie_info->{genres};
}

sub title {
	my ($self, $title) = @_;
	$self->{TITLE} if ($title);
	return $self->{TITLE};
}

sub id {
	my ($self, $id) = @_;
	$self->{ID} if ($id);
	return $self->{ID};
}

sub genres {
	my ($self, $genres) = @_;
	$self->{GENRES} if ($genres);
	return $self->{GENRES};
}

sub is_of_genre {
	my ($self, $genre) = @_;

	foreach (@{$self->genres}) {
		return 1 if ($_ eq $genre);
	}

	return 0;
}

1;