use warnings;
use strict;

use Data::Dumper;
use Instapaper::API;
use Try::Tiny;
use open qw( :std :encoding(UTF-8) );

# Setup
my $CLIENT_KEY = $ENV{CLIENT_KEY};
my $CLIENT_SECRET = $ENV{CLIENT_SECRET};
my $X_AUTH_USERNAME = $ENV{X_AUTH_USERNAME};
my $X_AUTH_PASSWORD = $ENV{X_AUTH_PASSWORD};


#
# Step 1: Login to Instapaper API
#
my $app = Instapaper::API->new( $CLIENT_KEY, $CLIENT_SECRET );

unless ($app->consumer_key && $app->consumer_secret) {
    die "You must go get a consumer key and secret from App\n";
}

my ($access_token, $access_token_secret) = $app->xauth_request_access_token(
    x_auth_username => $X_AUTH_USERNAME,
    x_auth_password => $X_AUTH_PASSWORD,
    x_auth_mode => 'client_auth',
);

#
# Step 2: Go through the folder items...
#

# Get a list of folder names...
my $folder_map;
foreach my $folder (@{$app->folder_list}) {
    $folder_map->{$folder->{title}} = $folder;

    my $bms = $app->bookmark_list(
        folder_id => $folder->{folder_id},
        limit => 200,
    );

    #
    # Step 3: Try get the text, if we can't delete it
    #
    foreach my $bm (@{$bms}) {
        my $result;
        try {
            $result = $app->bookmark_text($bm->{bookmark_id});
        } catch {
            warn $_;
            warn "Title $bm->{bookmark_id} $bm->{title} doesn't look avaialble...\n";
            $app->bookmark_delete($bm->{bookmark_id});
        };

        if ($result) {
            warn "Title $bm->{bookmark_id} $bm->{title} is OK\n";
        }
    }
}
