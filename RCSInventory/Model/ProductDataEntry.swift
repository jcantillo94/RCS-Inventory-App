//
//  ProductDataEntry.swift
//  RCSInventory
//
//  Created by Jose Cantillo on 1/10/22.
//

import Foundation

class ProductDataEntry: Codable {
    var barcode: String
    var prodno: String
    var lngdesc: String
    var boxCount: String
    var looseCount: String
    var finalCount: String
    
    init(barcode : String, prodNo : String, lngDesc: String, boxCount : String, looseCount : String, finalCount : String) {
        self.barcode = barcode
        self.prodno = prodNo
        self.lngdesc = lngDesc
        self.boxCount = boxCount
        self.looseCount = looseCount
        self.finalCount = finalCount
    }
}
