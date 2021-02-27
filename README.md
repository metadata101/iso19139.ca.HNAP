# ISO Harmonized North American Profile (HNAP) plugin for GeoNetwork

The Canadian GeoNetwork community is pleased share the *ISO Harmonized North American Profile (HNAP)* schema plugin. This is a bilingual extension of the *North American Profile of ISO 19115:2003 - Geographic information - Metadata* used nationally.

For details on this release see [3.7.0 Milestone](https://github.com/metadata101/iso19139.ca.HNAP/milestone/4?closed=1) release notes for details.

## User Manual

[User Manual (HNAP)](https://metadata101.github.io/iso19139.ca.HNAP/) is provided for end-users. The user manual explores catalog use using HNAP examples. This is an end-user supliment to the far more technical [GeoNetwork User and Developer Manuals](https://geonetwork-opensource.org/manuals/trunk/en/index.html).

This user manual is available for local installation. 

## Communication

The [project issue tracker](https://github.com/metadata101/iso19139.ca.HNAP/issues) is used for communication, with ongoing topics tagged [discussion](https://github.com/metadata101/iso19139.ca.HNAP/issues?q=is%3Aissue+label%3Adiscussion).

## Installation

### GeoNetwork version to use with this plugin

Use GeoNetwork ``3.10.x``, not tested with prior versions!

The schema plugin editor makes use of a number of controls for editing structured text fields requiring newer releases of core-geonetwork.

### Deploy the profile in an existing installation

The plugin can be deployed manually in an existing GeoNetwork installation:

1. Download from [releases](https://github.com/metadata101/iso19139.ca.HNAP/releases) page.
   
   Each release includes a `jar`, `zip`, and `doc` download.

2. Extract contents of the `schema-iso19139.ca.HNAP` zip download into `WEB-INF/data/config/schema_plugins/iso19139.ca.HNAP`.

3. Copy the `schema-iso19139.ca.HNAP` jar to geonetwork `WEB-INF/libs`

6. Copy the `schema-iso19139.ca.HNAP` doc to geonetwork `doc`

5. Restart geonetwork

There is some custom initialization code run when GeoNetwork starts up:

1. The plugin includes will check the GeoNetwork Data Directory `ThesauriDir` to see if the HNAP Thesauruses are already installed.

2. If they are not (i.e. this is the very first run of GeoNetwork with the HNAP Schema), the required thesaurus files are are copied from the `jar` into to the correct location in the Data Directory.

  See `SchemaInitializer.java` for details.

## Building

### Adding the plugin to the source code

The best approach is to add the plugin as a submodule:

1. Use [add-schema.sh](https://github.com/geonetwork/core-geonetwork/blob/3.10.x/add-schema.sh) for automatic deployment:

   ```
   ./add-schema.sh iso19139.ca.HNAP https://github.com/metadata101/iso19139.ca.HNAP 3.10.x
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

2. Copy `schema-iso19139.ca.HNAP` jar from `target` into geonetwork `WEB-INF/libs``.

3. Restart geonetwork

## Documentation

Documentation is [sphinx-build](https://www.sphinx-doc.org/) with [sphinx-rtd-theme](https://sphinx-rtd-theme.readthedocs.io/en/stable/). GeoCat has provided a [writing guide](https://geocat.github.io/geocat-themes/) on the use of ``rst`` directives and formatting.

Generated docs:

```
mvn clean compile -Pdocs
```

Docs generated into `target/html/index.html`:

```
open target/html/index.html
```

Package docs into `zip`:

```
mvn package -Pdocs
```

### sphinx-build environment

windows:

```
pip install -U sphinx
pip install hieroglyph recommonmark sphinx-copybutton
```

macOS:

```
brew install python
brew install sphinx-doc
pip install hieroglyph recommonmark sphinx-copybutton
```

jenkins:

* [Dockerfile](https://github.com/GeoCat/jenkins-docker-agent-docs/blob/master/Dockerfile)

## Project Procedures

### Publish User Guide Process

### update github pages

```
mvn clean install -Pdocs
git add docs
git commit -m "update docs"
git push
```
### User Guide Internationalization

Translation workflow:

1. Before you start:

   ```
   pip install sphinx-intl
   ```

2. Generate `pot` files, and generate messages for translation:
   
   ```
   mvn compile -Ptranslate
   ```
   
   This performs:
   ```
   sphinx-build -b gettext src/sphinx target/gettext
   sphinx-intl -c src/sphinx/conf.py update -p target/gettext -l fr
   ```

3. Each ``rst`` file has a matching messages ``po`` file in ``src/local/fr/LC_MESSAGES``.

   Message files follow the ``gettext`` portable object ``po`` format:
   
   ```
   #: ../../src/sphinx/index.rst:3 338fd9f388f64839963b54e20898e403
   msgid "User Manual"
   msgstr "Manuel d'Utilisateur"
   ```
   
   Messages are described using:
   
   * ``#`` a comment documenting the line number, and a uuid used to help as content is updated over time
   * ``msgid`` origional
   * ``msgstr`` translation, please take care not to break sphinx directives
   
   Plenty of tools are available to work with ``po` files.
   
   * https://poedit.net
   * http://transifex.com

4. Optional: translates images, figures and screen snaps:

   * ``img/sample.png`` origional, `img/sample_fr.png`` translation.
   * ``figure/example.svg`` origional, ``figure/example_fr.svg`` translation.

Transifex workflow (optional):

1. Create an account on transifex: https://www.transifex.com/

   Transifex offers a cloud based editor for internationalization, it is good at
   suggesting translations by remembering prior translation of similar phrases.

2. Translate content at: https://www.transifex.com/geonetwork/metadata101/

Developers transifex workflow:

1. Before you start: install the transifex command line client:

   ```
   pip install transifex-client
   ```
   
   And setup your ``~/.transifexrc` using::
   
   ```
   tx init --token API_KEY --no-interactive
   ```
   
   Use https://www.transifex.com/user/settings/api/ to generate the ``API_KEY`` above.

2. Stage the ``en`` docs into ``.tx/config`` for transifex to work with:

   ```
   tx config mapping-bulk --project metadata101 --file-extension '.pot' --source-file-dir 'target/gettext' --source-lang en --type PO --expression 'src/locale/<lang>/LC_MESSAGES/{filepath}/{filename}.po' --execute
   ```
   
   If you look into ``.tx/config`` you will see each fileis mapped:
   
   ```
   [metadata101.target_gettext_index]
   file_filter = src/locale/<lang>/LC_MESSAGES/index.po
   source_file = target/gettext/index.pot
   source_lang = en
   type = PO
   ```

3. Push the changes mapped in ``.tx/config`` to transifex:
   
   ```
   tx push --source
   ```

4. Pull changes mapped in ``.tx/config`` from transifex:
   
   ```
   tx pull --all
   ```

For more information:
  
* https://www.sphinx-doc.org/en/master/usage/advanced/intl.html
* https://www.gnu.org/software/gettext/
* https://sphinx-intl.readthedocs.io/en/master/quickstart.html
* https://docs.readthedocs.io/en/stable/guides/manage-translations.html
* https://docs.transifex.com/integrations/sphinx-doc

### Release Process

1. Update the ``pom.xml`` version information.

   ```
   find . -name `pom.xml` -exec sed -i '' 's/3.10-SNAPSHOT/3.10.7-0/g' {} \;
   ```
   
2. Build everything, including documentation:
   
   ```
   mvn clean install -Pdocs
   ```

3. Commit and tag
   
   ```
   git add pom.xml
   git commit -am "Version 3.10.7"
   git tag -a 3.10.6 -m "Release 3.10.7"
   git push origin 3.10.7
   ```

4. Navigate to release page: https://github.com/metadata101/iso19139.ca.HNAP/releases

   Click ``Edit tag`` button:
   
   * Title: ``iso19139.ca.HNAP 3.10.7 Release``
   
   * Content: Copy from [README.md](https://raw.githubusercontent.com/metadata101/iso19139.ca.HNAP/3.10.x/README.md)

   * Upload artifacts from ``target`` to the new github page.

5. Restore the `pom.xml` version information.

   ```
   find . -name `pom.xml` -exec sed -i '' 's/3.10.7-0/3.10-SNAPSHOT/g' {} \;
   ```
6. Create the next milestone: https://github.com/metadata101/iso19139.ca.HNAP/milestones
   
   * Title: ``3.10.8``
   * Date: leave empty
   * Content: ``Released in conjunction with core-geonetwork 3.10.8.``
   
7. Update ``README.md`` to link to new milestone:
    
   ```
   For details on this release see [3.10.8 Milestone](https://github.com/metadata101/iso19139.ca.HNAP/milestone/5?closed=1)
   release notes for details.
   ```
   
8. Commit 
   
   ```
   git add pom.xml README.md
   git commit -m "Start 3.10.8 development"
   git push
   ```
