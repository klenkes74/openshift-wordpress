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

The default language of the 

### Adding Themes
Adding the base name of the theme to the file themes.cfg will install the theme. The file contains one theme name per
line. The base name is the name in the theme directory of wordpress without the extension ".zip".


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

### Updating plugins or themes
Depending where the plugins got added, you need to update either the wordpress S2I builder image or the site image.

### Updating wordpress
For updating wordpress you need to add either a new wordpress-s2i builder or change the current build configuration for
the wordpress S2I builder. I would propose to change the builder for patch level releases and use new builder for
major releases. Minor relaeses could be handled one or the other way, depending on your idea when to force the users
of the builder to update.


## Deep dive
Main problem is, that Wordpress is not designed to run immutable in a container. So you need to decide what to put into
the container and what not to put into it. In addition to the PHP enabled web server in the main pod another pod is 
created containing the [mySQl](http://www.mysql.com) database holding the data of the Wordpress instance.

### Main application pod
The main pod contains of the site container image. That image gets build in a two stage build process:

#### Building the builder
The first stage is building a more or less generic wordpress S2I builder. It is defined in the subdirectory ./wordpress
of this repository. 

##### Getting Wordpress
Here the specified Wordpress gets downloaded. The version gets specified by setting the environment variable 
`WORDPRESS_VERSION` to the wanted Wordpress version. If this variable is not specified, the central Wordpress repository 
is queried which is the current version and this version will be built. The version is downloaded and compared to the 
Wordpress provided MD5 sum of the archive file (SHA1sum is not provided in the PHP 7.2 container of Red Hat).

##### Adding plugins
In addition you can define plugins to be loaded in the file `plugins.cfg`. Just give the name (as found when hovering over
the "Download" link in the plugin catalog of Wordpress without .zip and the path of the file) and the version number 
(for some plugins you can omit the version number to get the most current one). The plugins get downloaded and then 
copied into the directory `./wp-content/plugins`. They can then be activated within the dashboard of Wordpress. When
removing plugins, you will have to deactivate the plugin while it is still in the image, otherwise you will get in
problems using the deactivation mechanism of Wordpress.

##### Configuring Wordpress
The script `./wordpress/.s2i/bin/assembe` also modifies the wp-config.php file to read the environment for database and
other configuration variables.


#### Building the wordpress site container image
After building the wordpress-s2i builder you can now go on and define the site container. Here you can add additional
plugins (the same way as for the wordpress-s2i image).

##### Adding Themes
If you want to upload themes, you need to change the `./site-blueprint/.s2i/bin/asseble` script to include downloading
the theme wanted and unpack it to the place you want to have it. You also can check the unpacked theme into git and copy
it in this function to the directory `./wp-content/themes`. It only matters that after the call, the theme is completly
in this directory.

##### Special work
Some themes or plugins need patched to the generic files (like the bug list plugin needs to have a single file within
the active theme). You can add all these specialities tho the file `./site-blueprint/.s2i/bin/asseble`.

##### An image for every site?
Yes, the concept is to have a single image for every site. Since the sites normally differ in the plugins used, that
emerges from the decition to have unmutable software containers. But if you have multiple sites only differeng in the
content and configuration within the database, you can of course use a single image to all that sites. 


### Database pod or external database?
The database is a default mySQL installation providing a single database. All connection data is stored in the secret
<APPLICATION_NAME>-db-config. So if you want to connect to an external database, you can change the data within the
secret to point to an external database (or better create a service pointing to that database and add the data for this
endpoint to the secret to de-couple the external database).

> _**A note for new k8s devops:**_ When accessing an external database, please don't wire the external service directly into your configuration. It is
much better to create a service definition pointing to the external source. If the source changes you only need to 
change this single service instead of all pods where the datatabase server (for example) is wired into. That can you
save a lot of work, make changes less error-prone and if used consequently, you have a single point to look for external
dependencies (the services) instead of all pods.

The database itself is not backuped. We use the Wordpress modules to export the database. So importing it to other 
installations where some IDs may be changed is more easy.

## To dos
Well, Backup is only halfway done (I included exporter doing the database and file backup). You still need something
like the stash project to really backup the data from the PV and database. Perhaps one of my next projects. 