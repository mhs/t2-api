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

The [first effort to build (and then rebuild) this](https://github.com/neo/T2) ran into several problems along the way, most
of which aren't worth discussing here. Suffice to say, we are in the midst of a reboot on things to get to the
vision that will work best for Neo.


## Current status
We now actively developing several different repositories/apps:

1. This repository, which is deployed to
   http://t2api.herokuapp.com is to own the data layer and also add in
   authentication and simple navigation features (i.e. it is the the thing that
   draws the left navbar in an iframe for other apps). When we're all done with
   the transition, it will be this that answers to t2.neo.com. When you go
   there, you'll be authenticated (using google OAuth) and then that app will
   redirect you to your preferred T2 application. Client Principals may prefer
   to see the allocation tool while Daniel may prefer to start off seeing the
   reporting tool.  Each t2 styled application works basically the same way.
   It's a client-side only app that is passed an authentication token on
   invocation. That token is passed in AJAX calls back tot he API when fetching
   data. Also, the t2 app is expected to setup an iframe on the left side of
   the page and fill it with t2api.herokuapp.com/navbar. The API will fill that
   navbar with links to the available T2 applications you can use.

2. https://github.com/neo/t2-allocation is the new repo for taking over the
   allocation portion of the old T2. It's not yet deployed to heroku (I'm
   hoping to make that happen in the next day or two). It's an ember app.
   It's the thing that needs the most love
   and is probably on the critical path to making the transition away from
   neo/T2 happen. If people are on the bench and want to contribute, this would
   be a great spot - especially if they already know ember.js. But if they
   don't know it, they're probably best advised to start with some ember
   tutorials or helping somewhere else because this is actually a fairly
   complicated bit of code.

3. https://github.com/neo/t2-utilization is a new repo for utilization
   reporting. It's deployed to http://t2-utilization.herokuapp.com. It's an ember app,
   and one that is substantially simpler than t2-allocation. If there are
   people who are looking to learn ember, this would be a good place to
   contribute.

4. https://github.com/neo/t2-pto is a new repo for entering vacation and other
   paid time off. It's an angular application that is brand new. Scott Walker
   in the Columbus office has been building it. If you have someone who is
   comfortable with angular, this could be a good place to contribute.  It is
   deployed to http://t2-pto.herokuapp.com.

5. https://github.com/neo/t2-user-preferences is a new rep for maintaining
   user preferences for T2 application.  This includes your default T2 application,
   preferred date format, etd.. It's an angular app.  It is deployed as
   http://t2-user-preferences.herokuapp.com


## Authentication and Navigation Flow

**Note - some of this section is speculative at this point. We are still building this piece.**

The navigation and authentication flow works like this.

1. A user begins by navigating to the root page for this application (eventually http://t2.neo.com).
2. If the user is not already authenticated, they get redirected to /sign_in which takes them through Google OAuth.
3. After Google OAuth completes, the user is directed (or redirected) to their default T2 application.  The application
   is passed a query string parameter named *authentication_token* that contains an authentication token to use when talking
   to the API.
4. Each application grabs that token and shoves it into an HTTP header named 'Authorization' with each call it
   makes. Optionally the client app can also authenticate it's API calls by passing it as a query param named *authentication_token*.
5. Each application also draws an iframe and fills it with http://t2api.herokuapp.com/navbar.  This will draw out the set of
   icons for the left hand side navigation common to all T2 applications.

In cases where a T2 application is called directly (e.g. navigating to http://t2-utilization.herokuapp.com directly
in your browser), the app will be unable to use the API layer until it authenticates. In this case, the app should
redirect the user to the /sign_in route for this app and include a *return_url* query string parameter.  After
authentication is completed, the API layer will redirect the user to that URL and included the token parameter
mentioned above.


# Contributing

If you want to contribute, we'd welcome your help.  Getting started is best achieved by:

1. Pile into the T2 room in hipchat where those of us who are working on it
   hang out and talk through things.  We're trying to make the README files in
   each of the above repositories good resources to use in getting going, but
   it can still be a challenge to get all the moving pieces together.

2. Check out the issues in the various repos for things to do. We're using
   github issues for these rather than Pivotal Tracker, primarily because
   there's less friction to getting someone going and because it allows the
   issue to live closer to the code.  If you're working on an issue, assign it
   to yourself and let us know in hipchat so we don't get multiple people
   working on the same thing.

3. Work in a branch and use pull requests.  We're trying to follow the model
   spelled out here http://scottchacon.com/2011/08/31/github-flow.html for
   this.

4. We're using heroku organizations to house these apps.  Getting access to
   push/pull is done by adding you to the heroku organization.  I can help you
   with this if needed.  Ping me in hipchat.

5. If you want to build a new T2-style application, consider using the
   [t2-angular-template](https://github.com/neo/t2-angular-template) that has been
   extracted from some of the other apps. It provides a starting project, including
   authentication, to help you get going quickly.

6. Ask for help if you need it.  As I said, there are a lot of moving pieces.


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
./.git_remotes_setup.sh
rake db:refresh_from_production
```

to pull down the latest development database.  Note that you do end up running "rake db:seed" above. This is
not enough to create a full-on dev database, but it will ensure that the navigataion data works correctly
in a dev environment.

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
./.git_remotes_setup.sh
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
