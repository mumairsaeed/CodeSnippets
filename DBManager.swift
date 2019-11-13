//
//  DBManager.swift
//  GrindFitness
//
//  Created by Umair on 05/11/2018.
//  Copyright © 2018 Citrusbits. All rights reserved.
//

import UIKit
import CoreData

// Developer's Note: IMPORTANT!!!!
// Always use private managedobjectcontext for performing any changes to db we are using main managedobjectcontext for display purpose only

// MARK: -

class DBManager: NSObject {
    
    // MARK: -
    
    var persistentContainer: NSPersistentContainer!
    
    // MARK: -
    
    static let shared: DBManager = {
        let instance = DBManager()
        return instance
    }()
    
    override init() {
        super.init()
        loadDefaults()
        setupNotifications()
    }
    
    // MARK: - Core Data stack
    
    func setupStack(dbName: String, completion: @escaping (_ success: Bool, _ errorMessage: String?) -> ()) {
        persistentContainer = NSPersistentContainer(name: dbName)
        
        persistentContainer.loadPersistentStores(completionHandler: { (_, error) in
            var success = true
            var message: String?
            
            if let errorObject = error as NSError? {
                success = false
                message = errorObject.localizedDescription
                print("Unresolved error \(errorObject), \(errorObject.userInfo), \(errorObject.localizedDescription)")
                
            } else {
                // This will save sync changes back to main from private moc or from performBackgroundTask
                self.persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
                
                // It will prioritize store changes over in-memory while saving.
                // For background import context choose NSMergePolicy.mergeByPropertyObjectTrump
                self.persistentContainer.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
            }
            
            completion(success, message)
        })
    }
    
    func context() -> NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func saveContext(completion: ((_ success: Bool) -> Void)? = nil) {
        let context = persistentContainer.viewContext
        
        if context.hasChanges {
            
            context.performAndWait({
                var success = true
                
                do {
                    try context.save()
                    
                } catch {
                    success = false
                    
                    let nserror = error as NSError
                    print("Unresolved error \(nserror), \(nserror.userInfo), \(nserror.localizedDescription)")
                }
                
                if completion != nil {
                    completion!(success)
                }
            })
            
        } else {
            
            if completion != nil {
                completion!(true)
            }
        }
    }
    
    // MARK: - Notification Methods
    
    private func setupNotifications() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(saveChanges(_:)), name: UIApplication.willTerminateNotification, object: nil)
    }
    
    @objc func saveChanges(_ notification: Notification) {
        saveContext(completion: nil)
    }
    
    // MARK: - Private
    
    fileprivate func loadDefaults() {
        
    }
}


// MARK: - How to use

// Call the following method in app delegate did launch

//fileprivate func setupDatabase() {
//    
//    DBManager.shared.setupStack(dbName: "DBName") { (success, error) in
//        
//        if !success {
//            
//            DispatchQueue.main.async {
//               // Show error message or what ever is you requirement, may be you can show error alert the on Okay tap perfrom the follwoing
//                    // Home button pressed programmatically - to thorw app to background
//                    UIControl().sendAction(#selector(URLSessionTask.suspend), to: UIApplication.shared, for: nil)
//
//                    // Terminaing app in background
//                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
//                        exit(EXIT_SUCCESS)
//                    })
//            }
//        }
//    }
//}

// Get the context
// DBManager.shared.context()
