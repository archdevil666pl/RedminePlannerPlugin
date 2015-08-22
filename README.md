# Redmine Planner Plugin

**Please note that this plugin is currently not under active development due to
lack of time. Proper pull requests are welcome.**

A Redmine plugin for resource planning with a request/confirm scheme.

This software is licensed under the terms of the GNU General Public License (GPL) v2.
See COPYRIGHT and COPYING for details.

For more information about the plugin, see:

  * [Concepts](doc/concept.md)
  * [Getting Started](doc/gettingstarted.md)


Requirements:

  * Redmine 2.2 or higher (currently tested: Redmine 2.6, 3.1)
  * Ruby 1.9.3 or higher
  * PostgreSQL or MySQL. Other DBs might work as well but are untested.


## Installation

Installing Planner requires a running Redmine v2.2.x or higher. Once Redmine is
up and running, the standard procedure for plugin installation applies. Three
easy steps are enough to get the plugin going:

 1. **Getting the source**

	Download the source tarball or use Git to directly clone the repository into
	Redmine's `plugin/` directory.

	Extracting the tarball can be achieved with the following commands from within
	the Redmine root directory. The tarball already contains the required
	directory structure.

	```
	cd plugins
	tar zxf planner-v0.5.tar.gz
	mv RedminePlanner* planner
	```

	Alternatively, Git can be used to clone the source repository. Using this
	method makes updates far easier.

	```
	cd plugins
	git clone git://github.com/dr-itz/RedminePlannerPlugin.git planner
	cd planner
	```

 2. **Install Gems**

	Planner also comes with a Gemfile. To install the required Gems:

	```
	bundle install --without development test
	```

	If you're planning on hacking on Planner, install with development and test
	Gems:

	```
	bundle install
	```

 3. **Run DB migrations**

	Once the plugin is in place, the necessary database structures must be
	created. This works through normal Rails migrations. Redmine offers a special
	Rake task to execute plugin migrations. Again, execute from within the Redmine
	root directory.

	  * For production

		```
		RAILS_ENV=production rake redmine:plugins:migrate NAME=planner
		```
	  * For development

		```
		RAILS_ENV=development rake redmine:plugins:migrate NAME=planner
		```

 4. **Restart Redmine**

	The last step is to restart Redmine. How this is done depends on how Redmine is
	setup. After the restart, configuration of the plugin can begin.


## Uninstallation

Uninstalling the plugin is easy as well. Basically it means dropping all the
tables and removing the plugin directory. Again, execute from withing the
Redmine root directory.

 1. **Dropping the database tables**

	```
	rake redmine:plugins:migrate NAME=planner VERSION=0 RAILS_ENV=production
	```

 2. **Removing the plugin directory**

	```
	rm -r plugins/planner
	```

 3. **Restart Redmine**

	The last step is to restart Redmine. Once restarted, the plugin will be gone.



## Development setup on OS X 10.7 or higher

### Installing and setting up Redmine #

Setting up a development environment on Lion for Redmine development is straight
forward. Prerequisites are Xcode command line tools and Git (Xcode ships with Git
too, but an older version with a, at least in some cases, broken Git GUI).

OS X already ships with Ruby. But it's a good idea to use a more recent version,
or even required as 10.7 only includes 1.8.7. To install an up-to-date Ruby
version, use RVM, see http://rvm.io/.
When using RVM, make sure to select the @global Gemset.

Redmine can work fine with SQLite, but a MySQL is recommended. The MySQL server
can be local or remote. Alternatively, PostgreSQL works fine too. Only MySQL is
described here. Using a remote MySQL requires installing the MySQL client
libraries, also called Connector/C or simply libmysql. The client should be
installed in `/usr/local`

 1. **Preparation**

	Redmine uses Bundler to manage dependencies. This is what makes installation
	so easy. First, make sure Bundler is installed. This step is not necessary
	when using RVM.

	```
	sudo gem install bundler
	```

 2. **Getting the sources**

	There's different ways of getting the sources. Choose the one that fits you
	best. Note however, that the official repository is maintained using the toy
	tool Subversion, the Git and Mercurial repositories are just mirrors and might
	not always be up to date.
	  * Download an official release package from

		http://rubyforge.org/frs/?group_id=1850
	  * Checkout the official repository using SVN

		```
		svn co http://redmine.rubyforge.org/svn/branches/3.1-stable redmine
		cd redmine
		```
	  * Clone the repository mirror using Git

		```
		git clone git://github.com/redmine/redmine.git
		cd redmine
		git checkout 3.1-stable
		```

 3. **Setting up database connectivity**

	Start by `cp config/database.yml{.example,}`, edit the resulting
	file and change configuration as required. It's the normal Rails way.

 4. **Installing required dependencies**

	```
	bundle install --without rmagick
	```

 5. **Initialize Redmine**

	```
	rake generate_secret_token
	RAILS_ENV=development rake db:migrate
	RAILS_ENV=development rake redmine:load_default_data
	mkdir -p tmp public/plugin_assets
	```

 6. **Test**

	```
	rails s
	```

	Give WEBrick a moment to boot, then point the web browser at
	http://localhost:3000 and login using the user "admin" with the same
	password.


### Development and testing of Planner

#### Additional setup for Planner

The Planner plugin can be installed into the newly created development
environment as described above. To develop and test, it's necessary to have a
test database setup. This can be SQLite, MySQL or PostgreSQL. Just makes sure the
database connectivity is setup correctly in `config/database.yml` for
the environment "test".

Another important step is the setup of the email delivery in Redmine. Without
this step, tests will fail. The email configuration is done in Redmine's
`config/configuration.yml`:

```
development:
  email_delivery:
    delivery_method: :file
test:
  email_delivery:
    delivery_method: :test
```

The important one is for the "test" environment. The "development"
environment can have any configuration, but `:file` is preferred since
resulting emails can be manually verified. Also, this does not send unwanted
emails to people when working on a copy of a production database.


#### Running the tests

If everything is set up correctly, running the automatic tests of Planner can
be done via the standard Redmine way:

```
rake redmine:plugins:test NAME=planner
```

Alternatively, mainly for historical reasons, there are also some Rakes tasks.
The names should speak for themselves.

```
rake planner:test:units
rake planner:test:functionals
rake planner:test:integration
rake planner:test:all
```

Coverage tests are ran automatically with SimpleCov. Once a test run is
complete, open `coverage/index.html` in your browser to see the results. On Mac,
this is easy also from within the terminal:

```
open coverage/index.html
```
