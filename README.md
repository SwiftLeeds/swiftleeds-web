<p align="center">
    <picture>
        <source media="(prefers-color-scheme: dark)" srcset="./media/swift-leeds-horizontal-dark.png">
        <img alt="The Swift Leeds logo showing two swift birds to the left of the text 'Swift Leeds'" src="./media/swift-leeds-horizontal.png">
    </picture>
</p>

![Contributions welcome](https://img.shields.io/badge/contributions-welcome-orange.svg)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)
  
## Introduction 👋🏼

SwiftLeeds is a truly unique conference built by the community for the community. Started in 2021, we're now working towards our third year. SwiftLeeds is hosted in the heart of [Leeds](https://www.google.com/maps/place/Leeds/@53.8059821,-1.6057715,12z/data=!3m1!4b1!4m5!3m4!1s0x48793e4ada64bd99:0x51adbafd0213dca9!8m2!3d53.8007554!4d-1.5490774), a beautiful city in the northern English county of Yorkshire.

The website, which is of course built in Swift using [Vapor](https://vapor.codes/), is split into two key components:
1. The frontend which provides the community with information about the event, as well as the capability to buy tickets.
2. The API which powers our [open-source iOS application](https://github.com/SwiftLeeds/swiftleeds-ios).

## Contributing 🏗

As a community conference, we welcome contributions from anybody: from veteran developers to those just getting started. We're here to help, so feel free to jump into the [#swiftleeds-web](https://swiftleedsworkspace.slack.com/archives/C02M5L9C64D) channel on [our Slack](https://join.slack.com/t/swiftleedsworkspace/shared_invite/zt-wkmr6pif-ZDCdDeHM60jcBUy0BxHdCQ), or raise a [GitHub Issue](https://github.com/SwiftLeeds/swiftleeds-web) if you need a hand.

Equally, feel free to open a new pull request and we can discuss together how to take your ideas forward.

## Developer Setup 💻

To get started, follow along with these step by step instructions to get your local development environment setup and ready to run the SwiftLeeds website.

For now, we'll focus on your local environment which is slightly different to how the application is deployed in [production](https://swiftleeds.co.uk/) but allows us to quickly build and test our changes. For advanced users, you can utilise our Dockerfile.

### Prerequisites

SwiftLeeds relies on a few tools before we can get started! 

* [Xcode](https://developer.apple.com/xcode/) (we recommend using Xcode 14)
* [Postgres](https://postgresapp.com) - our chosen database, used to persist data.
* Optional: [Vapor](https://docs.vapor.codes/4.0/install/macos/)

Once you have these dependencies installed and setup (following the instructions in each of the links above), you're ready to get continue!

### 1. Open Xcode

Start by double-clicking the `Package.swift` file in the root of the repository. This will open the project in Xcode.

It'll take a few moments for Xcode to download our code dependencies, especially on first open as Xcode is unlikely to have cached versions of these ready to use. You don't need to do anything while it fetches these.

### 2. Setup Database

We're going to start by creating a new Postgres database for the SwiftLeeds application. Open Terminal and run the following commands:

```shell
$ psql postgres -U postgres
```

This will enter an interactive shell session which allows us to issue commands directly to Postgres.

```shell
postgres=# CREATE DATABASE swiftleeds;
postgres=# CREATE USER dev WITH ENCRYPTED PASSWORD 'root';
postgres=# GRANT ALL PRIVILEGES ON DATABASE swiftleeds TO dev;
postgres=# \q
```

In order, these commands will create a new database called 'swiftleeds', create a user called 'dev' with the password 'root' and then provide that user will access to the database. The `\q` command simply quits the interactive session as we're all done there!

You are welcome to provide your own database name, username and password - modifying the commands above as necessary.

Once those commands have been executed, your database is now setup! 🚀

### 3. Environment Variables

Vapor, along with many server frameworks, uses 'dot env' files to store environment variables for our application to use at runtime. You'll see that we have a file called `.env.development` - these are variables which our local environment is able to use.

By default, you do not need to make any changes to this file! However, if you provided your own database name, username or password in the previous step then you will need to change the `DATABASE_URL` variable now.

### 4. Database Migrations

At this point you will have an empty database! We need to create some tables so SwiftLeeds has somewhere to store data. Thankfully, this is done for us as part of an "auto migrations" step when you first run the project. You don't need to do anything!

For advanced users, you may wish to run `vapor run migrate` in Terminal. You'll need to press 'Y' when prompted. You can revert the previous migrations by running `vapor run migrate --revert`.

### 5. Frontend Views

SwiftLeeds uses a framework called [Leaf](https://docs.vapor.codes/leaf/overview/) in order to render the HTML frontend of our website. These views are stored within the `Resources/Views` folder of the repository.

In order for Xcode to know where the Leaf files are stored, you must set your working directory within the active scheme. Vapor has documented how to do this [here](https://docs.vapor.codes/getting-started/xcode/#custom-working-directory).

### 🚀 Ready to develop

That should be everything! If you've followed these steps, you should now be able to run the 'swift-leeds' scheme in Xcode. This will output a message reading "Server starting on http://127.0.0.1:8080".

If the application fails to load then we recommend following these steps again to make sure you haven't missed something. Otherwise, feel free to raise a GitHub Issue or contact us on the Slack (links above) and we'll help you to get started.