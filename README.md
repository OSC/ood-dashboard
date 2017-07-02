# OOD Dashboard

[![GitHub version](https://badge.fury.io/gh/OSC%2Food-dashboard.svg)](https://badge.fury.io/gh/OSC%2Food-dashboard)

This app is a Rails app for Open OnDemand that serves as a gateway to launching
other Open OnDemand apps. It is meant to be run as the user (and on behalf of
the user) using the app. Thus, at an HPC center if I log into OnDemand using
the `efranz` account, this app should run as `efranz`. This Rails app doesn't
use a database.

## New Install


1. Start in the **build directory** for all sys apps, clone and check out the
   latest version of the dashboard app (make sure the app directory's name is
   `dashboard`):

   ```sh
   scl enable git19 -- git clone https://github.com/OSC/ood-dashboard.git dashboard
   cd dashboard
   scl enable git19 -- git checkout tags/v1.13.3
   ```

2. Install the app for a production environment:

   ```sh
   RAILS_ENV=production scl enable git19 rh-ruby22 nodejs010 -- bin/setup
   ```

   this will setup a default Open OnDemand install. If you'd like a specific
   pre-defined portal such as OSC OnDemand you'd specify `OOD_SITE` and
   `OOD_PORTAL` as:

   ```sh
   OOD_SITE=osc OOD_PORTAL=ondemand RAILS_ENV=production scl enable git19 rh-ruby22 nodejs010 -- bin/setup
   ```

   assuming the corresponding `.env.local.$OOD_SITE.$OOD_PORTAL` file exists.

3. Copy the built app directory to the deployment directory, and start the
   server. i.e.:

   ```sh
   sudo mkdir -p /var/www/ood/apps/sys/dashboard
   sudo cp -r . /var/www/ood/apps/sys/dashboard
   ```

## Updating to a New Stable Version

1. Navigate to the app's build directory and check out the latest version:

   ```sh
   cd dashboard # cd to build directory
   scl enable git19 -- git fetch
   scl enable git19 -- git checkout tags/v1.13.3
   ```

2. Update the app for a production environment:

   ```sh
   RAILS_ENV=production scl enable git19 rh-ruby22 nodejs010 -- bin/setup
   ```

   You do not need to specify `OOD_SITE` and `OOD_PORTAL` if they are defined
   in the `.env.local` file.

3. Copy the built app directory to the deployment directory:

   ```sh
   sudo rsync -rlptv --delete . /var/www/ood/apps/sys/dashboard
   ```

## Configuration

See the wiki page https://github.com/OSC/ood-dashboard/wiki/Configuration-and-Branding

### Message Of The Day

See the wiki page https://github.com/OSC/ood-dashboard/wiki/Message-of-the-Day

### Site-wide announcement

See the wiki page https://github.com/OSC/ood-dashboard/wiki/Site-Wide-Announcement

### App Sharing

**This is a feature currently in development. The documentation below is for developers working on this feature.**

See the wiki page https://github.com/OSC/ood-dashboard/wiki/App-Sharing

## iHPC CLI

You can launch an iHPC session by the command line using the provided rake
task:

```sh
bin/rake batch_connect:new_session
```

When you run the rake task, it will need to be run under the same environment
that the Dashboard **web** app is run under:

- `PWD` will need to be the Dashboard App root
- `RAILS_ENV` will need to be set to the rails environment the Dashboard App
  would be run under
- `RAILS_RELATIVE_URL_ROOT` will need to be set to what the Dashboard App would
  use

So an example to launch an Owens desktop that is deployed at OSC under the app
token `sys/bc_desktop_v2/owens` using the system-installed Dashboard App
(production) would be run as:

```sh
# We need to be at the root of the Dashboard app
cd /var/www/ood/apps/sys/dashboard

# We set the environment to match the Dashboard app's environment
export RAILS_ENV=production
export RAILS_RELATIVE_URL_ROOT=sys/dashboard

# We launch our Owens desktop session
bin/rake batch_connect:new_session BC_APP_TOKEN=sys/bc_desktop_v2/owens
```

If the session was launched successfully, then you should be able to navigate
to the chosen Dashboard app in your browser and find your session under
"Interactive Apps" => "Interactive Session".

### Modify Session Context

To modify the context that the session is launched with (e.g., modify number of
nodes or walltime) you need to provide a JSON file with the settings you want
to use.

For the case of the Owens desktop, a session context file can look like:

```json
{
  "bc_num_hours": "1",
  "bc_num_slots": "1",
  "node_type": ":ppn=28",
  "bc_account": "",
  "bc_vnc_resolution": "2048x1152",
  "bc_email_on_started": "0"
}
```

You can then launch and Owens desktop session with this JSON file as:

```sh
# Set environment for the Dashboard app of your choosing
...

# Launch and Owens desktop session with user-defined context
bin/rake batch_connect:new_session BC_APP_TOKEN=sys/bc_desktop_v2/owens BC_SESSION_CONTEXT=/path/to/context.json
```

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/OSC/ood-dashboard.

## License

The gem is available as open source under the terms of the [MIT
License](http://opensource.org/licenses/MIT).
