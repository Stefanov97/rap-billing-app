CLASS lhc_zi_bill_item DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS recalcHeaderNet FOR DETERMINE ON MODIFY
      IMPORTING keys FOR zi_bill_item~recalcHeaderNet.
    METHODS setCurrencyFromHeader FOR DETERMINE ON MODIFY
      IMPORTING keys FOR zi_bill_item~setCurrencyFromHeader.
    METHODS recalcHeaderNetOnDelete FOR DETERMINE ON MODIFY
      IMPORTING keys FOR zi_bill_item~recalcHeaderNetOnDelete.

ENDCLASS.

CLASS lhc_zi_bill_item IMPLEMENTATION.

  METHOD recalcHeaderNet.

    READ ENTITIES OF zi_bill_header IN LOCAL MODE
      ENTITY zi_bill_item BY \_header
        FIELDS ( NetAmount ) WITH CORRESPONDING #( keys )
        RESULT DATA(lt_header).

    MODIFY ENTITIES OF zi_bill_header IN LOCAL MODE
      ENTITY zi_bill_header
        EXECUTE recalculateNetAmount FROM CORRESPONDING #( lt_header ).
  ENDMETHOD.

  METHOD setCurrencyFromHeader.
    DATA: lt_update TYPE TABLE FOR UPDATE zi_bill_header\\zi_bill_item.

    READ ENTITIES OF zi_bill_header IN LOCAL MODE
     ENTITY zi_bill_item
       FIELDS ( Currency ) WITH CORRESPONDING #( keys )
       RESULT DATA(lt_item)
     ENTITY zi_bill_item BY \_header
       FIELDS ( Currency ) WITH CORRESPONDING #( keys )
       RESULT DATA(lt_header)
       LINK DATA(lt_link).

    " source = айтем, target = хедър
    LOOP AT lt_link INTO DATA(ls_link).
      DATA(lv_item_cur) = lt_item[ KEY id %tky = ls_link-source-%tky ]-Currency.
      DATA(lv_head_cur) = lt_header[ KEY id %tky = ls_link-target-%tky ]-Currency.

      CHECK lv_item_cur <> lv_head_cur.

      APPEND VALUE #( %tky     = ls_link-source-%tky
                      Currency = lv_head_cur ) TO lt_update.
    ENDLOOP.

    CHECK lt_update IS NOT INITIAL.

    MODIFY ENTITIES OF zi_bill_header IN LOCAL MODE
      ENTITY zi_bill_item
        UPDATE FIELDS ( Currency ) WITH lt_update.
  ENDMETHOD.

  METHOD recalcHeaderNetOnDelete.
    DATA lt_header TYPE TABLE FOR ACTION IMPORT zi_bill_header~recalculateNetAmount.

    " ключът на хедъра се взима директно от ключа на изтрития айтем
    LOOP AT keys INTO DATA(ls_key) WHERE billid IS NOT INITIAL.
      APPEND VALUE #( %is_draft = ls_key-%is_draft
                      billid    = ls_key-billid ) TO lt_header.
    ENDLOOP.

    SORT lt_header BY %is_draft billid.
    DELETE ADJACENT DUPLICATES FROM lt_header COMPARING %is_draft billid.

    CHECK lt_header IS NOT INITIAL.

    MODIFY ENTITIES OF zi_bill_header IN LOCAL MODE
      ENTITY zi_bill_header
        EXECUTE recalculateNetAmount FROM lt_header.
  ENDMETHOD.

ENDCLASS.

CLASS lsc_zi_bill_header DEFINITION INHERITING FROM cl_abap_behavior_saver.

  PROTECTED SECTION.

    METHODS adjust_numbers REDEFINITION.

ENDCLASS.

