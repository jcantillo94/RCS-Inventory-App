//
//  ViewController.swift
//  RCSInventory
//
//  Created by Jose Cantillo on 11/23/21.
//

import UIKit
import AVFoundation
import SwiftyDropbox
import RealmSwift

class ViewController: UIViewController, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 3
    }
    
    
    //Dropbox Access Token sl.A-QWpTUKf2WPOgFcTOab3YH1aQhiVhuDdcdkvPIho0dMRGnhq_zXlCRxc0S_1Jb-xRDNAjTbE9af7sfPIXlKlhQ7cqB05lNe0I50UCBY7dOlvUIa_phhRBiPYquwA2x3UM_LKMA
    
    let realm = try! Realm()
    
    var scannedItem = Product()
    
    @IBOutlet weak var changingBoxCount: UILabel!
    
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    @IBOutlet weak var barcodeTextField: UITextField!
    
    @IBOutlet weak var boxCountTextField: UITextField! {
        didSet { boxCountTextField?.addDoneCancelToolbar() }
    }
    
    @IBOutlet weak var finalCount: UITextView!
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
        barcodeTextField.becomeFirstResponder()
    }
    
    @IBAction func boxCountChanged(_ sender: UITextField) {
        
        let box = (boxCountTextField.text! as NSString) .integerValue
        
        var quantity : Int = 0
        
        if let scannedItem = barcodeTextField.text {
        if (barcodeTextField.text != "") && (realm.objects(Product.self).filter("barcode == %@", scannedItem).isEmpty == false) {
        print("boxCountChanged")
        
        
        
            quantity = realm.objects(Product.self).filter("barcode == %@", scannedItem)[0].qtymaster
        }
        
        
        print("\(box), \(quantity)")
        let total = box * quantity
        print(total)
        
        finalCount.text = String(total)
        } else {
            boxCountTextField.text = ""
            barcodeTextField .becomeFirstResponder()
            let ac = UIAlertController(title: "No barcode scanned", message: "Please scan item before entering box count.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
        
    }
    @IBOutlet weak var looseItemCount: UITextField! {
        didSet { looseItemCount?.addDoneCancelToolbar() }
    }
    
    @IBAction func looseItemCountChanged(_ sender: UITextField)
    {
        
        if let scannedItem = barcodeTextField.text {
            
        let box = (boxCountTextField.text! as NSString) .integerValue
        
        var quantity : Int = 0
        
        let looseItems = (looseItemCount.text! as NSString) .integerValue
        
        if barcodeTextField.text != "" && (realm.objects(Product.self).filter("barcode == %@", scannedItem).isEmpty == false) {
            
        
        
        
        
            quantity = realm.objects(Product.self).filter("barcode CONTAINS[cd] %@", scannedItem)[0].qtymaster
        }
        
        print("\(box), \(quantity)")
        let total = (box * quantity) + looseItems
        
        finalCount.text = String(total)
        } else {
            looseItemCount.text = ""
            barcodeTextField .becomeFirstResponder()
            let ac = UIAlertController(title: "No barcode scanned", message: "Please scan item before entering broken box count.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    @IBOutlet weak var totalQtyPerBox: UILabel!
    
    @IBOutlet weak var descField: UITextView!
    
//    var barcodeArray: [(String, String, String, String, String, String)] = []
    
    var barcodeArray: [ProductDataEntry] = []
    
    var items2: [(String, String, String, String, String, String, String)] = [("Barcode", "Product Number", "Desc", "QTY", "Box Count", "Loose Count", "Total Count")]
    
//    var items2: [(String, String, String)] = [("Item", "Total Count", "Desc")]
    
    var items: [(String, String, String, String, Int)]?
    
    var added = false
    
    let defaults = UserDefaults.standard
    
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
//    // Reference after programmatic auth flow
//    let client = DropboxClientsManager.authorizedClient

    // Initialize with manually retrieved auth token
    let client = DropboxClient(accessToken: "DGCscqKUVxwAAAAAAAAAAVL0aRpL_aI0iCi-uCdi3UPXBw3hIBtmAfPfnDGosRmB")
    
    //"P7XYGdDZwx0AAAAAAAAAAYZ1HZTnZkZW_Ass24gXyJfzF5WPyBQTsM9fd-pVmwCg"
    
    
    @IBAction func downloadInvButtonPressed2(_ sender: UIButton) {
        
        var lastLogFile = ""
        
        let realm = try! Realm()
        try! realm.write {
          realm.deleteAll()
        }
        
//        var lines : [String]
//
//        let fileURL = try! FileManager.default.url(for: .desktopDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
//
//        let inputFile = fileURL.appendingPathComponent("JOSE FLAT FILE").appendingPathExtension(".csv")
//
//        do {
//            let savedData = try String(contentsOf: inputFile)
//            lines = savedData.components(separatedBy: NSCharacterSet.newlines) as [String]
//
//            for line in 1...lines.count - 1 {
//                var values: [String] = []
//                if lines[line] != "" {
//                    if lines[line].range(of: "\"") != nil {
//                        var textToScan:String = lines[line]
//                        var value:NSString?
//                        var textScanner:Scanner = Scanner(string: textToScan)
//                        while textScanner.string != "" {
//                            if (textScanner.string as NSString).substring(to: 1) == "\"" {
//                                textScanner.scanLocation += 1
//                                textScanner.scanUpTo("\"", into: &value)
//                                textScanner.scanLocation += 1
//                            } else {
//                                textScanner.scanUpTo(",", into: &value)
//                            }
//
//                             values.append(value! as String)
//
//                             if textScanner.scanLocation < textScanner.string.count {
//                                 textToScan = (textScanner.string as NSString).substring(from: textScanner.scanLocation + 1)
//                             } else {
//                                 textToScan = ""
//                             }
//                             textScanner = Scanner(string: textToScan)
//                        }
//
//                        // For a line without double quotes, we can simply separate the string
//                        // by using the delimiter (e.g. comma)
//                    } else  {
//                        values = lines[line].components(separatedBy: ",")
//                    }
//
//                    // Put the values into the tuple and add it to the items array
//                    let item = (values[0], values[1], values[2])
//
//                    self.items.append(item)
//
//                 }
//             }
//        } catch {
//            print(["Error "])
//        }
        
        
//        let filepath = "./JOSE FLAT FILE.xlsx"
//        guard let file = XLSXFile(filepath: filepath) else {
//          fatalError("XLSX file at \(filepath) is corrupted or does not exist")
//        }
//
//        for wbk in try file.parseWorkbooks() {
//          for (name, path) in try file.parseWorksheetPathsAndNames(workbook: wbk) {
//            if let worksheetName = name {
//              print("This worksheet has a name: \(worksheetName)")
//            }
//
//            let worksheet = try file.parseWorksheet(at: path)
//            for row in worksheet.data?.rows ?? [] {
//              for c in row.cells {
//                print(c)
//              }
//            }
//          }
//        }
        
        if self.added == false {

            client.files.listFolder(path: "/Inventory Log").response { response, error in
                print("*** List folder ***")
                if let result = response {
                    print(result.entries[result.entries.count - 1].name)
                    lastLogFile = result.entries[result.entries.count - 1].name

                    print("/Inventory Log/\(lastLogFile)")

                    // Download to Data
//                    self.client.files.download(path: "/Inventory Log/\(lastLogFile)")
                   self.client.files.download(path: "/Inventory Log/JOSE FLAT FILE.csv")
                        .response { response, error in
                            if let response = response {
                                let responseMetadata = response.0
                                print(responseMetadata)
                                let fileContents = response.1
                                print("Showing: ")
                                print(fileContents)
                                let dataString: String! = String.init(data: fileContents, encoding: .utf8)
                                let lines: [String] = dataString.components(separatedBy: NSCharacterSet.newlines) as [String]

                                for line in 1...lines.count - 1 {
                                    var values: [String] = []
                                    if lines[line] != "" {
                                        if lines[line].range(of: "\"") != nil {
                                            var textToScan:String = lines[line]
                                            var value:NSString?
                                            var textScanner:Scanner = Scanner(string: textToScan)
                                            while textScanner.string != "" {
                                                if (textScanner.string as NSString).substring(to: 1) == "\"" {
                                                    textScanner.scanLocation += 1
//                                                    textScanner.scanUpTo("\"", into: &value)
                                                    textScanner.scanUpTo(",", into: &value)
                                                    textScanner.scanLocation += 1
                                                } else {
                                                    textScanner.scanUpTo(",", into: &value)
                                                }

                                                 values.append(value! as String)

                                                 if textScanner.scanLocation < textScanner.string.count {
                                                     textToScan = (textScanner.string as NSString).substring(from: textScanner.scanLocation + 1)
                                                 } else {
                                                     textToScan = ""
                                                 }
                                                 textScanner = Scanner(string: textToScan)
                                            }

                                            // For a line without double quotes, we can simply separate the string
                                            // by using the delimiter (e.g. comma)
                                        } else  {
                                            values = lines[line].components(separatedBy: ",")
                                        }

                                        // Put the values into the tuple and add it to the items array
                                        let item = (values[0], values[1], values[3], values[4], values[7])
                                        
                                        let product = Product()
                                        product.barcode = values[0]
                                        product.prodno = values[1]
                                        product.name = values[3]
                                        product.lngdesc = values[4]
                                        product.qtymaster = Int(values[7]) ?? 0

//                                        self.items2.append(item)
                                        
                                        self.saveProductsList(products: product)

//                                        print(item.0)
//                                        print(item.1)
//                                        print(item.2)
                                     }
                                 }
                                self.added = true

                            } else if let error = error {
                                print(error)
                            }
                        }
                        .progress { progressData in
                            print(progressData)
                        }


//                    print("Folder contents:")
//                    for entry in result.entries {
//                        print(entry.name)
//                    }

                }  else if let error = error {
                    print(error)
                }
            }

//            print("/Inventory Log/\(lastLogFile)")

        } else {
            print("previous inventory log already downloaded")
        }
    }
    
    
    
    
    @IBAction func downloadInvButtonPressed(_ sender: UIButton) {
        
        let scopeRequest = ScopeRequest(scopeType: .user, scopes: ["files.content.read",  "files.content.write"], includeGrantedScopes: false)
        DropboxClientsManager.authorizeFromControllerV2(
            UIApplication.shared,
            controller: self,
            loadingStatusDelegate: nil,
            openURL: { (url: URL) -> Void in UIApplication.shared.open(url) },
            scopeRequest: scopeRequest
        )
                
        // Download to Data
//        client?.files.download(path: "https://www.dropbox.com/s/uyc3xqj8cn26hwr/StoredInv.csv?dl=0")
//            .response { response, error in
//                if let response = response {
//                    let responseMetadata = response.0
//                    print(responseMetadata)
//                    let fileContents = response.1
//                    print(fileContents)
//                } else if let error = error {
//                    print(error)
//                }
//            }
//            .progress { progressData in
//                print(progressData)
//            }
    }
    
    
    func myButtonInControllerPressed() {
        // OAuth 2 code flow with PKCE that grants a short-lived token with scopes, and performs refreshes of the token automatically.
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            self.view.endEditing(true)
            return false
        }
    
    @IBAction func barcodeTextChanged(_ sender: UITextField) {
        
        if barcodeTextField.text != "" {
        if let scannedItem = barcodeTextField.text {
            
            if realm.objects(Product.self).filter("barcode == %@", scannedItem).isEmpty == false {
            descField.text = realm.objects(Product.self).filter("barcode == %@", scannedItem)[0].lngdesc
            
//            itemNumberTextField.text = realm.objects(Product.self).filter("barcode == %@", scannedItem)[0].prodno
            
            changingBoxCount.text = "x " + String(realm.objects(Product.self).filter("barcode == %@", scannedItem)[0].qtymaster)
            
            totalQtyPerBox.text = "/ " + String(realm.objects(Product.self).filter("barcode == %@", scannedItem)[0].qtymaster)
            } else {
                print(realm.objects(Product.self).filter("barcode == %@", scannedItem).isEmpty)
            }
        }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        barcodeTextField.delegate = self
        boxCountTextField.delegate = self
        looseItemCount.delegate = self
        
        boxCountTextField.keyboardType = .numberPad
        looseItemCount.keyboardType = .numberPad
//        barcodeTextField.addTarget(self, action: #selector(ViewController.textField(_:)), for: .editingChanged)
        
        defaults.removeObject(forKey: "RCSInventoryArray")
        
        overrideUserInterfaceStyle = .dark
        
        if defaults.object(forKey: "RCSInventoryArray") != nil {
            print("not new")
        } else {
            let productDataArray = try! JSONEncoder().encode(self.barcodeArray)
            defaults.set(productDataArray, forKey: "RCSInventoryArray")
            print("barcode array \(self.barcodeArray)")
            if let array = defaults.data(forKey: "RCSInventoryArray") {
            let strings = try! JSONDecoder().decode([ProductDataEntry].self, from: array)
            print("defaults \(strings)")
            }
            print("new")
        }
        print(defaults.array(forKey: "RCSInventoryArray") as? [String] ?? [] )

        
        //        view.backgroundColor = UIColor.black
    }
    @IBOutlet weak var itemNumberTextField: UITextField!
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print("oof")
        
//        print(barcodeTextField!)
//        if barcodeTextField.text != "" {
//        if let scannedItem = barcodeTextField.text {
//            descField.text = realm.objects(Product.self).filter("barcode CONTAINS[cd] %@", scannedItem)[0].lngdesc
//
//            itemNumberTextField.text = realm.objects(Product.self).filter("barcode CONTAINS[cd] %@", scannedItem)[0].prodno
//        }
//        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        print("lol")
        
        print(barcodeTextField!)
        if barcodeTextField.text != "" {
        if let scannedItem = barcodeTextField.text {
            
            if realm.objects(Product.self).filter("barcode == [cd]%@", scannedItem).isEmpty == false {
                
            descField.text = realm.objects(Product.self).filter("barcode == [cd]%@", scannedItem)[0].lngdesc
            
//            itemNumberTextField.text = realm.objects(Product.self).filter("barcode == [cd]%@", scannedItem)[0].prodno
                
                if boxCountTextField.text != "" && looseItemCount.text != "" {
                
                let box = (boxCountTextField.text! as NSString) .integerValue
                
                var quantity : Int = 0
                
                let looseItems = (looseItemCount.text! as NSString) .integerValue
                
                quantity = realm.objects(Product.self).filter("barcode == [cd] %@", scannedItem)[0].qtymaster
            
            
            print("\(box), \(quantity)")
            let total = (box * quantity) + looseItems
            
            finalCount.text = String(total)
                }
            
            } else {
                print(realm.objects(Product.self).filter("barcode == [cd]%@", scannedItem).isEmpty)
                
                let ac = UIAlertController(title: "Barcode not found", message: "Barcode does not exist. Please try again.", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default))
                present(ac, animated: true)
            }
        }
        } else {
            descField.text = ""
//            itemNumberTextField.text = ""
            changingBoxCount.text = "x ?"
            totalQtyPerBox.text = "/ ?"
            
        }
    }
    
    
    func failed() {
        let ac = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
        captureSession = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("willappear")
        print(defaults.array(forKey: "RCSInventoryArray") ?? "empty")
        
//        let alertView = UIAlertController(title: "", message: "", preferredStyle: UIAlertController.Style.alert)
//
//        let pickerView = UIPickerView(frame: CGRect(x: 0, y: 0, width: 350, height: 180))
//        pickerView.dataSource = self
//        pickerView.delegate = self
//
//        alertView.view.addSubview(pickerView)
//
//        let action = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
//
//        alertView.addAction(action)
//        
//        DispatchQueue.main.async {
//            self.present(alertView, animated: true, completion: nil)
//        }
        
        
        barcodeTextField.becomeFirstResponder()
        
        
//        barcodeTextField.inputView = UIView.init(frame: CGRect())
        
        
        //        if (captureSession?.isRunning == false) {
        //            captureSession.startRunning()
        //        }
    }
    
//    @IBAction func barCodeTextDidChange(_ sender: UITextField) {
//        barcodeTextField.text = "yo"
//    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        print("didDisappear")
        if (captureSession?.isRunning == true) {
            captureSession.stopRunning()
            print("stopped")
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    @IBAction func cameraPressed(_ sender: UIButton) {
        
        print("cam pressed")
        
        captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
            print("do try")
        } catch {
            return
        }
        
        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
            print("can")
        } else {
            failed()
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            //            metadataOutput.metadataObjectTypes = [.ean8, .ean13, .pdf417]
            metadataOutput.metadataObjectTypes = [.qr, .ean8, .ean13, .pdf417, .upce, .code128, .code39, .code39Mod43, .code93, .interleaved2of5, .itf14, .upce]
            print("captured")
        } else {
            failed()
            print("failed")
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        
        
        
        print("running")
        captureSession.startRunning()
    }
    
    @IBAction func reviewInvButtonPressed(_ sender: UIButton) {
        self.performSegue(withIdentifier: "goToReviewInv", sender: self)

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ReviewViewController
        
//        if let defaultsArray = defaults.object(forKey: "RCSInventoryApp") as? [(String, String, String, String, String, String)] {
//            barcodeArray.append(contentsOf: defaultsArray)
//            barcodeArray[""]
//        }
        
        if let defaultsArray = defaults.object(forKey: "RCSInventoryApp") as? [ProductDataEntry] {
            barcodeArray.append(contentsOf: defaultsArray)
        }
        
        destinationVC.barcodes = barcodeArray
        destinationVC.previousInvLog = items2
//        barcodeArray = [:]
    }
    
    @IBAction func saveItemButtonPressed(_ sender: UIButton) {
        
//        var oldArray = defaults.object(forKey: "RCSInventoryArray") as? [(String, String, String, String, String, String)]
        
//        var oldArray = defaults.object(forKey: "RCSInventoryArray") as? [ProductDataEntry]
        
        if let scannedItem = barcodeTextField.text {
            
            if realm.objects(Product.self).filter("barcode == %@", scannedItem).isEmpty == false {
        
        var oldArray : [ProductDataEntry] = []
        
        if let defaultsData = defaults.data(forKey: "RCSInventoryArray") {
            oldArray = try! JSONDecoder().decode([ProductDataEntry].self, from: defaultsData)
        } else {
            print("wtf")
        }
        
        
        if barcodeTextField.text != "" && boxCountTextField.text != "" && looseItemCount.text != "" {
        if let barcode = barcodeTextField.text {
            
            if barcodeTextField.text != "" && boxCountTextField.text != "" && looseItemCount.text != "" {
                print("something is empty")
            }
            
//            oldArray?.append(contentsOf: barcodeArray)
            
//            let item = (barcode, itemNumberTextField.text, descField.text, boxCountTextField.text, looseItemCount.text, finalCount.text)
            
            
//            oldArray?.append((barcode, itemNumberTextField.text!, descField.text!, boxCountTextField.text!, looseItemCount.text!, finalCount.text!))
            
            oldArray.append(ProductDataEntry(barcode: barcode, prodNo: "00", lngDesc: descField.text!, boxCount: boxCountTextField.text!, looseCount: looseItemCount.text!, finalCount: finalCount.text!))
                
            
            print(barcode, "00", descField.text!, boxCountTextField.text!, looseItemCount.text!, finalCount.text!)
            print(oldArray ?? "no oldArray")
//            oldArray?.append(("dog", "dog", "dog", "dog", "dog", "dog"))
            
            
            
//            defaults.removeObject(forKey: "RCSInventory")
            
            let productDataArray = try! JSONEncoder().encode(oldArray)
            defaults.set(productDataArray, forKey: "RCSInventoryArray")
            
            
            print("saved")
            
            let strings = defaults.data(forKey: "RCSInventoryArray")
            
            let strings2 = try! JSONDecoder().decode([ProductDataEntry].self, from: strings!)
            
            print(strings2[0].barcode)
            
            
            print("test: ", strings ?? [])
            
            barcodeTextField.text = ""
//            itemNumberTextField.text = ""
            descField.text = ""
            boxCountTextField.text = ""
            looseItemCount.text = ""
            finalCount.text = ""
            changingBoxCount.text = "x ?"
            totalQtyPerBox.text = "/ ?"
            barcodeTextField .becomeFirstResponder()
            
            
//            print(oldArray)
            
        } else {
            print("no barcode scanned or typed")
        }
        } else {
            let ac = UIAlertController(title: "Check missing field(s)", message: "A field is missing. Complete all fields to save current product.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
        
        print("\(oldArray) old array" ?? "no old array...")
                print(defaults.object(forKey: "RCSInventoryArray") as? [ProductDataEntry] ?? "no defaults for RCS")
                
            } else {
                let ac = UIAlertController(title: "Barcode not Valid", message: "Please enter or scan a valid RCS item barcode", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default))
                present(ac, animated: true)
            }
            
        }
        
    }
    
}

//    extension ViewController: UITableViewDataSource {
//        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//            return messages.count
//        }
//
//        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//
//            let message = messages[indexPath.row]
//
//            let cell = tableView.dequeueReusableCell(withIdentifier: K.cellIdentifier, for: indexPath) as! MessageCell
//            cell.label.text = message.body
//
//
//            // This ia a message from the current user.
//            if message.sender == Auth.auth().currentUser?.email {
//                cell.leftImageView.isHidden = true
//                cell.rightImageView.isHidden = false
//                cell.messageBubble.backgroundColor = UIColor(named: K.BrandColors.lightPurple)
//                cell.label.textColor = UIColor(named:K.BrandColors.purple)
//            }
//            // This is a message from another sender.
//            else {
//                cell.leftImageView.isHidden = false
//                cell.rightImageView.isHidden = true
//                cell.messageBubble.backgroundColor = UIColor(named: K.BrandColors.purple)
//                cell.label.textColor = UIColor(named:K.BrandColors.lightPurple)
//            }
//
//
//            return cell
//        }
//    }

extension ViewController: AVCaptureMetadataOutputObjectsDelegate {
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        print("yo")
        captureSession.stopRunning()
        
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            print("yo2")
            guard let stringValue = readableObject.stringValue else { return }
            print("yo3")
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            found(code: stringValue)
        }
        
        dismiss(animated: true) {
            print("hi")
        }
        
        print("dismissed")
        previewLayer.removeFromSuperlayer()
        //        view.layer.removeFromSuperlayer()
    }
    
    func found(code: String) {
        print(code)
        barcodeTextField.text = code
    }
}

extension ViewController {
    
    func saveProductsList(products: Product) {
        do {
            try realm.write {
            realm.add(products)
            }
            } catch {
            print("Error saving products \(error)")
        }
    }
}

extension UITextField {
    func addDoneCancelToolbar(onDone: (target: Any, action: Selector)? = nil, onCancel: (target: Any, action: Selector)? = nil) {
        let onCancel = onCancel ?? (target: self, action: #selector(cancelButtonTapped))
        let onDone = onDone ?? (target: self, action: #selector(doneButtonTapped))

        let toolbar: UIToolbar = UIToolbar()
        toolbar.barStyle = .default
        toolbar.items = [
            UIBarButtonItem(title: "Cancel", style: .plain, target: onCancel.target, action: onCancel.action),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil),
            UIBarButtonItem(title: "Done", style: .done, target: onDone.target, action: onDone.action)
        ]
        toolbar.sizeToFit()

        self.inputAccessoryView = toolbar
    }

    // Default actions:
    @objc func doneButtonTapped() { self.resignFirstResponder() }
    @objc func cancelButtonTapped() { self.resignFirstResponder() }
}

