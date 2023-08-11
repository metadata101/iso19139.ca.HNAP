# ISO Harmonized North American Profile (HNAP) plugin for GeoNetwork

The Canadian GeoNetwork community is pleased share the *ISO Harmonized North American Profile (HNAP)* schema plugin. This is a bilingual extension of the *North American Profile of ISO 19115:2003 - Geographic information - Metadata* used nationally.

For details on this release see [3.12.11 Milestone](https://github.com/metadata101/iso19139.ca.HNAP/milestone/19?closed=1) release notes for details.

## User Manual

[User Manual (HNAP)](https://metadata101.github.io/iso19139.ca.HNAP/) is provided for end-users. The user manual explores catalog use using HNAP examples. This is an end-user supliment to the far more technical [GeoNetwork User and Developer Manuals](https://geonetwork-opensource.org/manuals/trunk/en/index.html).

This user manual is available for local installation. 

## Communication

The [project issue tracker](https://github.com/metadata101/iso19139.ca.HNAP/issues) is used for communication, with ongoing topics tagged [discussion](https://github.com/metadata101/iso19139.ca.HNAP/issues?q=is%3Aissue+label%3Adiscussion).

## Installation

### GeoNetwork version to use with this plugin

Use GeoNetwork ``3.12.x``, not tested with prior versions!

The schema plugin editor makes use of a number of controls for editing structured text fields requiring newer releases of core-geonetwork.

### Deploy the profile in an existing installation

The plugin can be deployed manually in an existing GeoNetwork installation:

1. Download from [releases](https://github.com/metadata101/iso19139.ca.HNAP/releases) page.
   
   Each release includes a `jar`, `zip`, and `doc` download.

2. Extract contents of the `schema-iso19139.ca.HNAP` zip download into `WEB-INF/data/config/schema_plugins/iso19139.ca.HNAP`.

3. Copy the `schema-iso19139.ca.HNAP` jar to geonetwork `WEB-INF/lib`

6. Copy the `schema-iso19139.ca.HNAP` doc to geonetwork `doc`

5. Restart geonetwork

There is some custom initialization code run when GeoNetwork starts up:

1. The plugin includes will check the GeoNetwork Data Directory `ThesauriDir` to see if the HNAP Thesauruses are already installed.

2. If they are not (i.e. this is the very first run of GeoNetwork with the HNAP Schema), the required thesaurus files are are copied from the `jar` into to the correct location in the Data Directory.

  See `SchemaInitializer.java` for details.

## Building

### Adding the plugin to the source code

The best approach is to add the plugin as a submodule:

1. Use [add-schema.sh](https://github.com/geonetwork/core-geonetwork/blob/3.12.x/add-schema.sh) for automatic deployment:

   ```
   ./add-schema.sh iso19139.ca.HNAP https://github.com/metadata101/iso19139.ca.HNAP 3.12.x
   ```

2. Build the application:
   
   ```
   mvn clean install -Penv-prod -DskipTests
   ```
   
3. Once the application is built, the war file contains the schema plugin:

   ```
   cd web
   mvn jetty:run -Penv-dev
   ```

### Deploy locally built profile into existing installation

1. Copy the `iso19139.ca.HNAP` folder from `schemas/iso19139.ca.HNAP/src/main/plugin` into geonetwork `WEB-INF/data/config/schema_plugins/`.

2. Copy `schema-iso19139.ca.HNAP` jar from `target` into geonetwork `WEB-INF/lib`.

3. Restart geonetwork

## Documentation

Documentation is [mkdocs-material](https://squidfunk.github.io/mkdocs-material/) which is a Markdown documentation framework written on top of [MkDocs](https://www.mkdocs.org/).

If you are familiar with python you can install using ``pip3`` and build:

```bash
pip3 install -r requirements.txt
mkdocs serve
open http://localhost:8000
```

If you use a python virtual environment:
```
virtualenv venv
source venv/bin/activate
pip install -r requirements.txt
mkdocs serve
open http://localhost:8000
```

If you are not familiar with python the mkdocs-material website has instructions for docker:
```
docker pull squidfunk/mkdocs-material
docker run --rm -it -p 8000:8000 -v ${PWD}:/docs squidfunk/mkdocs-material
open http://localhost:8000 
```

## Writing Guide

GeoCat has provided a [writing guide](https://geocat.github.io/geocat-themes/) for sphinx documentation. While the writing conventions should be followed, adapting sphinx direcives to markdown formatting requires some work.

When converting to markdown we can only focus on the visual appearance, converting many sphinx directives to their closest visual counterpart: 

| Markdown          | Sphinx directive                  |
| ----------------- | --------------------------------- |
| `*emphais*`       | gui-label, menuselection          |
| `` `monospace` `` | file, text input, item selection  |
| `*bold*`          | command                           |

### User interface components

Use ``**strong**`` to name user interface components for interaction (press for buttons, click for link).

> Navigate to **Data > Layers** page, and press **Add** to create a new layer.
> ```
> Navigate to :menuselection:`Data > Layers` page, and press :guilabel:`Add`` to create a new layer.
> Navigate to **Data > Layers** page, and press **Add** to create a new layer.
> ```

### User input

Use `` `item` `` for user supplied input, or item in a list or tree::

> Select `Basemap` layer.
> ```
> Select ``Basemap`` layer.
> Select `Basemap` layer.
> ```

Use `` `text` `` for user supplied text input:

> Use the *Search* field enter `Ocean*`.
> ```
> Use the :guilabel:`Serach` field to enter :kbd:`Ocean*`.
> Use the *Search* field enter `Ocean*`.
> ```

Use ``++key++`` for keyboard keys.

> Press ++Control-s++ to search.
> ```
> Press :key:``Control-s`` to search.
> Press ++control+s++ to search.
> ```

Use definition list to document for entry. The field names use emphasis as they name a user interface element. Field values to input uses monspace as user input to type in.

Preview:

> #. Log in as the GeoServer administrator.
>    
>    *User*
> 
>    : `admin`
>
>    *Password*
>
>    : `geoserver`
>    
>    *Remeber me*
> 
>    : Unchecked

Previously sphinx-build used list-table:

> ```
> #. Log in as the GeoServer administrator.
> 
>    .. list-table::
>       :widths: 30 70
>       :width: 100%
>       :stub-columns: 1
> 
>       * - User:
>         - :kbd:`admin`
>       * - Password:
>         - :kbd:`geoserver`
>       * - Remember me
>         - Unchecked
> ```

Markdown uses definition lists:

> ```
> #. Log in as the GeoServer administrator.
>    
>    *User*
> 
>    : `admin`
>
>    *Password*
>
>    : `geoserver`
>    
>    *Remeber me*
> 
>    : Unchecked
> ```

### Applications, commands and tools

Use **bold** and **italics** for proper names of applications, commands, tools, and products.

> Launch ***pgAdmin*** and connect to the databsae `tutorial`.
> ```
> Launch :command:`pgAdmin` and connect to the ``tutorial`` database.
> Launch ***pgAdmin*** and connect to the databsae `tutorial`.
> ```

### Files

Use **bold** **monospace** for files and folders:

> See configuration file **``WEB-INF/config-security/config-security-ldap.xml``** for details
> ```
> See configuration file :file:`WEB-INF/config-security/config-security-ldap.xml` for details
> See configuration file **``WEB-INF/config-security/config-security-ldap.xml``** for details
> ```


### Links and references

Specific kinds of links:

Reference to other section of the document (some care is required to reference a specific heading):

> Editors have option to [manage](../editor/publish/index.md#publish-records) records.
> ```
> Editors have option to :ref:`manage <Publish records>` records.
> Editors have option to [manage](../editor/publish/index.md#publish-records) records.
> ```

Download of sample files:

Example:

> Download schema [**`example.xsd`**](files/example.xsd).
> ```
> Download schema :download:`example.xsd <files/example.xsd>`.
> Download schema [**`example.xsd`**](files/example.xsd).
> ```

### Icons, Images and Figures

Material for markdown has extensive icon support, for most user interface elements we can directly make use of the appropriate icon in markdown:

```
1.  Press the *Validate :fontawesome-solid-check:* button at the top of the page.
```

Add cusotm icons to `overrides/.icons/geocat`:
```
Thank you from the GeoCat team!
:geocat-logo:
```

Figures are handled by convention, adding emphasized text after each image, and trust CSS rules to provide a consistent presentation:

```
![](img/begin_date.png)
*Value is required for Begin Date*
```

Raw images are not used very often:
```
![](img/geocat-logo.png)
```

## Document Conversion Notes

Pandoc used for initial conversion to Markdown:
```
cp -r src/sphinx docs
cd docs
find . -name \*.rst -type f -exec pandoc -o {}.md {} \;
```

Searches used to clean up content:
```
``{.interpreted-text role="guilabel"} **Cancel**
`waterways`{.interpreted-text role="kbd"} `waterways`
```

## Project Procedures

### Publish User Guide Process

A github page automation is used to update https://metadata101.github.io/iso19139.ca.HNAP/ each time the active branch is updated:

* ``.github/workflows/ci.yml``

When working on a fork you can manually update your own github pages using:
```
mkdocs gh-deploy --force
```

### User Guide Internationalization

Reviewing the use of https://www.deepl.com/translator

Presently copy and paste page by page to translate.

The use of the API warns that text markup causes problems and may not be reserved. It suggests breaking translation down into sentences; or generating html and using the option to ignore tags (which in effect breaks everything down to sentences).

### Release Process

1. Update the ``pom.xml`` version information for release:

   ```
   find . -name 'pom.xml' -exec sed -i '' 's/3.12-SNAPSHOT/3.12.7/g' {} \;
   ```

2. Update the [src/main/plugin/iso19139.ca.HNAP/schema-ident.xm](src/main/plugin/iso19139.ca.HNAP/schema-ident.xml#L32) ``appMinorVersionSupported``:

   ```
   sed -i '' 's/3.12-SNAPSHOT/3.12.7/g' src/main/plugin/iso19139.ca.HNAP/schema-ident.xml
   ```
   
4. Build everything, deploying to osgeo repository:
   
   ```
   mvn clean install deploy
   ```

3. Commit and tag
   
   ```
   git add .
   git commit -am "Version 3.12.7"
   git tag -a 3.12.7 -m "Release 3.12.7"
   git push origin 3.12.7
   ```

4. Navigate to release page: https://github.com/metadata101/iso19139.ca.HNAP/releases

   Click ``Edit tag`` button:
   
   * Title: ``iso19139.ca.HNAP 3.12.7 Release``
   
   * Content: Copy from [README.md](https://raw.githubusercontent.com/metadata101/iso19139.ca.HNAP/3.12.x/README.md)

   * Upload artifacts from ``target`` to the new github page.

5. Restore the `pom.xml` and `schema-ident.xml` version information.

   ```
   find . -name 'pom.xml' -exec sed -i '' 's/3.12.7-0/3.12-SNAPSHOT/g' {} \;
   sed -i '' 's/3.12.7-0/3.12-SNAPSHOT/g' src/main/plugin/iso19139.ca.HNAP/schema-ident.xml
   ```

6. Create the next milestone: https://github.com/metadata101/iso19139.ca.HNAP/milestones
   
   * Title: ``3.12.8``
   * Date: leave empty
   * Content: ``Released in conjunction with core-geonetwork 3.12.8.``
   
7. Update ``README.md`` to link to new milestone:
    
   ```
   For details on this release see [3.12.8 Milestone](https://github.com/metadata101/iso19139.ca.HNAP/milestone/5?closed=1)
   release notes for details.
   ```
   
8. Commit 
   
   ```
   git add .
   git commit -m "Start 3.12.8 development"
   git push
   ```
