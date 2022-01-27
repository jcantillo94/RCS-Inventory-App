//
//  ReviewViewController.swift
//  RCSInventory
//
//  Created by Jose Cantillo on 11/27/21.
//

import Foundation
import UIKit
import SwiftyDropbox
import RealmSwift


class ReviewViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    let realm = try! Realm()
    
//    var barcodes : [(String, String, String, String, String, String)] = []
    
    var barcodes : [ProductDataEntry] = []
    
    var previousInvLog : [(String, String, String, String, String, String, String)] = []
    
    let client = DropboxClientsManager.authorizedClient
    
    let defaults = UserDefaults.standard
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        let pointInTable = textField.convert(textField.bounds.origin, to: self.tableView)
        let textFieldIndexPath = self.tableView.indexPathForRow(at: pointInTable)
        
        print(textFieldIndexPath!)
        print(textFieldIndexPath?[1] ?? "error index path")
        print(textField)
        
//        let cell = tableView.dequeueReusableCell(withIdentifier: "InvCell", for: textFieldIndexPath!) as! TableViewController
        let cell = tableView.cellForRow(at: textFieldIndexPath!) as! TableViewController
        
        print(cell.amountField)
        print(cell.looseCountField)
        

        
        print("tags \(textField.tag), \(cell.amountField.tag)")
        if (textField.tag == cell.amountField!.tag) {
            print("amount field")
            print("textfield \(textField)")
            print("textfield \(cell.amountField!)")
        } else {
            print("loose field")
            print("loose field \(textField)")
            print("textfield \(cell.amountField!)")
        }
        
        let array = defaults.data(forKey: "RCSInventoryArray")

        let strings = try! JSONDecoder().decode([ProductDataEntry].self, from: array!)
        
        

        if textField.tag == 0 {
            print(textField.tag)
            if let otherTextFieldText = cell.looseCountField.text {
            
            let amount1 = Int(otherTextFieldText)
    
        if let textFieldText = textField.text {
            let amount2 = Int(textFieldText)
            strings[textFieldIndexPath![1]].boxCount = textFieldText
            strings[textFieldIndexPath![1]].finalCount = String(amount1! + (amount2! * realm.objects(Product.self).filter("barcode CONTAINS[cd] %@", cell.label.text ?? "")[0].qtymaster))
            
        }
        }
        } else {
            print(textField.tag)
            
            if let otherTextFieldText = cell.amountField.text {
            
            let amount1 = Int(otherTextFieldText)
    
        if let textFieldText = textField.text {
            let amount2 = Int(textFieldText)
            strings[textFieldIndexPath![1]].looseCount = textFieldText
            strings[textFieldIndexPath![1]].finalCount = String((amount1! * realm.objects(Product.self).filter("barcode CONTAINS[cd] %@", cell.label.text ?? "")[0].qtymaster) + (amount2!))
        }
        }
            
        }
        
        let productDataArray = try! JSONEncoder().encode(strings)
        defaults.set(productDataArray, forKey: "RCSInventoryArray")
        
        
        
        
        if let cell = textField.superview as? TableViewController {
                    let indexpath = tableView.indexPath(for: cell)
            print(indexpath)
                    // indexpath.row -  row index, indexpath.section - section index
        } else {
            print("hi")
        }
        
        print("inViewController")
            self.view.endEditing(true)
            self.tableView.reloadData()
            return false
        
        
        
        }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //        return barcodes.count
        
        
        let array = defaults.data(forKey: "RCSInventoryArray")
        
        let strings = try! JSONDecoder().decode([ProductDataEntry].self, from: array!)
        
//        print(strings[0].barcode)
        
        
        if let arrayCount = defaults.data(forKey: "RCSInventoryArray") {
            return strings.count
        } else {
            print("defaults array return nil")
        }
        return 0
        
        
