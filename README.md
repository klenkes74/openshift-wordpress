Modular Wordpress Openshift S2I Builder
==

Wordpress is a wide used CMS system. The easy admnistration for single installation is a problem when it comes to
containerization. Most Wordpress adaptions install the software during runtime on a persistent volume. This version
installs the software (including themes, plugins and languages) during container build. The software is unmutable.

The build is divided in two steps. First a generic basic container is build. This container contains the Apache HTTPd,
PHP, Wordpress and a selection of languages and plugins. This image can be generic within an organization. The build
is found in subdirectory 'wordpress' of this repository and should recide in a git repo of its own.

Then the specific application is build during a second step adding more plugins and languages and a theme (if wanted).
This part is specific for a special site. the configuration is found in 'site-blueprint' of this repo but normally is
found in a site-specifig repository.


Adding Plugins
--
Plugins need to be added to the file plugins.cfg. The file can be used in the base image builder and in the site
specific repository. The file contains one plugin and version per line. The entry has to be the basename of the zip
file to be downloaded from the official Wordpress Plugin repository.


Adding Languages
--
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

Adding Themes
--
Themes need to be added in the site-speficic repository. The script .s2i/bin/assemble contains the shell commands to
retrieve the theme and install it. It can be adapted to the needed theme.