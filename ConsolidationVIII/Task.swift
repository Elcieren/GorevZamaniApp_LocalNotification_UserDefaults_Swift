//
//  Task.swift
//  ConsolidationVIII
//
//  Created by Eren Elçi on 15.11.2024.
//

import Foundation


class Task: Codable {
    var task: String
    var saat: String
    var dakika: String
    
    init(task: String, saat: String, dakika: String) {
        self.task = task
        self.saat = saat
        self.dakika = dakika
    }
}
