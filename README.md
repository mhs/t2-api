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
ways. We don't want a monolithic beast with all features in one spot. As just one example, few people need to work
with billing/invoicing.

The [first effort to build (and then rebuild) this](https://github.com/neo/T2) ran into several problems along the way, most
of which aren't worth discussing here. We have since gone back and rebuilt the suite with an architecture
that should work better for the ways in which we can develop it.


## The T2 Ecosystem
We now have several different repositories/apps:

1. This repository, which is deployed to http://t2api.herokuapp.com owns the
   data layer and also adds in authentication. When you go to t2.neo.com you
   will be redirected here. At that point, you'll be authenticated (using
   google OAuth) and then this app will redirect you to your preferred T2
   application. Principals may prefer to see the allocation tool while the CEO
   may prefer to start off seeing the reporting tool.  Each t2-styled
   application works basically the same way.  It's a client-side-only app that
   is passed an authentication token on invocation. That token is passed in
   AJAX calls back to the API when fetching data. Also, each t2 app is expected
   to setup a navigation bar on the top strip of the app and fill it with
   content that is driven by an API response. These navigation strips are
   currently common code unfortunately copied and pasted from one T2
   app to another.

2. https://github.com/neo/t2-allocation is the repository that houses the
   allocation tool. Like most T2 applications, it is an ember.js application.
   The tool is used primarily by Principals to assign people to projects (where
   "projects" are broadly understood to include not just billable client works but
   really anything that can occupy a person's time including things like
   vacation and conference attendance). The production version of that
   repository is deployed to http://t2-allocation.herokuapp.com.

3. https://github.com/neo/t2-utilization is the repo for utilization (and
   eventually other key performance indicators) reporting. It's deployed to
   http://t2-utilization.herokuapp.com. It too is an Ember application.

4. https://github.com/neo/t2-pto is a repository for entering vacation and
   other paid time off. It's currently an Angular application though it may be
   moved to ember.js for consistency across the T2 world. This application has
   not been updated to reflect the new PTO policy announced in October 2013 and
   is thus not generally available. Once the work is done, it will be deployed
   to http://t2-pto.herokuapp.com.

5. https://github.com/neo/t2-user-preferences is for maintaining user
   preferences for T2 applications.  This includes your default T2 application,
   preferred date format, etc.. It's an Angular app.  It is deployed as
   http://t2-user-preferences.herokuapp.com but we're not yet pointing to it
   because we have not made the changes to other apps to respect those
   preferences.

6. https://github.com/neo/t2-people is an employee directory application that
   is deployed to t2-people.herokuapp.com. It allows us to CRUD people resources
   within the T2 ecosystem and then filter them in interesting ways (e.g. see
   who is on the bench across the company). It is an Ember application.

7. https://github.com/neo/zoho_reports is not a T2 application per-se in that
   it doesn't make use of this API or the database behind it. But it does show
   up on the T2 navigation bar as a key internal tool. It pulls sales pipeline
   data from Zoho CRM into its own DB and displays it in ways somewhat helpful
   to us. Note that it's constrained by the awfulness that is Zoho CRM and
   so it's not long for this world. We're in the process of spinning up a new
   CRM application that is part of the T2 ecosystem.


## Authentication and Navigation Flow

The navigation and authentication flow works like this.

