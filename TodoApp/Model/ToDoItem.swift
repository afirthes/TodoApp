//
//  TodoItemModel.swift
//  TodoApp
//
//  Created by Afir Thes on 08.09.2021.
//

import Foundation
import RealmSwift

public class LocalDatabaseManager {
    
    static var realm: Realm? {
            do {
                let realm = try Realm()
                return realm
            } catch {
                return nil
            }
    }
    
}

class Task: Object {
    
    @objc dynamic var id = 0
    
    override static func primaryKey() -> String {
        return "id"
    }
    
    @objc dynamic var name = ""
    @objc dynamic var details = ""
    @objc dynamic var completionDate = NSDate()
    @objc dynamic var startdate = NSDate()
    @objc dynamic var isComplete = false
    
}

