# Users and Groups

The `Admin Console > Users and Groups`{.interpreted-text
role="menuselection"} is managed during application startup based on
active directory services.

## Groups

A single group is created on startup:

-   [Sample Group]{.title-ref}

    This group is configured with label [Sample Group]{.title-ref} and
    the geonetwork logo.

Additional groups can be manually added using the administration
console.

## Users

User can be manually managed using the administration console.

### LDAP

When using LDAP users are created during login based on active directory
services:

-   [GeoNetwork_Admin]{.title-ref} users added to [Sample
    Group]{.title-ref} with Administrator role
-   [GeoNetwork_Editor]{.title-ref} users added to [Sample
    Group]{.title-ref} with Editor role

The [Administrator]{.title-ref} role provides access to the
`Admin console`{.interpreted-text role="guilabel"} and is not related to
group access.

See configuration file
[WEB-INF/config-security/config-security-ldap.xml]{.title-ref} for
details.
