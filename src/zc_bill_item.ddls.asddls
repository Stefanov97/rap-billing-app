@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection View of Billing Doc Item'
@Metadata.allowExtensions: true
define view entity ZC_Bill_Item
  as projection on zi_bill_item
{
  key BillId,
  key ItemNo,
      MaterialId,
      Description,
      Quantity,
      ItemAmount,
      Currency,
      Uom,
      @Semantics.user.createdBy: true
      CreatedBy          as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      CreateDat          as CreateDat,
      @Semantics.user.lastChangedBy: true
      LastChangedBy      as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      LastChangedAt      as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      LocalLastChangedAt as LocalLastChangedAt,

      /* Associations */
      _header : redirected to parent ZC_BILL_HEADER
}
