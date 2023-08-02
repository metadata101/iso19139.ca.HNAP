# Upgrade

## Migration to schemas.metadata.geo.ca

!!! note

    [iso19139.ca.HNAP 3.12.10 Release](https://github.com/metadata101/iso19139.ca.HNAP/releases/tag/3.12.10)

The published location of the HNAP schema has changed from
[nap.geogratis.gc.ca](http://nap.geogratis.gc.ca/metadata/tools/schemas/metadata/can-cgsb-171.100-2009-a/)
to [schemas.metadata.geo.ca](https://schemas.metadata.geo.ca/2009/).

The location of the HNAP registry used for code list definitions has
also changed:

-   `http://nap.geogratis.gc.ca/metadata/register/napMetadataRegister.xml` <br/>
    `https://schemas.metadata.geo.ca/register/napMetadataRegister.xml` <br/>
-   `http://nap.geogratis.gc.ca/metadata/register/registerItemClasses-eng.html` <br/>
    `https://schemas.metadata.geo.ca/register/registerItemClasses-eng.html`

Individual records can be upgraded by saving and loading in the editor:

1.  Open the record in the editor.
2.  Press `Save and Close`.

To update all records in the database use the following SQL:

``` sql
UPDATE Metadata SET data =
  replace(
     data,
    'http://nap.geogratis.gc.ca/metadata/register/',
    'https://schemas.metadata.geo.ca/register/'
  );
UPDATE MetadataDraft SET data =
  replace(
    data,
    'http://nap.geogratis.gc.ca/metadata/register/',
    'https://schemas.metadata.geo.ca/register/'
  );
```
