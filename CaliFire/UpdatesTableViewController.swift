//
//  UpdatesTableViewController.swift
//  CaliFire
//
//  Created by Guest account on 9/21/18.
//  Copyright © 2018 ParraIndustries. All rights reserved.
//

import UIKit
import CloudKit

struct Updates {
    
    struct Keys {
        
        static let name =  "name"
        
    }
    
    //struct recordType {
    
    //    static let recordType = "Updates"
    
    //}
    
    //print("\(Keys.name)") // “name"
    
    fileprivate static let recordType = "Updates"
    //fileprivate static let keys = (name : "name")
    
    var record : CKRecord
    
    init(record : CKRecord) {
        self.record = record
    }
    
    init() {
        self.record = CKRecord(recordType: Updates.recordType)
    }
    
    var name : String! {
        get {
            return self.record.value(forKey: Updates.Keys.name) as? String
        }
        set {
            self.record.setValue(newValue, forKey: Updates.Keys.name)
        }
    }
    
}

class UpdatesModel {
    
    private let database = CKContainer.default().publicCloudDatabase
    
    var updates = [Updates()] {
        didSet {
            self.onChange?()
        }
    }
    
    var onChange : (() -> Void)?
    var onError : ((Error) -> Void)?
    var notificationQueue = OperationQueue.main
    
    private func handle(error: Error){
        
        self.notificationQueue.addOperation {
            
            self.onError?(error)
            
        }
        
    }
    
    init() {
    }
    
    var records = [CKRecord]()
    var insertedObjects = [Updates]()
    var deletedObjectIds = Set<CKRecord.ID>()
    
    func addUpdates(name : String) {
        
        var updates = Updates()
        updates.name = name
        database.save(updates.record) { _, error in
            guard error == nil else {
                self.handle(error: error!)
                return
            }
        }
        
        self.insertedObjects.append(updates)
        self.updateUpdates()
        
    }
    
    func delete(at index : Int) {
        let recordId = self.updates[index].record.recordID
        database.delete(withRecordID: recordId) { _, error in
            guard error == nil else {
                self.handle(error: error!)
                return
            }
        }
        
        deletedObjectIds.insert(recordId)
        updateUpdates()
        
    }
    
    private func updateUpdates() {
        
        var knownIds = Set(records.map { $0.recordID })
        
        // remove objects from our local list once we see them returned from the cloudkit storage
        self.insertedObjects.removeAll { updates in
            knownIds.contains(updates.record.recordID)
        }
        knownIds.formUnion(self.insertedObjects.map { $0.record.recordID })
        
        // remove objects from our local list once we see them not being returned from storage anymore
        self.deletedObjectIds.formIntersection(knownIds)
        
        var updates = records.map { record in Updates(record: record) }
        
        updates.append(contentsOf: self.insertedObjects)
        updates.removeAll { updates in
            deletedObjectIds.contains(updates.record.recordID)
        }
        
        self.updates = updates
        
        debugPrint("Tracking local objects \(self.insertedObjects) \(self.deletedObjectIds)")
    }
    
    @objc func refresh() {
        
        let query = CKQuery(recordType: Updates.recordType, predicate: NSPredicate(value: true))
        
        database.perform(query, inZoneWith: nil) { records, error in
            guard let records = records, error == nil else {
                self.handle(error: error!)
                return
            }
            
            self.updates = records.map { record in Updates(record: record) }
            
            self.records = records
            self.updateUpdates()
        }
    }
    
}

class UpdatesTableViewController: UITableViewController {
    
    var model = UpdatesModel()
    
    // MARK: - UIViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.contentInset = UIEdgeInsets(top: 20.0, left: 0.0, bottom: 0.0, right: 0.0)
      
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44
        
        tableView.reloadData()
    
        
        struct Keys {
            
            static let name = "name"
            
        }
        
        print("\(Keys.name)") // “name")
        
        self.model.onError = { error in
            let alert = UIAlertController(title: "Error", message: String(describing: error), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default))
            self.present(alert, animated: true, completion: nil)
            self.refreshControl!.endRefreshing()
        }
        
        self.model.onChange = {
            self.tableView.reloadData()
            self.refreshControl!.endRefreshing()
        }
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self.model, action: #selector(UpdatesModel.refresh), for: .valueChanged)
        self.refreshControl = refreshControl
        
        self.model.refresh()
    }
    
    // MARK: - Actions
    
    @IBAction func addUpdates() {

        
        let alertController = UIAlertController(title: "Add Updates", message: "", preferredStyle: .alert)
        alertController.addTextField(configurationHandler: nil)
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            let name = alertController.textFields!.first!.text!
            if name.count > 0 {
                self.model.addUpdates(name: name)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .default)
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Protocol UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.model.updates.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LabelCell", for: indexPath)
        
        let updates = model.updates[indexPath.row]
        cell.textLabel?.text = updates.name
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.model.delete(at: indexPath.row)
            // tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    
}
