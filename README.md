# T2-API

This is the API layer for the suite of apps used by Neons to run the business.

## A bit of history

T2 (a perpetual working title derived from teamster 2) started life as the resource allocation tool used within Neo.
It drew influence from several sources including teamster (the tool used by the former Edgecase) and Pivotal's allocation tool.
Over time the vision for the tool grew quite ambitious - aiming to grow into a suite of tools that gives us the intelligence
we need to run our business.  Current and potential features could include:

- allocation of people to projects currently being worked on
- visibility to staff availability within the sales channel
- allowing employees to schedule and communicate to others their time (paid or not) out of the office
- assisting with the invoice and billing process
- financial and operational reporting
- employee directory
- provide help in managing client interactions - from the sales channel up through finished projects

From an architectural perspective, we wanted to have proper separation of concerns.  In particular, we want an API layer
that contains the business objects and a constellation of small, focused apps, that combine that data in interesting
ways. We dont' want a monolithic beast with all features in one spot. As just one example, few people need to work
with billing/invoicing.


## Current status

This API layer was extracted from the first attempt to build T2.  It is not yet ready to be the authoritative
source of data. Instead, we have a rake task to copy the production data from the current T2 heroku app into
here.  Once we have an allocation tool built off this version and a daily utilization reporting tool built off this,
we'll be ready to retire the existing T2 and promote this app as the authoritative source of data.  Dan Williams
in Cincinnati is working on the allocation tool and Mike Doel in Columbus is building the daily utilization tool.
These are ember.js applications contained in separate repositories.  In addition, Scott Walker in Columbus is
building a PTO tool that uses this API for scheduling paid time off by employees. That is an angular.js app.


# What This Is Responsible For

As mentioned above, the T2 ecosystem is made up of several diferent applications/repositories. This one is
responsible for the following:

- RESTful API that can be used to build new applications on allocation, project, office, person, etc. data
- Authentication for this and other related applications (more below)
- Navigation - the primary view for this app is a page with a nav strip in one frame and another app in the other, larger frame.
  This app knows the set of T2 apps a user can access and provides the links for them.

## Authentication and Navigation Flow

**Note - some of this section is speculative at this point. We are still building this piece.**

The navigation and authentication flow works like this.

1. A user begins by navigating to the root page for this application (eventually http://t2.neo.com).
2. If the user is not already authenticated, they get redirected to /sign_in which takes them through Google OAuth.
3. After Google OAuth completes, the user is directed (or redirected) to one of the T2 applications.  The application
   is passed a query string parameter named *authentication_token* that contains an authentication token to use when talking
   to the API.
4. Each application grabs that token and shoves it into an HTTP header named 'Authorization' with each call it
   makes. Optionally the client app can also authenticate it's API calls by passing it as a query param named *authentication_token*.

Note that in step 3, the application is called from within a frame. The other frame in the frame set is the navigation
strip provided by this application.

In cases where a T2 application is called directly (e.g. navigating to http://t2-utilization.herokuapp.com directly
in your browser), the app will be unable to use the API layer until it authenticates. In this case, the app should
redirect the user to the /sign_in route for this app and include a *return_url* query string parameter.  After
authentication is completed, the API layer will redirect the user to that URL and included the token parameter
mentioned above.


# Contributing

Have bench time and want to help contribute to T2?  Fantastic.  Here are the rules of the road:

- Hop into the T2 room in hipchat.  Those of us working on it actively hang out there.
- Work in a branch and submit a pull request when you have something to contribute.  Don't work in master.
- Want to contribute but don't know what to work on?  Ask in hipchat.  We will eventually more use of Github
  issue (though there are already a few you can pick from) once we have reached a stable state.
- Mike Doel is currently acting as the primary gatekeeper on pull requests - reviewing and merging.


# Building and Running Locally

## Setup

Clone repository:

```
  $ git clone git@github.com:neo/t2-api.git
```

```
  $ cd t2-api
```

#### Environment

Copy the env sample file:

```
  $ cp .env.sample .env
```

This sets you up with API access to Google using a default account (adam.mccrea@gmail.com).
Feel free to replace the credentials with your own if you need to make any changes.
To do so, first get your Google Client ID and Secret keys from: https://code.google.com/apis/console/.
Then, in your Google API console, under API Access > Client ID for web applications, set the
`Redirect URIs` value to `[host]/users/auth/google_oauth2/callback`.
Eg.: `http://localhost:5000/users/auth/google_oauth2/callback`

#### Ruby version

We're currently using MRI ruby 1.9.3-p448

## Develop

```
bundle
foreman run rake db:create:all
foreman run rake db:schema:load
```

We don't yet have a good seed file to use locally (feel free to create one).  Instead, we're making copies
of the data on heroku (which as mentioned above is itself a copy of the currently live t2 production data).
To get this, you'll need to be added to the t2api heroku application.  Ask for this on ask@neo.com.  Once you
have been setup as a collaborator, you can run:

```
./git_remotes_setup.sh
rake db:refresh
```

to pull down the latest development database.

#### Start the server

```
foreman start
```

## Test

#### Setup

```
rake db:test:prepare
```

#### Run suite

```bash
rake
```

## Deploying

#### Setup

The api app runs on Heroku in both production (t2api) and staging (t2api-staging) instances.  You will need to
be added as a collaborator to one or both in order to deploy. To set up the heroku git remotes run:

```
./git_remotes_setup.sh
```


#### Deploy

```
git push staging master
```
```
git push production master
```
## Obscuring Project Names

Working on t2-api is something we sometimes do with candidates on pairing days.  Some of our clients
insist that our work for them is confidential. As such, we keep project names in staging obscure via

```
heroku run rake obscure_projects -a t2api-staging
```

This is done automatically whenever we transfer data from production to staging (see below).


## Refreshing data

As mentioned above, this repository is not yet the authoritative copy of the allocation
and related data.  That exists in the heroku app named t2-production.  We periodically
pull data from that app into one of the heroku apps for this repository.  To do this, you need
to be a collaborator on both t2-production and the appropriate api apps in heroku.  Send a note to
ask@neo.com if you need either.  Once you are setup, you can refresh the heroku data
with:

```
rake db:transfer_staging_db
```

or

```
rake db:transfer_prod_db
```

and then pull that data down for your own development use with:

```
rake db:refresh
```

for staging or

```
rake db:refresh_from_production
```

for production
