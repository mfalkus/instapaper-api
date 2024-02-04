package Net::InstapaperAPI;

use warnings;
use strict;

use JSON;

use base qw(Net::OAuth::Simple);

my $BASE = "https://www.instapaper.com";
my $API_VERSION = "api/1";
my $ACCESS_TOKEN = "oauth/access_token";
my $ACCOUNT = "account/verify_credentials";
my $BOOKMARKS = "bookmarks/list";
my $BOOKMARKS_MOVE = "bookmarks/move";
my $FOLDERS = "folders/list";

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

sub update_restricted_resource {
    my $self        = shift;
    my $url_part    = shift;

    my $url = join('/', $BASE, $API_VERSION, $url_part);
    my %extra_params = @_;
    my $response = $self->make_restricted_request($url, 'POST', %extra_params);
    return decode_json($response->decoded_content);
}

sub bookmarks {
    my ($self, %args) = @_;

    # Output is array, e.g.:
    #  [
    #     {
    #       'starred' => '0',
    #       'progress' => '0',
    #       'time' => 1700589280,
    #       'bookmark_id' => 1647300436,
    #       'description' => '',
    #       'hash' => 'LIHebq7l',
    #       'private_source' => 'email',
    #       'progress_timestamp' => 0,
    #       'url' => 'instapaper://private-content/1647300436',
    #       'type' => 'bookmark',
    #       'title' => 'Money Stuff: OpenAI Is a Strange Nonprofit'
    #     },
    #  ... ]

    return $self->update_restricted_resource($BOOKMARKS, %args);
}

sub bookmark_move {
    my ($self, $bookmark_id, $folder_id) = @_;

    die("Must supply bookmark_id and folder_id") unless $bookmark_id && $folder_id;

    # Sadly this resets the `time` in the API response, which can cause confusion!
    return $self->update_restricted_resource($BOOKMARKS_MOVE, (
        bookmark_id => $bookmark_id,
        folder_id => $folder_id,
    ));
}

sub folders {
    my ($self, $limit) = @_;
    $limit ||= 100;

    return $self->update_restricted_resource($FOLDERS, (
        limit => $limit,
    ));
}

1;
