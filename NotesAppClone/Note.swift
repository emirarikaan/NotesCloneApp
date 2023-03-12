//
//  Note.swift
//  Project20
//
//  Created by Emir Arıkan on 24.02.2023.
//


import UIKit

class Note: NSObject, Codable {
    var id: Int
    var title: String
    var detail: String
    
    init (id: Int, title : String, detail : String){
        self.id = id
        self.title = title
        self.detail = detail
    }
}
