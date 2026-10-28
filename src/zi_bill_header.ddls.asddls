@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Root Entity of Billing Header table'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_BILL_HEADER
  as select from zbill_header
  composition [0..*] of zi_bill_item  as _item
  association [1..*] to ZI_BILL_DOC_TYPE as _billType on  $projection.BillType = _billType.Blart

{
  key bill_id            as BillId,
      bill_type          as BillType,
      bill_date          as BillDate,
      customer_id        as CustomerId,
      @Semantics.amount.currencyCode : 'Currency'
      net_amount         as NetAmount,
      currency           as Currency,
      sales_org          as SalesOrg,
      @Semantics.user.createdBy: true
      createdby          as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      createdat          as CreateDat,
      @Semantics.user.lastChangedBy: true
      lastchangedby      as LastChangedBy,
      //This is needed so this can be used as Total ETag field
      @Semantics.systemDateTime.lastChangedAt: true
      lastchangedat      as LastChangedAt,
      //This is needed so this can be used as ETag master field
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      locallastchangedat as LocalLastChangedAt,

      _item,
      _billType
}
