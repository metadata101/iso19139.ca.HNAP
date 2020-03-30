# ISO Harmonized North American Profile (HNAP) plugin for GeoNetwork

ISO Harmonized North American Profile (HNAP)

## Installing the plugin

### GeoNetwork version to use with this plugin

Use GeoNetwork 3.8. It's not supported in older versions so don't plug it into it!

### Adding the plugin to the source code

The best approach is to add the plugin as a submodule. Use https://github.com/geonetwork/core-geonetwork/blob/3.8.x/add-schema.sh for automatic deployment:

```
./add-schema.sh iso19139.ca.HNAP https://github.com/metadata101/iso19139.ca.HNAP 3.8.x
```
```
./add-schema.sh iso19139.ca.HNAP https://github.com/GeoCat/iso19139.ca.HNAP.git  3.8.x
```

### Build the application
Once the application is built, the war file contains the schema plugin:

```
$ mvn clean install -Penv-prod
```

### Deploy the profile in an existing installation

The plugin can be deployed manually in an existing GeoNetwork installation:

Copy the content of the folder `schemas/iso19139.ca.HNAP/src/main/plugin` to `INSTALL_DIR/geonetwork/WEB-INF/data/config/schema_plugins/iso19139.ca.HNAP`.
