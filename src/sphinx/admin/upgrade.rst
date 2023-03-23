Upgrade
=======

Migration to schemas.metadata.geo.ca
------------------------------------

The published location of the HNAP schema has changed from
`nap.geogratis.gc.ca <http://nap.geogratis.gc.ca/metadata/tools/schemas/metadata/can-cgsb-171.100-2009-a/>`__ to
`schemas.metadata.geo.ca <https://schemas.metadata.geo.ca/2009/>`__.

The location of the HNAP registry used for code list definitions has also changed:

* ``http://nap.geogratis.gc.ca/metadata/register/napMetadataRegister.xml``
  | ``https://schemas.metadata.geo.ca/register/napMetadataRegister.xml``
* ``http://nap.geogratis.gc.ca/metadata/register/registerItemClasses-eng.html``
  | ``https://schemas.metadata.geo.ca/register/registerItemClasses-eng.html``

Individual records can be upgraded by saving and loading in the editor:

1. Open the record in the editor.
2. Select :command:`Save and Close`.

To update all records:

1. Navigate to :menuselection:`Admin console > Tools > Batch process`.
2. Select records to process, or choose ``All``.
3. Use :guilabel:`Configure a process` to select the process ``URL replacer``
4. Fill in process parameters:

   .. list-table::
       :widths: 30 70
       :width: 100%
       :stub-columns: 1

       * - URL prefix to search:
         - :kbd:`http://nap.geogratis.gc.ca/metadata/register/`
       * - Replace prefix by:
         - :kbd:`https://schemas.metadata.geo.ca/register/`

   And press :guilabel:`Run`

  .. figure:: img/upgrade_schemas_metadata_geo_ca.png

     URL Replacer process parameters

The database content can also be updated directly using the following SQL:

.. code-block:: text

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
       'https://schemas.metadata.geo.ca/register/
     );
