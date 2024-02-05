package Instapaper::API;

use warnings;
use strict;

use open qw( :std :encoding(UTF-8) );
use base qw(Net::OAuth::Simple);
use JSON;

# See https://www.instapaper.com/api for details...
my $BASE            = "https://www.instapaper.com";
my $API_VERSION     = "api/1";
my $ACCESS_TOKEN    = "oauth/access_token";
my $ACCOUNT         = "account/verify_credentials";

my $BOOKMARKS           = "bookmarks/list";
my $BOOKMARKS_MOVE      = "bookmarks/move";
my $BOOKMARKS_TEXT      = "bookmarks/get_text";
my $BOOKMARKS_DELETE    = "bookmarks/delete";

my $FOLDERS         = "folders/list";
my $FOLDERS_ADD     = "folders/add";
my $FOLDERS_DELETE  = "folders/delete";

sub new {
    my ($class, $key, $secret) = @_;
    return $class->SUPER::new(
        tokens => {
            consumer_key => $key,
            consumer_secret => $secret,
        },
        protocol_version => '1.0a',
        urls => {
            # authorization_url => '', # Unused for xauth
            # request_token_url => '', # Unused for xauth
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

sub bookmark_list {
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

    my $results = $self->update_restricted_resource($BOOKMARKS, %args);

    # Bookmark list returns other types beyond just bookmark,
    # let's filter them out here.
    return [grep { $_->{type} eq 'bookmark'} @{$results}];
}

sub bookmark_move {
    my ($self, $bookmark_id, $folder_id) = @_;

    die("Must supply bookmark_id") unless $bookmark_id;
    die("Must supply folder_id") unless $folder_id;

    # Sadly this resets the `time` in the API response, which can cause confusion!
    return $self->update_restricted_resource($BOOKMARKS_MOVE, (
        bookmark_id => $bookmark_id,
        folder_id => $folder_id,
    ));
}

sub bookmark_delete {
    my ($self, $bookmark_id) = @_;

    die("Must supply bookmark_id") unless $bookmark_id;

    # Sadly this resets the `time` in the API response, which can cause confusion!
    return $self->update_restricted_resource($BOOKMARKS_DELETE, (
        bookmark_id => $bookmark_id,
    ));
}

sub bookmark_text {
    my ($self, $bookmark_id) = @_;

    die("Must supply bookmark_id") unless $bookmark_id;

    my %params = ( bookmark_id => $bookmark_id );

    # We don't get JSON back, so call make_restricted_request direct
    my $url = join('/', $BASE, $API_VERSION, $BOOKMARKS_TEXT);
    my $response = $self->make_restricted_request($url, 'POST', %params);

    return $response->decoded_content;
}

sub folder_list {
    my ($self, $limit) = @_;
    $limit ||= 100;

    return $self->update_restricted_resource($FOLDERS, (
        limit => $limit,
    ));
}

sub folder_add {
    my ($self, $folder_title) = @_;

    return $self->update_restricted_resource($FOLDERS_ADD, (
        title => $folder_title
    ));
}

sub folder_delete {
    my ($self, $folder_id) = @_;

    return $self->update_restricted_resource($FOLDERS_DELETE, (
        folder_id => $folder_id
    ));
}

1;
