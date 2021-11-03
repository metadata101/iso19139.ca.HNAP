Settings
========

Settings: System
----------------

Common :menuselection:`Admin Console > Settings` to review from the :guilabel:`Settings` page:

#. Catalog server:

   * Network details: Update to accurately identify this web service.

   * Log level: Change level of detail reported for troubleshooting, return to `PROD` for general use.

   .. figure:: img/catalog_server.png

      Catalog server

#. Feedback: mail configuration

   .. figure:: img/feedback.png

      Feedback settings.

#. Proxy server: optional proxy used to allow geonetwork to access external web services.

   .. figure:: img/proxy.png

      Proxy service

#. A subset of settings for :menuselection:`Admin Console > Settings` are required for validation and managed during application startup.

   Site:

   * system/site/name
   * system/site/organization

   Schema settings:

   * schema/iso19139.ca.HNAP/DefaultMainOrganizationName_en
   * schema/iso19139.ca.HNAP/UseGovernmentOfCanadaOrganisationName
   * schema/iso19139.ca.HNAP/DefaultMainOrganizationName_fr
   * system/metadata/validation/removeSchemaLocation

   See initialization file :file:`initialization/settings/settings.json` for details.

Settings: User Interface
------------------------

Settings for :menuselection:`Admin Console > Settings` :guilabel:`UI Settings` page;

* HNAP adds a `layers=<name>` parameter to the GetCapabilities URL used to document a WMS Service

  To support this functionality locate :guilabel:`Add WMS layers from metadata to the map viewer` heading, and change the :guilabel:`URL parameter with the layer name` to :kbd:`layers`.

  .. figure:: img/wms-url-param-setting.png

     HNAP setting for URL parameter
