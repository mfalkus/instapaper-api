use warnings;
use strict;

use Data::Dumper;
use Instapaper::API;

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
# Step 2: Grab unread bookmarks and folders
#
my $unread_bookmarks = $app->bookmark_list(
    limit => 500,
);


#
# Step 3: Move bookmarks to folders if suitable folder exists.
#
#         e.g. 'Money Stuff: OpenAI Is a Strange Nonprofit'
#         moves to a folder 'Money Stuff' if that exists.
#
my $domains = {};
foreach my $bm (@{$unread_bookmarks}) {
    my $url = $bm->{url};
    if ($url =~ m/http/) {
        my ($domain) = $url =~ m#https?://([^/]*)#;
        if (!exists $domains->{$domain}) {
            $domains->{$domain} = [];
        }
        push(@{ $domains->{$domain} }, $bm->{bookmark_id});
    }
}

foreach my $key (keys %$domains) {
    my @bms = @{ $domains->{$key} };
    my $value = scalar @bms;
    if ($value > 3) {
        # Make the folder
        # Move the articles
        my ($folder) = @{ $app->folders_add($key) };
        foreach my $bm_id (@bms) {
            $app->bookmark_move($bm_id, $folder->{folder_id});
        }
    }
}

