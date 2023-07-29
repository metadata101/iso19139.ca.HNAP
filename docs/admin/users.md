# Users and Groups

The *Admin Console > Users and Groups* is managed during application startup based on
active directory services.

## Groups

A single group is created on startup:

-   `Sample Group`

    This group is configured with label `Sample Group` and
    the geonetwork logo.

Additional groups can be manually added using the administration
console.

## Users

User can be manually managed using the administration console.

### LDAP

When using LDAP users are created during login based on active directory
services:

-   `GeoNetwork_Admin` users added to `Sample Group` with `Administrator` role
-   `GeoNetwork_Editor` users added to `Sample Group` with `Editor` role

The `Administrator` role provides access to the *Admin console* and is not related to
group access.

See configuration file **``WEB-INF/config-security/config-security-ldap.xml``** for
details.
