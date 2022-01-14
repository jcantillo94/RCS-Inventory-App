//
//  Product.swift
//  RCSInventory
//
//  Created by Jose Cantillo on 1/9/22.
//

import Foundation
import RealmSwift

class Product: Object {
    @objc dynamic var barcode: String = ""
    @objc dynamic var prodno: String = ""
    @objc dynamic var name: String = ""
    @objc dynamic var lngdesc: String = ""
    @objc dynamic var qtymaster: Int = 0
}
