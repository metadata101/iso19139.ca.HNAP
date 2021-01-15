Search records
==============

The GeoNetwork catalog provides a data portal listing datasets and resources.

Search Catalogue
----------------

#. Enter the desired keywords and search terms into the :guilabel:`Search` field at the top of the page and use :kbd:`Enter`, or the :guilabel:`Search` button, to list search results.

   .. figure:: img/search.png

      Search field

#. Search for complete words: :kbd:`Ocean`.

   .. figure:: img/search_results.png

      Search results for Ocean

#. The wildcard :kbd:`*` is used to match the start or end of word: :kbd:`Area*`

   Keep in mind the entire record contents is searched, not only the titles and description.

   .. figure:: img/search_area.png

      Search for start of a word

#. The wildcard :kbd:`*` can also be used multiple times to match part of a word: :kbd:`*resea*`

   .. figure:: img/search_resea.png

      Search for part of a word

Browse Catalogue
----------------

#. The catalog page can be explored using the quick lists of:

   * `Latest news`: recently updated records
   * `Most popular`: frequently used records
   * `Comments`: records with new comments and discussion

   .. figure:: img/browse_latest.png

      Latest news

#. Records are displayed as a block list, large list, or small list using the toggle on the right.

   Click on any of the listed records to view.

   .. figure:: img/browse_large_list.png

      Large list display of records

#. The catalog page provides a number of quick searches to browse catalog contents:

   * Use :guilabel:`Browse by Topics` to explore records based on subject matter.

   * Use :guilabel:`Browse by Resources` to explore different kinds of content.

   Each option lists "search facets" (shown as small bubbles), click on a "search facet" such as :guilabel:`Dataset` to explore.

   .. figure:: img/browse.png

      Browse metadata catalogue

#. Clicking on a "search facet" (``Environment`` in this example) lists matching records.

   .. figure:: img/browse_facet.png

      Search facet

Search Results
--------------

To further explore listed records:

#. Use the :guilabel:`Filter` section on the right hand side to refine your search using additional search facets, keywords, and details such as download format.

   .. figure:: img/browse_filter.png

      Filter results

#. Options are provided along the top to control the presentation of the matching records (as a grid or list) and advance to additional pages of results.

   .. figure:: img/browse_results.png

      Browse results

#. Advanced search options are located in the :guilabel:`...` menu next to the :guilabel:`Search` field at the top of the page. These options can be used to further refine search results by category, keywords, contact or date range.

   .. figure:: img/search_advanced.png

      Advanced search options

#. Use the Advanced search options :guilabel:`...` panel, the drop down for :guilabel:`Records created in the last` to select ``this week``.

   This acts as a short cut to fill in the from and to calendar fields. Press the :guilabel:`Search` button to filter using this date range.

   .. figure:: img/search_record_creation.png
      :scale: 50%

      Records updated in the last week.

   .. note:: The ``Record`` date filter to only show records with data identification (creation, publication, revision) dates included within the calendar date range.

      The `Resource` date filter is not presently used.

#. To search for records in the year ``2012`` use the advanced search options to fill in:

   .. list-table::
      :widths: 30 70
      :stub-columns: 1

      * - From
        - :kbd:`2012-01-01`
      * - To
        - :kbd:`2012-12-31`

   Press :guilabel:`Search` button to show records from ``2012``.

   .. figure:: img/search_record_2012.png
      :scale: 50 %

      Records updated in 2012

#. A slide out map is provided at the bottom of the page, providing visual feedback on the extent of each record.

   .. figure:: img/search_map.png

      Search map

   The map can be controlled by by toggling beween two modes:

   * Bounding Box: Click and drag to define an extent used to filter records. The drop down controls if the extent is used to list only records that are withing, or all records that intersect.

   * Pan: Click and drag the map location, using the mouse wheel to adjust zoom level.

#. Records are selected (using the checkbox located next to each one) to quickly download or generate a PDF of one or more records.

   .. figure:: img/browse_selection.png

      Selected Records

#. Additional tips and tricks with search results:

   * Details on :ref:`selecting multiple records and exporting<Download from search results>` as a :file:`ZIP` or :file:`PDF`.

   * Editors have additional options to :ref:`edit <Edit record>` and :ref:`manage <Publish records>` records.
