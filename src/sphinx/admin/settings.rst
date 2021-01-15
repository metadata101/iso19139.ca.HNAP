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

Settings for :menuselection:`Admin Console > Settings` :guilabel:`UI Settings` page are replaced during application startup. These settings are used to configure the custom theme.

See :file:`initialization/settings/uisettings.json` for details.