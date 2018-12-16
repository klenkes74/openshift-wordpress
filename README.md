# Modular Wordpress Openshift S2I Builder

## tl;dr: For the impatient

Wordpress is a wide used CMS system. The easy admnistration for single installation is a problem when it comes to
containerization. Most Wordpress adaptions install the software during runtime on a persistent volume. This version
installs the software (including themes, plugins and languages) during container build. The software is unmutable.

The build is divided in two steps. First a generic basic container is build. This container contains the Apache HTTPd,
PHP, Wordpress and a selection of languages and plugins. This image can be generic within an organization. The build
is found in subdirectory 'wordpress' of this repository and should recide in a git repo of its own.

Then the specific application is build during a second step adding more plugins and languages and a theme (if wanted).
This part is specific for a special site. the configuration is found in 'site-blueprint' of this repo but normally is
found in a site-specifig repository.


### Adding Plugins
Plugins need to be added to the file plugins.cfg. The file can be used in the base image builder and in the site
specific repository. The file contains one plugin and version per line. The entry has to be the basename of the zip
file to be downloaded from the official Wordpress Plugin repository.


### Adding Languages
The language configuration need to match the language name in the official language translation repository of 
Wordpress. There are three parts needed for every language:

* The path fragment for downloading the language
* The name of the file after downloading
* The locale name of the language.

Downloading the German translations for "Du" and "Sie" could look like: 
```
wp/4.9.x/de/default:de-default:de_DE
wp/4.9.x/de/formal:de-formal:de_DE@formal
```

### Adding Themes
Themes need to be added in the site-speficic repository. The script site-bueprint/.s2i/bin/assemble contains the shell
commands to retrieve the theme and install it. It can be adapted to the needed theme.


## Combining Wordpress and OpenShift

### Yet another worpress template

Getting [Wordpress](https://www.wordpress.org) up and running within OpenShift oder even pure kubernetes is not an easy
task. Wordpress is optimized for an old-style server approach to administration. You install it once and then use the 
admin console for updating or adding or removing plugins. k8s (and therefore also OpenShift) want's software to be 
immutable inside containers. So there have been several attempts to containerize Wordpress. 

Many tried and all failed (this attempt here is also failing). You can't force not-fitting concepts together. You can
only to decide to which direction to fail. Concerning Wordpress you can either enable the admin console for updates
and administration by putting everything inside a PV so Wordpress is able to manage the software. Or you put the
software inside the container and have to run the build again for every software and plugin update.

This template uses the second way. All software is installed inside the container. The database with configuration is
configured traditionally. So having a database dump and the data from the ./wp-content/upload directory together with
the build git directory is sufficient for a new installation.


### Three stage build
The software container ist build in two stages. First a default organization wide base wordpress image is built. This
is a S2I builder image containing worpres itself and the defined plugins, languages that should be availailable
everywhere.

Then this S2I builder is used to generate the site itself. Here the theme gets added and all special plugins only 
being used on this site.

Now, all containers are ready. But when you call the site, you will need to run the installer. The database is not 
initialized. But after running the default installation routine once you have the database.

### Updating plugins
Depending where the plugins got added, you need to update either the wordpress S2I builder image or the site image.

### Updating wordpress
For updating wordpress you need to add either a new wordpress-s2i builder or change the current build configuration for
the wordpress S2I builder. I would propose to change the builder for patch level releases and use new builder for
major releases. Minor relaeses could be handled one or the other way, depending on your idea when to force the users
of the builder to update.

### To dos
Well, Backup is only halfway done (I included exporter doing the database and file backup). You still need something
like the stash project to really backup the data from the PV and database. Perhaps one of my next projects. 