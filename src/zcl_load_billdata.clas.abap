CLASS zcl_load_billdata DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_load_billdata IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.
  DELETE FROM zdbill_item WHERE billid IS INITIAL.
*    DATA: lt_bill_header TYPE STANDARD TABLE OF zbill_header.
*    DELETE FROM zdbill_head.
*    DELETE FROM zdbill_item.
*    DELETE FROM zbill_header.
*
*    lt_bill_header = VALUE #(
*      ( client      = sy-mandt bill_id = '1000000001' bill_type = 'Y1' bill_date = '20250401' customer_id = '100001' net_amount = '1500.00' currency = 'INR' sales_org = '1000' )
*      ( client      = sy-mandt bill_id = '1000000002' bill_type = 'Y1' bill_date = '20250402' customer_id = '100002' net_amount = '2500.00' currency = 'INR' sales_org = '1000' )
*      ( client      = sy-mandt bill_id = '1000000003' bill_type = 'Y1' bill_date = '20250403' customer_id = '100003' net_amount = '1800.00' currency = 'USD' sales_org = '2000' )
*      ( client      = sy-mandt bill_id = '1000000004' bill_type = 'ZZ' bill_date = '20250404' customer_id = '100004' net_amount = '3000.00' currency = 'EUR' sales_org = '3000' )
*      ( client      = sy-mandt bill_id = '1000000005' bill_type = 'ZZ' bill_date = '20250405' customer_id = '100005' net_amount = '2200.00' currency = 'INR' sales_org = '1000' )
*    ).
*
*    INSERT zbill_header FROM TABLE @lt_bill_header.
*    out->write( 'Billing data is inserted' ).
*
*    DATA lt_bill_item TYPE STANDARD TABLE OF zbill_item.
*
*    DELETE FROM zbill_item.
*
*    lt_bill_item = VALUE #(
*      ( client = sy-mandt bill_id = '1000000001' item_no = '000001' material_id = 'MAT001' description = 'USB Cable'      quantity = '2.000' item_amount = '500.00'  currency = 'INR' uom = 'EA' )
*      ( client = sy-mandt bill_id = '1000000001' item_no = '000002' material_id = 'MAT002' description = 'Charger'        quantity = '1.000' item_amount = '1000.00' currency = 'INR' uom = 'EA' )
*
*      ( client = sy-mandt bill_id = '1000000002' item_no = '000001' material_id = 'MAT003' description = 'Headphones'     quantity = '1.000' item_amount = '2500.00' currency = 'INR' uom = 'EA' )
*
*      ( client = sy-mandt bill_id = '1000000003' item_no = '000001' material_id = 'MAT004' description = 'Keyboard'       quantity = '1.000' item_amount = '800.00'  currency = 'USD' uom = 'EA' )
*      ( client = sy-mandt bill_id = '1000000003' item_no = '000002' material_id = 'MAT005' description = 'Mouse'          quantity = '2.000' item_amount = '1000.00' currency = 'USD' uom = 'EA' )
*
*      ( client = sy-mandt bill_id = '1000000004' item_no = '000001' material_id = 'MAT006' description = 'Monitor'        quantity = '1.000' item_amount = '3000.00' currency = 'EUR' uom = 'EA' )
*
*      ( client = sy-mandt bill_id = '1000000005' item_no = '000001' material_id = 'MAT007' description = 'Webcam'         quantity = '1.000' item_amount = '2200.00' currency = 'INR' uom = 'EA' )
*    ).
*
*    INSERT zbill_item FROM TABLE @lt_bill_item.
*    out->write( 'Billing item data is inserted' ).
  ENDMETHOD.
ENDCLASS.
