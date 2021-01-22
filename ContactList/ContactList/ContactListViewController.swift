//
//  ViewController.swift
//  ContactList
//
//  Created by Mohamed Khalid on 22/01/2021.
//

import UIKit
import CoreData

class ContactListViewController: UIViewController {
    // MARK:- Outlets
    //
    @IBOutlet weak var contactTableView: UITableView!
    
    // MARK:- Properties
    //
    var contacts: [NSManagedObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        contactTableView.delegate = self
        contactTableView.dataSource = self
        
        fetchDataAndReloadTableView()
    }
    
    @IBAction func addButtonClicked(_ sender: Any) {
        let alert = UIAlertController(title: "New Name", message: "Add new name", preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save", style: .default){ [unowned self] action in
            self.saveData(name: alert.textFields?[0].text ?? "", number: alert.textFields?[1].text ?? "")
            self.fetchDataAndReloadTableView()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        alert.addTextField(configurationHandler: nil)
        alert.addTextField(configurationHandler: nil)
        self.present(alert, animated: true, completion: nil)
    }
    
    
    // Core Data
    //
    func saveData(name: String, number: String){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Content", in: context)
        let contact = NSManagedObject(entity: entity!, insertInto: context)
        contact.setValue(name, forKey: "name")
        contact.setValue(number, forKey: "number")
        do {
            try context.save()
            contacts.append(contact)
        } catch{
            print("Saving error '\(error.localizedDescription)'")
        }
    }
    func fetchDataAndReloadTableView(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext

        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Content")
        do{
            try contacts = context.fetch(fetchRequest)
        } catch{
            print("Loading error '\(error.localizedDescription)'")
        }
        contactTableView.reloadData()
    }
    func deleteRowAtIndex(indexPath: IndexPath){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        context.delete(contacts[indexPath.row])
        do{
            try context.save()
            contacts.remove(at: indexPath.row)
            contactTableView.deleteRows(at: Array(arrayLiteral: indexPath), with: .left)
        } catch{
            print("Saving error '\(error.localizedDescription)'")
        }
        
        
    }
    
}

// MARK:- TableView delegates
//
extension ContactListViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        contacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        if cell == nil {
            cell = UITableViewCell(style: .value1, reuseIdentifier: "Cell")
        }
        cell?.textLabel?.text = contacts[indexPath.row].value(forKey: "name") as? String
        cell?.detailTextLabel?.text = contacts[indexPath.row].value(forKey: "number") as? String
        return cell ?? UITableViewCell()
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else {
            return
        }
        deleteRowAtIndex(indexPath: indexPath)
    }
}