1. A user begins by navigating to the root page for this application (eventually http://t2.neo.com).
2. If the user is not already authenticated, they get redirected to /sign_in which takes them through Google OAuth.
3. After Google OAuth completes, the user is directed (or redirected) to their default T2 application.  The application
   is passed a query string parameter named *authentication_token* that contains an authentication token to use when talking
   to the API.
4. Each application grabs that token from the URL, rewriting the URL in the process so that links can be shared, and stores
   the token in local storage.
5. The app then puts the token into an HTTP header named 'Authorization' with each call it
   makes. Optionally the client app can also authenticate its API calls by passing it as a query param named *authentication_token*.
6. The API side uses that token to understand who the current User is for the application.

In cases where a T2 application is called directly (e.g. navigating to http://t2-utilization.herokuapp.com directly
in your browser), the app will be unable to use the API layer until it authenticates. In this case, the app should
redirect the user to the /sign_in route for this app and include a *return_url* query string parameter.  After
authentication is completed, the API layer will redirect the user to that URL and included the token parameter
mentioned above.

Once authenticated, each application is responsible for drawing a navigation bar at the top of the page that makes
it easy for users to move from one T2 application to another. To do this, the app makes an API call to get the set
of available T2 applications and associated meta-data, including the fully authenticated version of the URL that should
be invoked to move to that application.  The result is rendered in the top navigation bar along with other elements that
the app uses for in-app navigation. A common example of the latter is an office picker that is used to customize the view
of an app for a particular office.



# Contributing

If you want to contribute, we'd welcome your help.  To get started:

1. Pile into the T2 room in hipchat where those of us who are working on it
   hang out and talk through things.  We're trying to make the README files in
   each of the above repositories good resources to use in getting going, but
   it can still be a challenge to get all the moving pieces together.

2. We use a combination of github issues and pivotal tracker for describing
   prioritizing work. Each new issue/feature request starts off in github
   issues within the appropriate repository. Discussion about the issue is
   done there so that we can benefit from the rich commenting environment there
   and make it easy for everyone in the company to see open issue and log new ones.
   Issues that are being worked on are then put into Pivotal Tracker. We have
   a single Pivotal Tracker project across all of the T2 repositories so that
   a common backlog of work. By convention, we use a "In Pivotal" label for any
   github issue that has made its way into the common backlog.

3. Work in a branch and use pull requests.  We're trying to follow the model
   spelled out here http://scottchacon.com/2011/08/31/github-flow.html for
   this.

4. We're using heroku organizations to house these apps.  Getting access to
   push/pull is done by adding you to the heroku organization.  Mike Doel can help you
   with this if needed.  Ping him in hipchat.

5. If you want to build a new T2-style application, please follow the conventions
   we are using. This includes using ember.js, Ember Data, SASS, lineman.js and
   other tech stack choices already made. It also includes certain visual conventions
   that we've begun to use (e.g. the aforementioned navigation and office selector).
   It's not helpful if each T2 project reinvents the wheel on these things as it makes
   it difficult for people to be productive across the suite. Please review other
   repositories when starting a new one and ask in hipchat before making a
   conscious decision to use something new or different.

6. We do daily standups and bi-weekly iteration planning meetings and retrospectives.
   Please join us for these. Ask Mike Doel to add you to the meeting invite. That
   invite includes the link to the google hangout we use.

7. Ask for help if you need it.  As mentioned above, there are a lot of moving pieces.


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

and add the following (or their equivalent) to your .profile, .bashrc, .zshrc, whatever:

```
export GOOGLE_CLIENT_ID="480140443980.apps.googleusercontent.com"
export GOOGLE_SECRET="v03dRPvKlgn_OsK79MXSDn5j"
```

This sets you up with API access to Google using a default account (adam.mccrea@gmail.com).
If for whatever reason we need to change this (unlikely), here is what is needed.
First create your Google Client ID and Secret keys from: https://code.google.com/apis/console/.
Then, in your Google API console, under API Access > Client ID for web applications, set the
`Redirect URIs` value to `[host]/users/auth/google_oauth2/callback`.
Eg.: `http://localhost:5000/users/auth/google_oauth2/callback`

#### Ruby version

We're currently using MRI ruby 1.9.3-p448

## Develop

Install gems and bootstrap the DB...

```
bundle
foreman run rake db:create:all
foreman run rake db:schema:load
```

Then establish links to production and staging and pull down a local copy of the production database to use for dev.

```
./.git_remotes_setup.sh
rake db:refresh_from_production
```


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

The API app runs on Heroku in both production (t2api) and staging (t2-staging) instances.  You will need to
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

Working on t2-api is something we someetimes do with candidates on pairing days.  Some of our clients
insist that our work for them is confidential. As such, we keep project names in staging obscure via

```
heroku run rake obscure_projects -a t2-staging
```

This is done automatically whenever we transfer data from production to staging (see below).
