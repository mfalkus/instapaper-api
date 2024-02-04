use warnings;
use strict;

use Data::Dumper;
use Net::InstapaperAPI;

# Setup
my $CLIENT_KEY = $ENV{CLIENT_KEY};
my $CLIENT_SECRET = $ENV{CLIENT_SECRET};
my $X_AUTH_USERNAME = $ENV{X_AUTH_USERNAME};
my $X_AUTH_PASSWORD = $ENV{X_AUTH_PASSWORD};


#
# Step 1: Login to Instapaper API
#
my $app = Net::InstapaperAPI->new( $CLIENT_KEY, $CLIENT_SECRET );

unless ($app->consumer_key && $app->consumer_secret) {
    die "You must go get a consumer key and secret from App\n";
}

my ($access_token, $access_token_secret) = $app->xauth_request_access_token(
    x_auth_username => $X_AUTH_USERNAME,
    x_auth_password => $X_AUTH_PASSWORD,
    x_auth_mode => 'client_auth',
);

#
# Step 2: Grab unread bookmarks and folders
#
my $unread_bookmarks = $app->bookmarks;

# Get a list of folder names...
my $folder_map;
foreach my $folder (@{$app->folders}) {
    $folder_map->{$folder->{title}} = $folder;
}

#
# Step 3: Move bookmarks to folders if suitable folder exists.
#
#         e.g. 'Money Stuff: OpenAI Is a Strange Nonprofit'
#         moves to a folder 'Money Stuff' if that exists.
#
foreach my $bm (@{$unread_bookmarks}) {
    next unless ($bm->{type} eq 'bookmark');

    my ($first, $second) = split(':', $bm->{title}) if $bm->{title};
    if ($first && $second && $folder_map->{$first}) {
        warn "$bm->{title} should be moved to $first folder";
        my $folder = $folder_map->{$first};

        my $result = $app->bookmark_move($bm->{bookmark_id}, $folder->{folder_id});
        # warn Dumper($result);
    }
}
