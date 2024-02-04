use warnings;
use strict;

use Data::Dumper;
use Net::InstapaperAPI;
use JSON;

# Setup
my $CLIENT_KEY = $ENV{CLIENT_KEY};
my $CLIENT_SECRET = $ENV{CLIENT_SECRET};
my $X_AUTH_USERNAME = $ENV{X_AUTH_USERNAME};
my $X_AUTH_PASSWORD = $ENV{X_AUTH_PASSWORD};


# Get the tokens from the command line, a config file or wherever
my $app = Net::InstapaperAPI->new(
    $CLIENT_KEY,
    $CLIENT_SECRET,
);

# Check to see we have a consumer key and secret
unless ($app->consumer_key && $app->consumer_secret) {
    die "You must go get a consumer key and secret from App\n";
}

my ($access_token, $access_token_secret) = $app->xauth_request_access_token(
    x_auth_username => $X_AUTH_USERNAME,
    x_auth_password => $X_AUTH_PASSWORD,
    x_auth_mode => 'client_auth',
);

warn $access_token;
warn $access_token_secret;

my $response = $app->bookmarks;
my $dec = $response->decoded_content;

my $output = decode_json($dec);
warn Dumper($output);

# Now save those values

