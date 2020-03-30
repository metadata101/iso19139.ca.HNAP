# ISO Harmonized North American Profile (HNAP) plugin for GeoNetwork

ISO Harmonized North American Profile (HNAP)

## Installing the plugin

### GeoNetwork version to use with this plugin

Use GeoNetwork 3.10+. It's not supported in older versions so don't plug it into it!

### Adding the plugin to the source code

The best approach is to add the plugin as a submodule. Use https://github.com/geonetwork/core-geonetwork/blob/3.10.x/add-schema.sh for automatic deployment:

```
./add-schema.sh iso19139.ca.HNAP https://github.com/metadata101/iso19139.ca.HNAP 3.10.x
```
```
./add-schema.sh iso19139.ca.HNAP https://github.com/GeoCat/iso19139.ca.HNAP.git  3.10.x
```

### Build the application

Once the application is built, the war file contains the schema plugin:

```
$ mvn clean install -Penv-prod
```

### Deploy the profile in an existing installation

The plugin can be deployed manually in an existing GeoNetwork installation:

Copy the content of the folder `schemas/iso19139.ca.HNAP/src/main/plugin` to `INSTALL_DIR/geonetwork/WEB-INF/data/config/schema_plugins/iso19139.ca.HNAP`.


# Changes To Standard Schema Build and Initialization

There is some custom code that gets run when GeoNetwork starts up.

This will look in the GeoNetwork Data Directory (ThesauriDir) and check to see if the HNAP Thesauruses are already there.  If they are not (i.e. this is the very first run of GeoNetwork with the HNAP Schema), then they are are copied from the JAR to the correct location in the Data Directory.  Otherwise it does nothing.


See `SchemaInitializer.java`

