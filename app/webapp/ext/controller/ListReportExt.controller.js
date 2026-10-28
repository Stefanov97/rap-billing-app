sap.ui.define([
  "sap/m/Dialog", "sap/m/Button", "sap/ui/unified/FileUploader",
  "sap/m/MessageToast", "sap/m/MessageBox"
], function (Dialog, Button, FileUploader, MessageToast, MessageBox) {
  "use strict";

 function readAsHex(oFile) {
  return new Promise((resolve, reject) => {
    const r = new FileReader();
    r.onload = () => resolve(
      Array.from(new Uint8Array(r.result), b => b.toString(16).padStart(2, "0"))
        .join("").toUpperCase()
    );
    r.onerror = reject;
    r.readAsArrayBuffer(oFile);
  });
}

  return {
    onExcelUpload: function () {
      const oModel = this.getView().getModel();
      const oExtAPI = this.extensionAPI;
      let oFile;

      const oDialog = new Dialog({
        title: "Upload from Excel",
        content: [new FileUploader({
          width: "100%",
          fileType: ["xlsx"],
          change: e => { oFile = e.getParameter("files")[0]; }
        })],
        beginButton: new Button({
          text: "Upload", type: "Emphasized",
          press: async () => {
            if (!oFile) { MessageToast.show("Избери файл"); return; }
            oDialog.setBusy(true);
            const sBase64 = await readAsHex(oFile);
            oModel.callFunction("/uploadExcel", {   // <-- името на function import-а
              method: "POST",
              urlParameters: {
                FileContent: sBase64,
                MimeType: oFile.type,
                FileName: oFile.name
              },
              success: () => {
                oDialog.setBusy(false);
                MessageToast.show("Документите са създадени");
                oDialog.close();
                oExtAPI.refreshTable();
              },
              error: oErr => {
                oDialog.setBusy(false);
                let sMsg = oErr.message;
                try { sMsg = JSON.parse(oErr.responseText).error.message.value; } catch (e) {}
                MessageBox.error(sMsg);
              }
            });
          }
        }),
        endButton: new Button({ text: "Cancel", press: () => oDialog.close() }),
        afterClose: () => oDialog.destroy()
      });
      oDialog.open();
    }
  };
});