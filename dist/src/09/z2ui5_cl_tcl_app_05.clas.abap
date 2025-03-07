CLASS z2ui5_cl_tcl_app_05 DEFINITION PUBLIC.

  PUBLIC SECTION.

    INTERFACES z2ui5_if_app.

    DATA mv_tab_name TYPE string VALUE `z2ui5_xlsx_t_01`.
    DATA mv_path TYPE string.
    DATA mv_value TYPE string.
    DATA mr_table TYPE REF TO data.
    DATA mv_check_edit TYPE abap_bool.
    DATA mv_check_download TYPE abap_bool.

  PROTECTED SECTION.

    DATA client TYPE REF TO z2ui5_if_client.
    DATA check_initialized TYPE abap_bool.

    METHODS ui5_on_event.
    METHODS ui5_view_main_display.

  PRIVATE SECTION.
ENDCLASS.



CLASS Z2UI5_CL_TCL_APP_05 IMPLEMENTATION.


  METHOD ui5_on_event.
    TRY.

        CASE client->get( )-event.

          WHEN 'START' OR 'CHANGE'.
            ui5_view_main_display( ).

          WHEN 'DOWNLOAD'.
            mv_check_download = abap_true.
            ui5_view_main_display( ).

          WHEN 'UPLOAD'.

            SPLIT mv_value AT `;` INTO DATA(lv_dummy) DATA(lv_data).
            SPLIT lv_data AT `,` INTO lv_dummy lv_data.

            DATA(lv_xdata) = z2ui5_cl_util=>conv_decode_x_base64( lv_data ).
            mr_table = z2ui5_cl_tcl_xlsx_api=>get_table_by_xlsx( lv_xdata ).
            client->message_box_display( `XLSX loaded to table` ).

            ui5_view_main_display( ).

            CLEAR mv_value.
            CLEAR mv_path.

          WHEN 'BACK'.
            client->nav_app_leave( client->get_app( client->get( )-s_draft-id_prev_app_stack ) ).

        ENDCASE.

      CATCH cx_root INTO DATA(x).
        client->message_box_display( text = x->get_text( ) type = `error` ).
    ENDTRY.
  ENDMETHOD.


  METHOD ui5_view_main_display.

    DATA(view) = z2ui5_cl_xml_view=>factory( ).
    DATA(page) = view->shell( )->page(
            title          = 'abap2UI5 - XLSX Uploader'
            navbuttonpress = client->_event( 'BACK' )
            shownavbutton  = abap_true
        ).

    page->sub_header(
            )->toolbar(
            )->label( 'Name'
            )->input( value = client->_bind_edit( mv_tab_name ) width = `20%`
            )->button( text = 'edit'
            )->toolbar_spacer(
*            )->button( text = 'File Upload'
*            )->button( text = 'View/Change/Download'
*            )->button( text = 'JSON/XML Editor'
            ).

    IF mv_check_download = abap_true.

      FIELD-SYMBOLS <tab> TYPE table.
      ASSIGN mr_table->* TO <tab>.
      mv_check_download = abap_false.
      DATA(lv_xlsx) = z2ui5_cl_tcl_xlsx_api=>get_xlsx_by_table( <tab> ).
      DATA(lv_base) = z2ui5_cl_util=>conv_encode_x_base64( lv_xlsx ).
      view->_generic( ns = `html` name = `iframe` t_prop = VALUE #( ( n = `src` v = `data:text/csv;base64,` && lv_base ) ( n = `hidden` v = `hidden` ) ) ).
    ENDIF.

    IF mr_table IS NOT INITIAL.
      ASSIGN mr_table->* TO <tab>.

      DATA(tab) = page->table(
              items = COND #( WHEN mv_check_edit = abap_true THEN client->_bind_edit( <tab> ) ELSE client->_bind_edit( <tab> ) )
          )->header_toolbar(
              )->overflow_toolbar(
                  )->title( 'XLSX Content'
                  )->toolbar_spacer(
                  )->switch(
                        change        = client->_event( `CHANGE` )
                        state         = client->_bind_edit( mv_check_edit )
                        customtexton  = 'Edit'
                        customtextoff = 'View'
          )->get_parent( )->get_parent( ).

      DATA(lr_fields) = z2ui5_cl_util=>rtti_get_t_attri_by_any( <tab> ).
      DATA(lo_cols) = tab->columns( ).
      LOOP AT lr_fields REFERENCE INTO DATA(lr_col).
        lo_cols->column( )->text( lr_col->name ).
      ENDLOOP.
      DATA(lo_cells) = tab->items( )->column_list_item( )->cells( ).
      LOOP AT lr_fields REFERENCE INTO lr_col.
        IF mv_check_edit = abap_true.
          lo_cells->input( `{` && lr_col->name && `}` ).
        ELSE.
          lo_cells->text( `{` && lr_col->name && `}` ).
        ENDIF.
      ENDLOOP.
    ENDIF.

    DATA(footer) = page->footer( )->overflow_toolbar( ).

    footer->_z2ui5( )->file_uploader(
      value       = client->_bind_edit( mv_value )
      path        = client->_bind_edit( mv_path )
      placeholder = 'filepath here...'
      upload      = client->_event( 'UPLOAD' ) ).

    footer->toolbar_spacer(
        )->button(
           text  = 'Download XLSX'
           press = client->_event( 'DOWNLOAD' )
           type  = 'Emphasized'
           icon  = 'sap-icon://download' ).

    client->view_display( view->stringify( ) ).

  ENDMETHOD.


  METHOD z2ui5_if_app~main.

    me->client = client.

    IF client->get( )-check_on_navigated = abap_true.
      ui5_view_main_display( ).
      RETURN.
    ENDIF.

    ui5_on_event( ).

  ENDMETHOD.
ENDCLASS.
