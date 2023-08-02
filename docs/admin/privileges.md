# Record Privileges

## Records Privileges

Selecting one or more records provides an opportunity to adjust the
privileges controlling what activities are available. Privileges are
provided to each group for fine grain control of record access.

!!! note

    [Managing privileges](https://geonetwork-opensource.org/manuals/3.12.x/en/user-guide/publishing/managing-privileges.html) (User Manual)

Manage group records editing access:

1.  Navigate to **Contribute > Editor board**.

2.  Select checkbox **GROUPS > Sample Group** to list all the
    records in group.

3.  At the start of the listed records locate the checkbox dropdown, and
    select **All**. This fills in the
    checkbox box next to each record on all of the records listed.

    ![](img/group_select.png)
    *Select all listed records*

4.  Use the **selected** drop-down to select **Update privileges** for
    the selected records.

    ![](img/group_selected_update_privileges.png)
    *Update privileges*

5.  Fill in privileges for the following groups:

    -   `All`: publish permissions to view published records.

        Built-in group representing visitors to the website.

    -   `Intranet`: publish and download permissions to view and
        download published records.

        Built-in group for authenticated users. Represents organization
        staff who have signed into the catalog and been authenticated.

    -   `Guest`: publish permission to view published records.

        Built-in group for website guests who have created their own
        account.

    -   `Staff`: Set-all privileges.

        Group used to give editing permissions to a select group of
        individuals, staff in this example, who have signed into the
        catalog and been authenticated as members.

    ![](img/record_privileges.png)
    *Record privileges*

6.  Press **Replace by selected** to update record permissions.

    This may take some moments to complete.

## Examples

Example of interaction between record group and record privileges:

-   For a record with *publish* privilege in `Sample Group`,
    any user assigned to the SampleGroup will be able to view the record.
-   For a record with *editing* privilege in `Sample Group`,
    any user assigned to the SampleGroup with `Editor` or `Reviewer` profile with be able
    to edit.
