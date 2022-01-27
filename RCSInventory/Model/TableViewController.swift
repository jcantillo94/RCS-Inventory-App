//
//  TableViewController.swift
//  RCSInventory
//
//  Created by Jose Cantillo on 11/27/21.
//

import UIKit

class TableViewController: UITableViewCell, UITextFieldDelegate {
    
    
    
    @IBOutlet weak var label: UILabel!
    
    @IBOutlet weak var amountField: UITextField!
    
    @IBOutlet weak var looseCountField: UITextField!
    
    @IBOutlet weak var totalCount: UILabel!
    
    @IBOutlet weak var desc: UITextView!
    
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        print("yo")
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        amountField.delegate = self
        looseCountField.delegate = self
        
        print("inCell")
        
            self.endEditing(true)
            return false
        }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        amountField.delegate = self
        looseCountField.delegate = self
        
            self.endEditing(true)
            return false
        }
    
}
