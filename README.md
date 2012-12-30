# NAME

HTML::ExtractMeta - Extract meta data from HTML.

# VERSION

Versjon 0.02

# SYNOPSIS

    use HTML::ExtractMeta;

    my $EM = HTML::ExtractMeta->new(
        html => $html, # required
    );

    print "Title       = " . $EM->get_title()       . "\n";
    print "Description = " . $EM->get_description() . "\n";
    print "URL         = " . $EM->get_url()         . "\n";
    print "Image URL   = " . $EM->get_image_url()   . "\n";
    print "Site name   = " . $EM->get_site_name()   . "\n";
    print "Type        = " . $EM->get_type()        . "\n";
    print "Keywords    = " . join( ', ', @{$EM->get_keywords()} ) . "\n";

# DESCRIPTION

HTML::ExtractMeta is a convenience module for extracting useful meta data from
HTML. It doesn't only look for the traditional meta tags, but also the newer
ones like "og:foobar" and "twitter:foobar".

# METHODS

## new( %opts )

Returns a new HTML::ExtractMeta instance. Requires HTML as input argument;

    my $EM = HTML::ExtractMeta->new(
        html => $html,
    );

## get\_dom()

Returns the Mojo::DOM object for the current HTML.

## get\_title()

Returns the HTML's title.

## get\_description()

Returns the HTML's description.

## get\_url()

Returns the HTML's URL.

## get\_image\_url()

Returns the HTML's image URL.

## get\_site\_name()

Returns the HTML's site name.

## get\_type()

Returns the HTML's type.

## get\_keywords()

Returns the HTML's keywords as an array reference.

# LICENSE AND COPYRIGHT

Copyright 2012 Tore Aursand.

This program is free software; you can redistribute it and/or modify it
under the terms of the the Artistic License (2.0). You may obtain a
copy of the full license at:

[http://www.perlfoundation.org/artistic\_license\_2\_0](http://www.perlfoundation.org/artistic\_license\_2\_0)

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
