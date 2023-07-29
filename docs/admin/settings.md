# Settings

## Settings: System

Common `Admin Console > Settings`{.interpreted-text
role="menuselection"} to review from the `Settings`{.interpreted-text
role="guilabel"} page:

1.  Catalog server:

    -   Network details: Update to accurately identify this web service.
    -   Log level: Change level of detail reported for troubleshooting,
        return to [PROD]{.title-ref} for general use.

    ![](img/catalog_server.png)
    *Catalog server*

2.  Feedback: mail configuration

    ![](img/feedback.png)
    *Feedback settings.*

3.  Proxy server: optional proxy used to allow geonetwork to access
    external web services.

    ![](img/proxy.png)
    *Proxy service*

4.  A subset of settings for
    `Admin Console > Settings`{.interpreted-text role="menuselection"}
    are required for validation and managed during application startup.

    Site:

    -   system/site/name
    -   system/site/organization

    Schema settings:

    -   schema/iso19139.ca.HNAP/DefaultMainOrganizationName_en
    -   schema/iso19139.ca.HNAP/UseGovernmentOfCanadaOrganisationName
    -   schema/iso19139.ca.HNAP/DefaultMainOrganizationName_fr
    -   system/metadata/validation/removeSchemaLocation

    See initialization file
    `initialization/settings/settings.json`{.interpreted-text
    role="file"} for details.

## Settings: User Interface

Settings for `Admin Console > Settings`{.interpreted-text
role="menuselection"} `UI Settings`{.interpreted-text role="guilabel"}
page;

-   HNAP adds a [layers=\<name\>]{.title-ref} parameter to the
    GetCapabilities URL used to document a WMS Service

    To support this functionality locate
    `Add WMS layers from metadata to the map viewer`{.interpreted-text
    role="guilabel"} heading, and change the
    `URL parameter with the layer name`{.interpreted-text
    role="guilabel"} to `layers`{.interpreted-text role="kbd"}.

    ![](img/wms-url-param-setting.png)
    alt="img/wms-url-param-setting.png" />
    *HNAP setting for URL parameter*
