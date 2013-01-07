package HTML::ExtractMeta;
use Moose;

=head1 NAME

HTML::ExtractMeta - Extract metadata from HTML.

=head1 VERSION

Version 0.06

=cut

our $VERSION = '0.06';

use Mojo::DOM;
use Mojo::Util qw( squish );

=head1 SYNOPSIS

    use HTML::ExtractMeta;

    my $EM = HTML::ExtractMeta->new(
        html => $html, # required
    );

    print "Title       = " . $EM->get_title()       . "\n";
    print "Description = " . $EM->get_description() . "\n";
    print "URL         = " . $EM->get_url()         . "\n";
    print "Site name   = " . $EM->get_site_name()   . "\n";
    print "Type        = " . $EM->get_type()        . "\n";
    print "Locale      = " . $EM->get_locale()      . "\n";
    print "Image URL   = " . $EM->get_image_url()   . "\n";
    print "Image URLs  = " . join( ', ', @{$EM->get_image_urls()} ) . "\n";
    print "Authors     = " . join( ', ', @{$EM->get_authors()} )    . "\n";
    print "Keywords    = " . join( ', ', @{$EM->get_keywords()} )   . "\n";

=head1 DESCRIPTION

HTML::ExtractMeta is a convenience module for extracting useful metadata from
HTML. It doesn't only look for the traditional meta tags, but also the newer
ones like "og:foobar" (OpenGraph) and "twitter:foobar".

=cut

has 'html' => ( isa => 'Str', is => 'ro', required => 1, default => 1, reader => 'get_html' );

has 'DOM'         => ( isa => 'Mojo::DOM',     is => 'ro', lazy_build => 1, reader => 'get_DOM'         );
has 'title'       => ( isa => 'Str',           is => 'ro', lazy_build => 1, reader => 'get_title'       );
has 'description' => ( isa => 'Str',           is => 'ro', lazy_build => 1, reader => 'get_description' );
has 'url'         => ( isa => 'Str',           is => 'ro', lazy_build => 1, reader => 'get_url'         );
has 'image_url'   => ( isa => 'Str',           is => 'ro', lazy_build => 1, reader => 'get_image_url'   );
has 'image_urls'  => ( isa => 'ArrayRef[Str]', is => 'ro', lazy_build => 1, reader => 'get_image_urls'  );
has 'site_name'   => ( isa => 'Str',           is => 'ro', lazy_build => 1, reader => 'get_site_name'   );
has 'type'        => ( isa => 'Str',           is => 'ro', lazy_build => 1, reader => 'get_type'        );
has 'locale'      => ( isa => 'Str',           is => 'ro', lazy_build => 1, reader => 'get_locale'      );
has 'author'      => ( isa => 'Str',           is => 'ro', lazy_build => 1, reader => 'get_author'      );
has 'authors'     => ( isa => 'ArrayRef[Str]', is => 'ro', lazy_build => 1, reader => 'get_authors'     );
has 'keywords'    => ( isa => 'ArrayRef[Str]', is => 'ro', lazy_build => 1, reader => 'get_keywords'    );

=head1 METHODS

=head2 new( %opts )

Returns a new HTML::ExtractMeta instance. Requires HTML as input argument;

    my $EM = HTML::ExtractMeta->new(
        html => $html,
    );

=head2 get_dom()

Returns the Mojo::DOM object for the current HTML.

=cut

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
        my @content = ();
        my %seen    = ();

        foreach my $meta ( @{$metas} ) {
            foreach ( qw(name property itemprop) ) {
                foreach my $Element ( $DOM->find('meta[' . $_ . '="' . $meta . '"]')->each() ) {
                    if ( my $content = $Element->attrs('content') ) {
                        $content = squish( $content );
                        if ( length $content ) {
                            unless ( $seen{$content} ) {
                                push( @content, $content );
                                $seen{ $content }++;
                            }
                        }
                    }
                }
            }
        }

        return \@content;
    }

    return [];
}

=head2 get_title()

Returns the HTML's title.

=cut

sub _build_title {
    my $self = shift;

    my @metas = (
        'title',
        'Title',
        'og:title',
        'twitter:title',
        'DC.title',
    );

    return $self->_get_meta_content( \@metas )->[0] || $self->_get_element_text( 'title' ) || '';
}

=head2 get_description()

Returns the HTML's description.

=cut

sub _build_description {
    my $self = shift;

    my @metas = (
        'description',
        'Description',
        'og:description',
        'twitter:description',
    );

    return $self->_get_meta_content( \@metas )->[0] || $self->_get_element_text( 'description' ) || '';
}

=head2 get_url()

Returns the HTML's URL.

=cut

sub _build_url {
    my $self = shift;

    my @metas = (
        'og:url',
        'twitter:url',
    );

    return $self->_get_meta_content( \@metas )->[0] || '';
}

