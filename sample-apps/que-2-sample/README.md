# Sample app for judoscale-que gem

This is a minimal Rails app to test the judoscale-que gem.

## Prerequisites

- Ruby
- Node
- [Heroku CLI](https://devcenter.heroku.com/articles/heroku-cli)
- Redis

## Set up the app

Run `./bin/setup` install necessary dependencies. This will...

- Run `bundle install` to install gems

## Run the app

Run `./bin/dev` to run the app in development mode. This will...

- Use `heroku local` and a `Procfile` to start the following processes:
  - A [tiny proxy server](https://github.com/judoscale/judoscale-adapter-proxy-server) that adds the `X-Request-Start` request header so we can test request queue time reporting.
  - The Rails server.
  - The Que server to process jobs.

## How to use this sample app

Open https://judoscale-adapter-mock.requestcatcher.com in a browser. The sample app is configured to use this endpoint as a mock for the Rails Autoscale Adapter API. This page will monitor all API requests sent from the adapter.

Run the app. Both the Rails and Que processes will send an initial request to the API once the app boots up. These can be inspected via request catcher.

Open http://localhost:5000 to see how many jobs are waiting on each of the available queues, and to enqueue sample jobs on those queues that will be processed by the Que server slowly.

## Deploy this app to Heroku

From this directory, run the following to create a new git repo and push it to Heroku:

```sh
git init
git add .
git commit -m "prep for Heroku"
heroku create
git push heroku main
```

To install Rails Autoscale:

```sh
# scale up a worker dyno before doing this so Rails Autoscale picks it up
heroku ps:scale que=1
heroku addons:create judoscale
```
