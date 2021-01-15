Edit
====

Edit record
-----------

#. There are several ways to open the record editor when viewing a record:
     
   .. figure:: img/record_view_edit.png
      
      Record view edit

#. The record editor is started using the :guilabel:`Basic view`, showing the document title, current editor status, and a toolbar of editor actions.

   .. figure:: img/basic_view.png
      
      Record editor basic view

#. The :guilabel:`Categories` dropdown shows the categorization of the record. To update use the checkboxes to assign one or more categories to the record. 
   
   .. figure:: img/categories.png
      
      Change metadata Categories

#. Use the :guilabel:`Group` to show the group containing the record. To update use the radio button to transfer the record to a different group.

   .. figure:: img/group.png
      
      Change metadata group

#. Use the :guilabel:`Validate` button to check the structure and contents of the record.

   Validation feedback is shown on the right-hand side of the screen.
   
   .. figure:: img/validate.png
      
      Record validation

#. Editing is completed using:

   * :guilabel:`Cancel` to abandon any changes and return to viewing record.   
   * :guilabel:`Save & close` to apply changes and return to viewing record.
   * :guilabel:`Save metadata` to apply changes and continue editing
   
   .. figure:: img/record_save.png
      
      Record apply, save and cancel options
      
#. Use the :guilabel:`View mode` (at the top of the screen on the far right) to choose the editor you would like to use.

   * Basic view
   * Advanced view
   * XML view
  
   Options to toggle tooltips and show more detail adjust how the editor is shown.
   
#. :guilabel:`Basic view` is recommended and provides easy access to the most commonly required fields.
     
   Basic view is often used when editing an existing document. 
    
   .. figure:: img/view_mode_basic.png
      
      Display mode basic view

#. The :guilabel:`Tooltips` and :guilabel:`More details` are used to toggle additional options for field editing.
     
   .. figure:: img/view_mode_options.png
      
      Basic view with tooltips and more detail turned off.

#. :guilabel:`Advanced view` provides greater control over document structure, with :guilabel:`+`  buttons to add additional information. 
   
   Advanced view is often used to add new sections when creating a document from scratch.
 
   .. figure:: img/view_mode_advanced.png
      
      Display mode advanced view

#. :guilabel:`XML view` is used to review the machine readable :file:`xml` content.
      
   The XML view is almost exclusively used for troubleshooting and is not recommended.
   
   .. figure:: img/view_mode_xml.png
      
      Display mode xml view

#. Tips and tricks for editing records:
   
   * To edit directly from search results use the :guilabel:`Edit` button (shown as a pencil icon below).
     
     .. figure:: img/search_results_edit.png
        
        Search results edit

Editor navigation
-----------------

#. Records are divided into a series of nested sections covering different subjects.
   
   Each section has a heading, use the :kbd:`v` toggle next to each heading to hide and show the section contents.
   
   .. figure:: img/record_headings.png
      
      Record headings

#. A overview of :guilabel:`Metadata record information` providing quick navigation is available at the bottom right of the page.

   * Click on a heading to jump to that section of the record.
   * As you scroll the overview will update to show the headings on screen in bold.
   
   .. figure:: img/metadata_record_information.png
      
      Metadata record information.

#. The bottom right of the screen also includes a :guilabel:`Scroll to top` button.

Editor fields
--------------

#. Record editing make use of data entry fields consisting of:
   
   * Label naming field content
   * Text field for data entry
   * :guilabel:`Delete this field` button to remove optional content.
   * :guilabel:`Tooltip` shown as a `?` icon, describing field.
   
   .. figure:: img/text_field.png
      
      Text field.

#. Mandatory fields are labeled with a ``*``:

   .. figure:: img/mandatory.png
      
      Mandatory field

#. Fields that cannot be edited are shown grayed out.
   
   .. figure:: img/non_editable.png
      
      Non-editable field
      
#. To access tooltip information hover mouse pointer over :guilabel:`?` icon.
   
   .. figure:: img/tooltip.png
      
      Field tool tip

#. Use :guilabel:`Delete this field` to remove optional fields.

   .. figure:: img/delete.png
      
      Delete this field

#. Text fields are used for data entry.

   .. figure:: img/text_field.png
      
      Text field.

#. Some text fields with a large number of options offer the ability to type or search
   to narrow down valid suggestions.
   
   .. figure:: img/text_field_search.png
   
      Type or search field
       
#. Select fields are used to choose between a limited number of options:
   
    .. figure:: img/select_field.png
      
       Select field
   
    .. note:: Occasionally these fields will show an empty line, where a value has not been provided yet.

Optional vs Nil
---------------

#. Optional values, can be removed using :guilabel:`Delete this field`.

   This button can be used to remove the :guilabel:`Country` field from and address.
   
   .. figure:: img/delete_country.png
      
      Delete optional country field
      
   This field is no longer included in the record (and may be re-added if needed using the Advanced view).
   
#. Advanced: Fields can also be filled in as :guilabel:`Nil` by opening up the :guilabel:`View mode` at the top of the screen and selected :guilabel:`More details` checkbox.
   
   This provides additional :guilabel:`Nil reason` buttons that can be used to add one or more reasons why a value cannot be provided.
   
   .. figure:: img/nil_reason.png
      
      Email address witheld
   
   .. note:: Be careful marking mandatory fields as Nil, as the resulting record may not be considered valid.
