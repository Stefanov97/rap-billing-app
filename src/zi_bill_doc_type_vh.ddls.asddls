@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Value help for Billing Doc Type'
@Metadata.ignorePropagatedAnnotations: true
@Search.searchable: true
define view entity ZI_BILL_DOC_TYPE_VH
  as select from t003
  association [1] to ZI_BILL_DOC_TYPE as _billTypeText on  $projection.BillType = _billTypeText.Blart
                                                       and _billTypeText.Spras  = $session.system_language

{
      @Search.defaultSearchElement: true
  key blart               as BillType,
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.7
      _billTypeText.Ltext as BillTypeText

}
