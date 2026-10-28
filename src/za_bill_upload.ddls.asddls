@EndUserText.label: 'Billing Excel upload'
define abstract entity ZA_BILL_UPLOAD
{
  @Semantics.largeObject: { mimeType: 'MimeType',
                            fileName: 'FileName',
                            acceptableMimeTypes: [ 'application/vnd.ms excel',
                            'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'],
                            contentDispositionPreference: #ATTACHMENT }
  FileContent : abap.rawstring(0);
  @Semantics.mimeType: true
  MimeType    : abap.char(128);
  FileName    : abap.char(128);
}
