<p align="center"><img width=70% src="https://github.com/SwiftLeeds/swiftleeds-web/blob/main/media/swift-leeds-horizontal.png"></p>

![Contributions welcome](https://img.shields.io/badge/contributions-welcome-orange.svg)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)
  
## Introduction 👋🏼

SwiftLeeds is a brand new Swift conference that started in 2021. It's a truly unique conference that is built by the community for the community. Hosted in the heart of Leeds City, UK.

The website is split into two components: the API and the front-end. Our immediate focus is developing a solid API that can power multiple platforms. Over the next few weeks, we'll be adding more and more front-end content to complement our API efforts.

## Developer Setup 💻

Follow these steps to get your development environment setup to run SwiftLeeds locally. To start, open the `Package.swift` file. It'll take a few moments for the dependencies to download, especially on first open. 

### Prerequisites
SwiftLeedsWeb runs off Vapor (of course!), which requires a couple of pre-requisites: 
* [Homebrew](https://brew.sh)
* [Vapor](https://docs.vapor.codes/4.0/install/macos/)
* [Postgres](https://postgresapp.com)

Once you have those two dependencies installed, you're ready to get started. For now, we'll ignore running in a production like environment. Instead, we'll focus on local only build. See the advanced setup below to get started with Docker. 

### Database Setup 
SwiftLeeds uses Postgres for its database. The following assumes you have postgres installed and ready to use. If not, please follow the tutorial in the link above. 

We'll start by logging into the postgres cli. In your terminal, type the following command: 
```
$ psql postgres -U postgres
```

We'll now create a database for all your users, content, etc to be stored. 

```
postgres=# CREATE DATABASE swiftleeds;
```

With the in place, we'll now create a user and grant them appropriate privileges. 

```
// you can rename the user and password here. 
postgres=# CREATE USER dev WITH ENCRYPTED PASSWORD 'root';
// grants privileges
postgres=# GRANT ALL PRIVILEGES ON DATABASE swiftleeds TO dev;
// quit psql
postgres=# \q
```

Your database is now setup! 

### .env
We also ship with a .env file to protect our production environment and allow for unique development environments. First, start by copying the .env file and renaming the copy to .env.development 

With that done, you can now update the values within it. The crucial one is `DB_URL`. If you followed the steps above, your environment variable should likely be the following: 

```
DB_URL=postgresql://dev:root@localhost/swiftleeds
```

### Migrations 
Finally, now that your database is setup and ready to accept connections, you can go ahead and run your migrations. Simply run the following command in terminal: 

```
vapor run migrate
```

You'll likely need to press Y when prompted. 

### Leaf

SwiftLeeds is using Leaf to build the frontend part of the website. These `Views` live within the Resources/Views folder of the project structure.

It's worth noting that to run this in development you will need to set your custom directory in the active scheme on Xcode. You can read about it [here](https://docs.vapor.codes/4.0/xcode/#custom-working-directory).

### 🚀 Ready to develop

That's it! You're ready to rock and roll. You should now see the following in your Xcode terminal

```
[ NOTICE ] Server starting on http://127.0.0.1:8080
```

If you have any issues, please reach out with an issue or via the Slack channel. 

## Contributing 🏗

We welcome all contributions to this repository. Please raise a PR so our Lead Maintainer can help get this pushed through, alternatively please raise an Issue or Discussion topic.