CLASS lsc_zi_bill_header IMPLEMENTATION.

  METHOD adjust_numbers.
    DATA: lv_bill_id     TYPE zbill_header-bill_id,
          lv_item_no     TYPE zbill_item-item_no,
          lt_header_keys TYPE TABLE FOR READ IMPORT zi_bill_header.

    LOOP AT mapped-zi_bill_header ASSIGNING FIELD-SYMBOL(<fs_mapped_header>).
      IF <fs_mapped_header>-BillId IS INITIAL.
        lv_bill_id = |{ sy-datum }{ sy-uzeit }{ sy-index }|.
        <fs_mapped_header>-BillId = lv_bill_id.
      ENDIF.
    ENDLOOP.

    READ TABLE mapped-zi_bill_item INTO DATA(ls_bill_item) INDEX 1.
    IF sy-subrc = 0.
      APPEND VALUE #( %key-BillId = ls_bill_item-%tmp-BillId ) TO lt_header_keys.

      READ ENTITIES OF zi_bill_header IN LOCAL MODE
      ENTITY zi_bill_header
        BY \_item
        ALL FIELDS
        WITH CORRESPONDING #( lt_header_keys )
      RESULT DATA(lt_items_by_header).

      SORT lt_items_by_header BY itemno DESCENDING.
      READ TABLE lt_items_by_header INTO DATA(ls_last_item) INDEX 1.
      IF sy-subrc = 0.
        lv_item_no = ls_last_item-ItemNo + 10.
      ELSE.
        lv_item_no = 10.
      ENDIF.

      LOOP AT mapped-zi_bill_item ASSIGNING FIELD-SYMBOL(<fs_mapped_item>).
        IF <fs_mapped_item>-ItemNo IS INITIAL.
          <fs_mapped_item>-BillId = <fs_mapped_item>-%tmp-BillId.
          <fs_mapped_item>-ItemNo = lv_item_no.
          lv_item_no = lv_item_no + 10.
        ENDIF.
      ENDLOOP.

    ENDIF.
  ENDMETHOD.

ENDCLASS.

CLASS lhc_ZI_BILL_HEADER DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zi_bill_header RESULT result.
    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR zi_bill_header RESULT result.
    METHODS uploadexcel FOR MODIFY
      IMPORTING keys FOR ACTION zi_bill_header~uploadexcel.
    METHODS adddiscount FOR MODIFY
      IMPORTING keys FOR ACTION zi_bill_header~adddiscount RESULT result.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR zi_bill_header RESULT result.
    METHODS validatecurrency FOR VALIDATE ON SAVE
      IMPORTING keys FOR zi_bill_header~validatecurrency.
    METHODS recalculatenetamount FOR MODIFY
      IMPORTING keys FOR ACTION zi_bill_header~recalculatenetamount.
    METHODS propagatecurrency FOR DETERMINE ON MODIFY
      IMPORTING keys FOR zi_bill_header~propagatecurrency.

*    METHODS earlynumbering_create FOR NUMBERING
*      IMPORTING entities FOR CREATE zi_bill_header.

ENDCLASS.

CLASS lhc_ZI_BILL_HEADER IMPLEMENTATION.

  METHOD get_instance_authorizations.

  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

