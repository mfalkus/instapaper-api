package Net::InstapaperAPI;

use warnings;
use strict;

use base qw(Net::OAuth::Simple);

my $BASE = "https://www.instapaper.com";
my $API_VERSION = "api/1";
my $ACCESS_TOKEN = "oauth/access_token";
my $ACCOUNT = "account/verify_credentials";
my $BOOKMARKS = "bookmarks/list";

sub new {
    my ($class, $key, $secret) = @_;
    return $class->SUPER::new(
        tokens => {
            consumer_key => $key,
            consumer_secret => $secret,
        },
        protocol_version => '1.0a',
        urls => {
            authorization_url => 'http://unused?',
            request_token_url => join('/', $BASE , $API_VERSION , $ACCESS_TOKEN),
            access_token_url  => join('/', $BASE , $API_VERSION , $ACCESS_TOKEN),
        }
    );
}

sub view_restricted_resource {
    my $self = shift;
    my $url  = shift;
    return $self->make_restricted_request($url, 'POST');
}

sub update_restricted_resource {
    my $self         = shift;
    my $url          = shift;
    my %extra_params = @_;
    return $self->make_restricted_request($url, 'POST', %extra_params);
}

sub bookmarks {
    my ($self, $limit) = @_;
    my $uri = join('/', $BASE , $API_VERSION , $BOOKMARKS);
    $limit ||= 100;

    return $self->update_restricted_resource($uri, (
        limit => $limit,
    ));
}

1;
