//
//  CountData.swift
//  original_app
//
//  Created by 辻志保美 on 2021/03/06.
//

import UIKit
import Firebase

class CountData {
    var date: Date?
    var companyCount: Int?
    var homeCount: Int?

    init(document: QueryDocumentSnapshot) {
        let countDic = document.data()
        
        let timestampDate = document["date"] as? Timestamp
        self.date = timestampDate?.dateValue()

        self.companyCount = countDic["companyCount"] as? Int

        self.homeCount = countDic["homeCount"] as? Int
    }
    
    init() {
        let date: Date = Date()
        self.date = date
        
        self.companyCount = 0
        
        self.homeCount = 0
    
    }
}
