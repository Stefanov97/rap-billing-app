@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Billing document types'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_BILL_DOC_TYPE
  as select from t003t
{
  @Semantics.language: true
  key spras as Spras,
  key blart as Blart,
  @Semantics.text: true
  ltext as Ltext
}
