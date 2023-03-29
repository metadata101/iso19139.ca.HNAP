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

GeoNetwork 4 provides the ability to perform a search and replace in the database:

1. Navigate to :menuselection:`Contribue > Edit Console`.
2. Press :guilabel:`Batch editing`.
3. From :guilabel:`Choose a set of records` tab, select ``All``.
4. Navigate to :guilabel:`Define edits` tab, select :guilabel:`Search and replace` with:

   .. list-table::
      :widths: 30 70
      :width: 100%
      :stub-columns: 1

      * - Value:
        - :kbd:`http://nap.geogratis.gc.ca/metadata/register/`
      * - Replacement:
        - :kbd:`https://schemas.metadata.geo.ca/register/`
      * - Regular expression flags
        - (no selection is required)

5. Navigate to :guilabel:`Apply edits` tab, and press :guilabel:`Save`.

   .. note:: We have not selected :guilabel:`Update the modification date in the metadata document` as this change reflects a change of infrastructure and not a change of the content of the metadata record.

GeoNetwork 3 content can be updated using the following SQL:

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
       'https://schemas.metadata.geo.ca/register/'
     );
