//
//  PlanData.swift
//  original_app
//
//  Created by 辻志保美 on 2021/02/14.
//

import UIKit
import Firebase

class PlanData {
    var id: String?
    var date: Date?
    var name: String?
    var attendance: String?
    var startTime: Date?
    var endTime: Date?
    var attendReason: String?
    var healthStatus: String?
    
    init(document: QueryDocumentSnapshot) {
        self.id = document.documentID
        
        let planDic = document.data()
        
        let timestampDate = document["date"] as? Timestamp
        self.date = timestampDate?.dateValue()
        
        self.name = planDic["name"] as? String
        
        self.attendance = planDic["attendance"] as? String
        
        let timestampStart = planDic["startTime"] as? Timestamp
        self.startTime = timestampStart?.dateValue()
        
        let timestampEnd = planDic["endTime"] as? Timestamp
        self.endTime = timestampEnd?.dateValue()
        
        self.attendReason = planDic["attendReason"] as? String
        
        self.healthStatus = planDic["healthStatus"] as? String
        
    }
    
    init() {
        self.id = ""
        
        let date: Date = Date()
        self.date = date
        
        //self.name = ""
        
        self.attendance = ""
        
        self.startTime = date
        
        self.endTime = date
        
        self.attendReason = ""
        
        self.healthStatus = "None"
    }

}
