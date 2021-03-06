//
//  Database+Save.swift
//  SmogWatch
//
//  Created by Filip Szukala on 06/11/2018.
//  Copyright © 2018 Filip Szukala. All rights reserved.
//

import UIKit
import CoreData

extension Database {
    func save(data: [String: Any], as entityName: String, primaryKey: String) {
        DispatchQueue.main.async {
            guard let primaryKeyValue = data[primaryKey] else { return }
            guard let managedContext = self.managedContext else { return }
            var managedObject: NSManagedObject? = nil

            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
            fetchRequest.fetchLimit = 1

            if let primaryKeyValue = primaryKeyValue as? Int {
                fetchRequest.predicate = NSPredicate(format: "\(primaryKey) = %d", primaryKeyValue)
            } else if let primaryKeyValue = primaryKeyValue as? String {
                fetchRequest.predicate = NSPredicate(format: "\(primaryKey) = %@", primaryKeyValue)
            } else if let primaryKeyValue = primaryKeyValue as? UUID {
                fetchRequest.predicate = NSPredicate(format: "%K == %@", primaryKey, primaryKeyValue.uuidString as CVarArg)
            } else {
                return
            }

            do {
                if let fetchResults = try managedContext.fetch(fetchRequest) as? [NSManagedObject] {
                    if fetchResults.count != 0 {
                        managedObject = fetchResults[0]
                        print("💾 🔵 Updating entity \(entityName) with \(primaryKey) = \(primaryKeyValue)")
                    }
                }
            } catch let error {
                print(error.localizedDescription)
            }

            if managedObject == nil {
                guard let entity = NSEntityDescription.entity(forEntityName: entityName, in: managedContext) else { return }
                managedObject = NSManagedObject(entity: entity, insertInto: managedContext)
                print("💾 ⚪️ Creating entity \(entityName) with \(primaryKey) = \(primaryKeyValue)")
            }

            for (key, value) in data {
                managedObject!.setValue(value, forKey: key)
            }

            do {
                try managedContext.save()

            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
        }
    }
}
