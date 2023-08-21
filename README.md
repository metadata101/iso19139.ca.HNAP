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

Reference:

* [Documentation Writing Guide](docs/devel/docs/docs.md)

## Document Conversion Notes

Translation makes use of document conversion between markdown and html. As a result some markdown extensions cannot be used:

* simple_tables cannot be used by github-flavored-markdown, use pipe_tables instead


Pandoc used for initial conversion from rich-structured-text to markdown:
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

Plugins are available for content translation:

* https://github.com/mondeja/mkdocs-mdpo-plugin using https://github.com/mondeja/mdpo
* https://github.com/ultrabug/mkdocs-static-i18n

Reviewing the use of https://www.deepl.com/translator

The API warns that text markup causes problems and may not be reserved. It suggests breaking translation down into sentences; or generating html and using the option to ignore tags (which in effect breaks everything down to sentences).

1. Convert page to html using pandoc:
   
   ```
   cd docs
   pandoc --from gfm -o index.docx index.md
   ```

2. Review `docx` output first, simply any comlicated markdown until you get simple result:
   
   * Admonitions: Notes, Warnings, ...
   
   You may also consider letting these sections fail and converting them sentence by sentence.
   
3. Use https://www.deepl.com/translator to convert the `docx` file.

4. Convert back to markdown using pandoc:
   
   ```
   pandoc --from docx --to gfm -o index.fr.docx index-fr.docx
   ```

5. Restore markdown:
   
   * Admonitions: Notes, Warnings, ...
   
6. Carefully review:

   * Use live preview to compare both pages
   * Compare against original markdown formatting
   * During PR file review check for differences in formatting
   
   Pandoc markdown conversion will not fully support MkDocs ``pymdownx`` extensions, with ``gfm`` github-flavored-markdown being the closest equivalent.

While I have been successful in converting to `html` and using Deepl REST API, it is also labour intensive and offers no advantage over manual process above.

```
pip3 install -r translate/requirements.txt
python3 -m translate
```

Provide environmental variable with Deepl authentication key:
```
export DEEPL_AUTH="xxxxxxxx-xxx-...-xxxxx:fx"
```

Using pandoc html:
```
python3 -m translate html docs/index.md
python3 -m translate document docs/index.en.html docs/index.fr.html
```

Use mkdocs html file:
```
mkdocs build
python3 -m translate document target/html/index.html docs/index.fr.html
```

Convert back to markdown:
```
python3 -m translate markdown docs/index.fr.html
```

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