//        if let arrayCount = defaults.array(forKey: "RCSInventoryArray")?.count {
//            return arrayCount
//        } else {
//            print("defaults array return nil")
//        }
//        return 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath)
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
//        if let barcodeEntry = defaults.array(forKey: "RCSInventoryArray")?[indexPath.row] {
//
////            defaults.array(forKey: "RCSInventoryArray")?[indexPath.row]
//
//            let cell = tableView.dequeueReusableCell(withIdentifier: "InvCell", for: indexPath) as! TableViewController
//
//            cell.amountField.text = "50"
//            cell.desc.text = "Test"
//            cell.desc.isEditable = false
//            cell.label.text = barcodeEntry as? String
//
//            return cell
//        }
        
        
        let array = defaults.data(forKey: "RCSInventoryArray")
        
        let strings = try! JSONDecoder().decode([ProductDataEntry].self, from: array!)
        
        
        if let barcodeEntry = array {
        
        //            defaults.array(forKey: "RCSInventoryArray")?[indexPath.row]
            
            
        
                    let cell = tableView.dequeueReusableCell(withIdentifier: "InvCell", for: indexPath) as! TableViewController
            
            cell.amountField.delegate = self
            cell.looseCountField.delegate = self
            
            cell.amountField.keyboardType = .numberPad
            cell.looseCountField.keyboardType = .numberPad
            
        
                    cell.amountField.text = strings[indexPath.row].boxCount
                    cell.looseCountField.text = strings[indexPath.row].looseCount
                    cell.totalCount.text = String(strings[indexPath.row].finalCount)
                    cell.desc.text = strings[indexPath.row].lngdesc
                    cell.desc.isEditable = false
                    cell.label.text = strings[indexPath.row].barcode
        
                    return cell
                }
        
        return tableView.dequeueReusableCell(withIdentifier: "InvCell", for: indexPath) as! TableViewController
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        print(indexPath)
        
        if editingStyle == UITableViewCell.EditingStyle.delete {
            //            numbers.remove(at: indexPath.row)
            
            let array = defaults.data(forKey: "RCSInventoryArray")
            
            var strings = try! JSONDecoder().decode([ProductDataEntry].self, from: array!)
            
            print(strings[0].barcode)
            
            strings.remove(at: indexPath.row)
            
            
//            barcodes.remove(at: indexPath.row)
//            defaults.removeObject(forKey: "RCSInventoryArray")
//            defaults.set(barcodes, forKey: "RCSInventoryArray")
            
            let productDataArray = try! JSONEncoder().encode(strings)
            defaults.set(productDataArray, forKey: "RCSInventoryArray")

            tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
            
        }
    }
    
    
    
    
    override func viewDidLoad() {
        
        
        
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        tableView.register(
            UINib(nibName: "TableViewController", bundle: nil),
            forCellReuseIdentifier: "InvCell"
        )
        tableView.dataSource = self
        
        
        
        print("Prev Log ", previousInvLog)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("Barcodes ", barcodes)
        
        if let products = defaults.array(forKey: "RCSInventoryArray") as? [ProductDataEntry] {
            barcodes = products
        }
        
        
    }
    
    
    
    @IBAction func submitInventoryButtonPressed(_ sender: UIButton) {
        
        let test1 = self.defaults.data(forKey: "RCSInventoryArray")
        
        let test2 = try! JSONDecoder().decode([ProductDataEntry].self, from: test1!)
        
        if test2.isEmpty == true {
            let ac = UIAlertController(title: "Empty Inventory List", message: "Scanned Item list above is empty. Return to previous screen and scan items", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {
        
        let alert = UIAlertController(title: "Confirm", message: "Are you sure that you are ready to send this updated inventory to Dropbox?", preferredStyle: UIAlertController.Style.alert)

                // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "Continue", style: UIAlertAction.Style.default, handler: { [self]action in
                    
                    
                    let array = self.defaults.data(forKey: "RCSInventoryArray")
                    
                    let strings = try! JSONDecoder().decode([ProductDataEntry].self, from: array!)
            
                    print(strings)
                    
//                    if let products = self.defaults.array(forKey: "RCSInventoryArray") as? [String] {
                        
                    if let products = self.defaults.data(forKey: "RCSInventoryArray") {
                        
                        print(products)

                        for product in strings {
                            
                            let qty = String(realm.objects(Product.self).filter("barcode CONTAINS[cd] %@", product.barcode)[0].qtymaster)

                            self.previousInvLog.append((product.barcode, product.prodno, product.lngdesc, qty, product.boxCount, product.looseCount, product.finalCount))
                        }
                    }
                    
//                    if let products = self.defaults.array(forKey: "RCSInventoryArray") as? [String] {
//
//                        for product in products {
//
//                            self.previousInvLog.append((product, "0", "N/A"))
//                        }
//                    }
                    
            //        let name = previousInvLog[0].0
                    
                    let fileName = "UpdatedInv.csv \(Date.init())"
                    let path = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)
                    var csvString = ""
                    
                    for item in self.previousInvLog {
                        
                        
                        csvString.append(item.0 + "," + item.1 + "," + item.2 +  "," + item.3 + "," + item.4 + "," + item.5 + "," + item.6 + "\n")
                    }
                    
                    print(csvString)
                    
                    do {
                        try csvString.write(to: path!, atomically: true, encoding: String.Encoding.utf8)
                    } catch {
                        print("Failed to create file")
                        print("\(error)")
                    }
                    print(path ?? "not found")
                    
                    let dateFormat = DateFormatter()
                    dateFormat.dateFormat = "yyyy-MM-dd, hh:mm:ss:a:zzz"

                    self.client?.files.upload(path: "/Inventory Log/UpdatedInvFile \(dateFormat.string(from: Date.init())).csv", input: path!)
                        .response { response, error in
                            if let response = response {
                                print(response)
                                self.dismiss(animated: true, completion: nil)
                            } else if let error = error {
                                print(error)
                            }
                        }
                        .progress { progressData in
                            print(progressData)
                        }

                    // in case you want to cancel the request
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: {action in
                
                return
                }))

                // show the alert
                self.present(alert, animated: true, completion: nil)
        
        print("yo")
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
