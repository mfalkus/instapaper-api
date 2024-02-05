This repo contains the beginnings of a perl library to use the Full Instapaper API.

## Getting Started

- Have a read of the [Instapaper API docs](https://www.instapaper.com/api/full)
- [Sign up ](https://www.instapaper.com/main/request_oauth_consumer_token) for an Instapaper API consumer key/secret
- Clone this repo and take a look at the scripts in the `examples/` folder.

You'll probably want to adjust what's there for your liking and then wrap in some helper script to configure the required environment variables, e.g.:

```
$ cat listit.sh 
#!/bin/sh
CLIENT_KEY=key-from-instapaper-api-signup \
CLIENT_SECRET=secret-from-instapaper-api-signup \
X_AUTH_USERNAME=your-user@email \
X_AUTH_PASSWORD=your-user-password \
PERL5LIB=lib \
perl examples/bookmarks-list.pl 
```

## Adding Methods

Currently only basic bookmark list/add/delete and folder list/add/delete operations are supported,
mostly because that's all I required for the project at hand. I may well add the rest in the future,
or reach out if your stuck without support for a particular method and I'll see what I can do.
