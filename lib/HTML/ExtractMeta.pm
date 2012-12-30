package HTML::ExtractMeta;
use Moose;

our $VERSION = '0.01';

use Mojo::DOM;
use Mojo::Util qw( squish );

has 'html' => ( isa => 'Str', is => 'ro', required => 1, default => 1, reader => 'get_html' );

has 'DOM'         => ( isa => 'Mojo::DOM',     is => 'ro', lazy_build => 1, reader => 'get_DOM'         );
has 'title'       => ( isa => 'Str',           is => 'ro', lazy_build => 1, reader => 'get_title'       );
has 'description' => ( isa => 'Str',           is => 'ro', lazy_build => 1, reader => 'get_description' );
has 'url'         => ( isa => 'Str',           is => 'ro', lazy_build => 1, reader => 'get_url'         );
has 'image_url'   => ( isa => 'Str',           is => 'ro', lazy_build => 1, reader => 'get_image_url'   );
has 'site_name'   => ( isa => 'Str',           is => 'ro', lazy_build => 1, reader => 'get_site_name'   );
has 'type'        => ( isa => 'Str',           is => 'ro', lazy_build => 1, reader => 'get_type'        );
has 'keywords'    => ( isa => 'ArrayRef[Str]', is => 'ro', lazy_build => 1, reader => 'get_keywords'    );

sub _build_DOM {
    my $self = shift;

    my $DOM = Mojo::DOM->new();
    $DOM->parse( $self->get_html() );
    $DOM->charset( 'UTF-8' );

    return $DOM;
}

sub _get_element_text {
    my $self = shift;
    my $name = shift;

    if ( my $DOM = $self->get_DOM() ) {
        if ( my $Element = $DOM->at($name) ) {
            return squish( $Element->text() );
        }
    }

    return '';
}

sub _get_meta_content {
    my $self  = shift;
    my $metas = shift || [];

    if ( my $DOM = $self->get_DOM() ) {
        foreach my $meta ( @{$metas} ) {
            foreach ( qw(name property) ) {
                if ( my $Element = $DOM->at('meta[' . $_ . '="' . $meta . '"]') ) {
                    if ( my $content = $Element->attrs('content') ) {
                        return squish( $content );
                    }
                }
            }
        }
    }

    return '';
}

sub _build_title {
    my $self = shift;

    my @metas = (
        'title',
        'og:title',
        'twitter:title',
    );

    return $self->_get_meta_content( \@metas ) || $self->_get_element_text( 'title' ) || '';
}

sub _build_description {
    my $self = shift;

    my @metas = (
        'description',
        'og:description',
        'twitter:description',
    );

    return $self->_get_meta_content( \@metas ) || $self->_get_element_text( 'description' ) || '';
}

sub _build_url {
    my $self = shift;

    my @metas = (
        'og:url',
        'twitter:url',
    );

    return $self->_get_meta_content( \@metas );
}

sub _build_image_url {
    my $self = shift;

    my @metas = (
        'og:image',
        'twitter:image',
    );

    return $self->_get_meta_content( \@metas );
}

sub _build_site_name {
    my $self = shift;

    my @metas = (
        'og:site_name',
        'twitter:site',
    );

    return $self->_get_meta_content( \@metas );
}

sub _build_type {
    my $self = shift;

    my @metas = (
        'og:type',
    );

    return $self->_get_meta_content( \@metas );
}

sub _build_keywords {
    my $self = shift;

    my @metas = (
        'keywords',
    );

    return [ split(/\s*,\s*/, $self->_get_meta_content(\@metas)) ];
}

__PACKAGE__->meta()->make_immutable();

1;