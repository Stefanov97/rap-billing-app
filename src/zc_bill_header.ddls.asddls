@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection View of Billing Document Header'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZC_BILL_HEADER
  provider contract transactional_query
  as projection on ZI_BILL_HEADER
{
  key BillId,
//      @ObjectModel.text.association: '_billType'
      @ObjectModel.text.element: [ 'BillText' ]
      @UI.textArrangement: #TEXT_ONLY
      BillType,
      BillDate,
      CustomerId,
      @Semantics.amount.currencyCode: 'Currency'
      NetAmount,
      Currency,
      SalesOrg,
      CreatedBy,
      CreateDat,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt,
      _billType.Ltext as BillText: localized,

      _item : redirected to composition child ZC_Bill_Item,
      _billType
}