=head2 get_image_url()

Returns the HTML's first mentioned image URL.

=cut

sub _build_image_url {
    my $self = shift;

    return $self->get_image_urls()->[0] || '';
}

=head2 get_image_urls()

Returns the HTML's image URLs.

=cut

sub _build_image_urls {
    my $self = shift;

    my @metas = (
        'og:image',
        'og:image:url',
        'og:image:secure_url',
        'twitter:image',
    );

    return $self->_get_meta_content( \@metas );
}

=head2 get_site_name()

Returns the HTML's site name.

=cut

sub _build_site_name {
    my $self = shift;

    my @metas = (
        'og:site_name',
        'twitter:site',
    );

    return $self->_get_meta_content( \@metas )->[0] || '';
}

=head2 get_type()

Returns the HTML's type.

=cut

sub _build_type {
    my $self = shift;

    my @metas = (
        'og:type',
    );

    return $self->_get_meta_content( \@metas )->[0] || '';
}

=head2 get_locale()

Returns the HTML's locale.

=cut

sub _build_locale {
    my $self = shift;

    my @metas = (
        'og:locale',
        'inLanguage',
        'Content-Language',
    );

    return $self->_get_meta_content( \@metas )->[0] || '';
}

=head2 get_author()

Returns the HTML's first mentioned author.

=cut

sub _build_author {
    my $self = shift;

    return $self->get_authors()->[0] || '';
}

=head2 get_authors()

Returns the HTML's authors as an array reference.

=cut

sub _build_authors {
    my $self = shift;

    my @metas = (
        'article:author',
        'author',
        'Author',
        'twitter:creator',
        'DC.creator',
    );

    return $self->_get_meta_content( \@metas );
}

=head2 get_keywords()

Returns the HTML's unique keywords as an array reference.

=cut

sub _build_keywords {
    my $self = shift;

    my @metas = (
        'keywords',
    );

    my $keywords = $self->_get_meta_content( \@metas )->[0];
    if ( defined $keywords && length $keywords ) {
        my @keywords = ();
        my %seen     = ();

        foreach my $keyword ( split(/\s*,\s*/, $keywords) ) {
            unless ( $seen{$keyword} ) {
                push( @keywords, $keyword );
                $seen{ $keyword }++;
            }
        }

        return \@keywords;
    }
    else {
        return [];
    }
}

__PACKAGE__->meta()->make_immutable();

=head1 AUTHOR

Tore Aursand, C<< <toreau at gmail.com> >>

=head1 BUGS

Please report any bugs or feature requests to the web interface at L<https://github.com/toreau/HTML-ExtractMeta/issues>.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc HTML::ExtractMeta

You can also look for information at:

=over 4

=item * github (report bugs here)

L<https://github.com/toreau/HTML-ExtractMeta/issues>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/HTML-ExtractMeta>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/HTML-ExtractMeta>

=item * Search CPAN

L<http://search.cpan.org/dist/HTML-ExtractMeta/>

=back

=head1 LICENSE AND COPYRIGHT

Copyright 2013 Tore Aursand.

This program is free software; you can redistribute it and/or modify it
under the terms of the the Artistic License (2.0). You may obtain a
copy of the full license at:

L<http://www.perlfoundation.org/artistic_license_2_0>

Any use, modification, and distribution of the Standard or Modified
Versions is governed by this Artistic License. By using, modifying or
distributing the Package, you accept this license. Do not use, modify,
or distribute the Package, if you do not accept this license.

If your Modified Version has been derived from a Modified Version made
by someone other than you, you are nevertheless required to ensure that
your Modified Version complies with the requirements of this license.

This license does not grant you the right to use any trademark, service
mark, tradename, or logo of the Copyright Holder.

This license includes the non-exclusive, worldwide, free-of-charge
patent license to make, have made, use, offer to sell, sell, import and
otherwise transfer the Package with respect to any patent claims
licensable by the Copyright Holder that are necessarily infringed by the
Package. If you institute patent litigation (including a cross-claim or
counterclaim) against any party alleging that the Package constitutes
direct or contributory patent infringement, then this Artistic License
to you shall terminate on the date that such litigation is filed.

Disclaimer of Warranty: THE PACKAGE IS PROVIDED BY THE COPYRIGHT HOLDER
AND CONTRIBUTORS "AS IS' AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES.
THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE, OR NON-INFRINGEMENT ARE DISCLAIMED TO THE EXTENT PERMITTED BY
YOUR LOCAL LAW. UNLESS REQUIRED BY LAW, NO COPYRIGHT HOLDER OR
CONTRIBUTOR WILL BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, OR
CONSEQUENTIAL DAMAGES ARISING IN ANY WAY OUT OF THE USE OF THE PACKAGE,
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

=cut

1;