*  METHOD earlynumbering_create.
*    DATA: lv_bill_id  TYPE zbill_header-bill_id,
*          lv_is_draft TYPE if_abap_behv=>t_xflag.
*
*    DATA(lt_entities) = entities.
*
**    DELETE lt_entities WHERE BillId IS NOT INITIAL.
*
*    LOOP AT lt_entities INTO DATA(ls_entity).
*      IF ls_entity-BillId IS INITIAL.
*        " Generate unique ID (e.g. timestamp or number range)
*        lv_bill_id = |{ sy-datum }{ sy-uzeit }{ sy-index }|.
*        lv_is_draft = if_abap_behv=>mk-on.
*
*      ELSE.
*        lv_bill_id = ls_entity-BillId.
*        lv_is_draft = if_abap_behv=>mk-off.
*      ENDIF.
*
*      APPEND VALUE #( %cid      = ls_entity-%cid
*                      BillId    = lv_bill_id
*                      %is_draft = lv_is_draft ) TO mapped-zi_bill_header.
*
*    ENDLOOP.
*  ENDMETHOD.

  METHOD uploadExcel.
    TYPES: BEGIN OF tys_row,
             doc_ref     TYPE string,
             bill_type   TYPE string,
             bill_date   TYPE string,
             customer_id TYPE string,
             sales_org   TYPE string,
             currency    TYPE string,
             material_id TYPE string,
             description TYPE string,
             quantity    TYPE string,
             uom         TYPE string,
             item_amount TYPE string,
           END OF tys_row.
    DATA lt_rows TYPE TABLE OF tys_row WITH EMPTY KEY.

    DATA(lv_file) = VALUE xstring( keys[ 1 ]-%param-FileContent OPTIONAL ).
    IF lv_file IS INITIAL.
      " съобщение в reported и RETURN
      RETURN.
    ENDIF.

    " --- четене на Excel (XCO) ---
    DATA(lo_worksheet) =
              xco_cp_xlsx=>document->for_file_content( lv_file )->read_access( )->get_workbook( )->worksheet->at_position( 1 ).

    DATA(lo_pattern) = xco_cp_xlsx_selection=>pattern_builder->simple_from_to(
                      )->from_row( xco_cp_xlsx=>coordinate->for_numeric_value( 2 ) " без заглавния ред
                      )->get_pattern( ).

    lo_worksheet->select( lo_pattern )->row_stream( )->operation->write_to( REF #( lt_rows )
      )->set_value_transformation( xco_cp_xlsx_read_access=>value_transformation->string_value
      )->if_xco_xlsx_ra_operation~execute( ).

    " --- header-и и позиции ---
    DATA lt_headers TYPE TABLE FOR CREATE zi_bill_header.
    DATA lt_items   TYPE TABLE FOR CREATE zi_bill_header\_item.
    DATA lv_n TYPE i.

    LOOP AT lt_rows INTO DATA(ls_row).
    lv_n = lv_n + 1.
      IF NOT line_exists( lt_headers[ KEY cid %cid = ls_row-doc_ref ] ).
        APPEND VALUE #( %cid       = ls_row-doc_ref
                        %is_draft = if_abap_behv=>mk-on
                        BillType   = ls_row-bill_type
                        BillDate   = ls_row-bill_date
                        CustomerId = |{ ls_row-customer_id ALPHA = IN }|
                        SalesOrg   = ls_row-sales_org
                        Currency   = ls_row-currency ) TO lt_headers.
        APPEND VALUE #( %cid_ref = ls_row-doc_ref
                        %is_draft = if_abap_behv=>mk-on ) TO lt_items ASSIGNING FIELD-SYMBOL(<fs_item>).
      ENDIF.

      APPEND VALUE #( %cid        = |{ ls_row-doc_ref }_{ lv_n }|
                      %is_draft = if_abap_behv=>mk-on
                      MaterialId  = ls_row-material_id
                      Description = ls_row-description
                      Quantity    = ls_row-quantity
                      Uom         = ls_row-uom
                      ItemAmount  = ls_row-item_amount
                      Currency    = ls_row-currency ) TO <fs_item>-%target.
    ENDLOOP.

    " --- създаване ---
    MODIFY ENTITIES OF zi_bill_header IN LOCAL MODE
      ENTITY zi_bill_header
        CREATE FIELDS ( BillType BillDate CustomerId SalesOrg Currency )
          WITH lt_headers
        CREATE BY \_item
          FIELDS ( MaterialId Description Quantity Uom ItemAmount Currency )
          WITH lt_items
      MAPPED DATA(lt_mapped)
      FAILED DATA(lt_failed)
      REPORTED DATA(lt_reported).

    mapped   = CORRESPONDING #( DEEP lt_mapped ).
    failed   = CORRESPONDING #( DEEP lt_failed ).
    reported = CORRESPONDING #( DEEP lt_reported ).
  ENDMETHOD.

  METHOD addDiscount.
    DATA: lt_discounts TYPE TABLE FOR UPDATE zi_bill_header.

    READ ENTITY IN LOCAL MODE zi_bill_header
       ALL FIELDS WITH CORRESPONDING #( keys )
       RESULT DATA(lt_result).

    DATA(lv_discount_percent) = keys[ 1 ]-%param-DiscountPercent.
    LOOP AT lt_result INTO DATA(ls_document).

      ls_document-NetAmount = ls_document-NetAmount - ( ls_document-NetAmount * lv_discount_percent / 100 ).
      APPEND CORRESPONDING #( ls_document ) TO lt_discounts.
    ENDLOOP.

    MODIFY ENTITY IN LOCAL MODE zi_bill_header
    UPDATE FIELDS ( NetAmount ) WITH lt_discounts
    FAILED DATA(lt_failed)
    REPORTED DATA(lt_reported).

    failed = lt_failed.
    reported = lt_reported.

    READ ENTITY IN LOCAL MODE zi_bill_header
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_updated).

    result = VALUE #( FOR ls_updated IN lt_updated
                      ( %tky = ls_updated-%tky
                        %param = ls_updated ) ).

  ENDMETHOD.


  METHOD get_instance_features.

    READ ENTITY IN LOCAL MODE zi_bill_header
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_result).

    LOOP AT lt_result INTO DATA(ls_result).
      APPEND VALUE #( %tky = ls_result-%tky
                      %action-adddiscount = COND #( WHEN ls_result-Currency = 'EUR' THEN if_abap_behv=>fc-o-enabled
                                                    ELSE  if_abap_behv=>fc-o-disabled ) ) TO result.
    ENDLOOP.
  ENDMETHOD.

  METHOD validateCurrency.
    READ ENTITIES OF zi_bill_header IN LOCAL MODE
    ENTITY zi_bill_header
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_header)

    ENTITY zi_bill_header BY \_item
     ALL FIELDS WITH CORRESPONDING #( keys )
     RESULT DATA(lt_item).

    LOOP AT lt_header INTO DATA(ls_header).
      APPEND VALUE #( %tky        = ls_header-%tky
                      %state_area = 'VALIDATE_CURRENCY' ) TO reported-zi_bill_header.

      LOOP AT lt_item INTO DATA(ls_item) WHERE billId = ls_header-BillId
                                           AND currency <> ls_header-currency.
        EXIT.
      ENDLOOP.
      IF sy-subrc = 0.
        APPEND VALUE #( %tky = ls_header-%tky ) TO failed-zi_bill_header.

        APPEND VALUE #( %tky = ls_header-%tky
                        %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                      text     = 'Currency differs from the currency in the items.' )
                        %state_area = 'VALIDATE_CURRENCY'
*                        %element-netAmount = if_abap_behv=>mk-on
                        %element-currency = if_abap_behv=>mk-on ) TO reported-zi_bill_header.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD recalculateNetAmount.
    READ ENTITIES OF zi_bill_header IN LOCAL MODE
    ENTITY zi_bill_header ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_header)

    ENTITY zi_bill_header BY \_item
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_item)
    LINK DATA(lt_link).

    DATA: lt_update TYPE TABLE FOR UPDATE zi_bill_header.

    LOOP AT lt_header INTO DATA(ls_header).
      DATA(lv_sum) = CONV zi_bill_header-NetAmount( 0 ).

      LOOP AT lt_link INTO DATA(ls_link) USING KEY id WHERE source-%tky = ls_header-%tky.
        lv_sum += lt_item[ KEY id %tky = ls_link-target-%tky ]-ItemAmount.
      ENDLOOP.

      APPEND VALUE #( %tky = ls_header-%tky NetAmount = lv_sum ) TO lt_update.
    ENDLOOP.

    MODIFY ENTITIES OF zi_bill_header IN LOCAL MODE
    ENTITY zi_bill_header UPDATE FIELDS ( NetAmount )
    WITH lt_update.
  ENDMETHOD.

  METHOD propagateCurrency.
    DATA: lt_upd TYPE TABLE FOR UPDATE zi_bill_header\\zi_bill_item.

    READ ENTITIES OF zi_bill_header IN LOCAL MODE
      ENTITY zi_bill_header
        FIELDS ( Currency ) WITH CORRESPONDING #( keys )
        RESULT DATA(lt_header)
      ENTITY zi_bill_header BY \_item
        FIELDS ( Currency ItemAmount ) WITH CORRESPONDING #( keys )
        RESULT DATA(lt_item)
        LINK DATA(lt_link).

    " source = хедър, target = айтем
    LOOP AT lt_link INTO DATA(ls_link).
      DATA(ls_head) = lt_header[ KEY id %tky = ls_link-source-%tky ].
      DATA(ls_item) = lt_item[ KEY id %tky = ls_link-target-%tky ].

      " вече е в правилната валута -> нищо (пази от двойно конвертиране)
      CHECK ls_item-Currency <> ls_head-Currency.

      DATA(lv_amount) = ls_item-ItemAmount.

      " конвертираме само ако има от какво и към какво
      IF ls_item-Currency IS NOT INITIAL AND ls_head-Currency IS NOT INITIAL.
        CALL FUNCTION 'CONVERT_TO_LOCAL_CURRENCY'
          EXPORTING
            date             = sy-datum          " или датата на документа
            foreign_amount   = ls_item-ItemAmount
            foreign_currency = ls_item-Currency
            local_currency   = ls_head-Currency
            type_of_rate     = 'M'
          IMPORTING
            local_amount     = lv_amount
          EXCEPTIONS
            OTHERS           = 1.

        IF sy-subrc <> 0.
          APPEND VALUE #( %tky              = ls_head-%tky
                          %element-Currency = if_abap_behv=>mk-on
                          %msg = new_message_with_text(
                                   severity = if_abap_behv_message=>severity-error
                                   text     = |No exchange rate { ls_item-Currency } -> { ls_head-Currency }| ) )
            TO reported-zi_bill_header.
          CONTINUE.   " айтемът остава в старата валута
        ENDIF.
      ENDIF.

      APPEND VALUE #( %tky       = ls_item-%tky
                      Currency   = ls_head-Currency
                      ItemAmount = lv_amount ) TO lt_upd.
    ENDLOOP.

    CHECK lt_upd IS NOT INITIAL.

    MODIFY ENTITIES OF zi_bill_header IN LOCAL MODE
      ENTITY zi_bill_item
        UPDATE FIELDS ( Currency ItemAmount ) WITH lt_upd.

  ENDMETHOD.

ENDCLASS.
