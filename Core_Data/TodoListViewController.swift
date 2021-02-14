//
//  TodoListViewController.swift
//  Core_Data
//
//  Created by Dominik Polzer on 21.12.20.
//  Copyright © 2020 Dominik Polzer. All rights reserved.
//

import UIKit
import CoreData

class TodoListViewController: UITableViewController {
    
    var todoList: [TodoItem] = []
    
    var managedObjectContext: NSManagedObjectContext {
        let appDelegete = UIApplication.shared.delegate as! AppDelegate
        return appDelegete.persistentContainer.viewContext
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let fetchRequest: NSFetchRequest<TodoItem> = TodoItem.fetchRequest()
        
        do{
            todoList = try managedObjectContext.fetch(fetchRequest)
        }catch let error as NSError{
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoCell", for: indexPath)
        let todoItem = todoList[indexPath.row]
        cell.textLabel?.text = todoItem.title
        
        return cell
    }
    
    
    @IBAction func addButton(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "New Todo Item", message: "Add a new todo item", preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save", style: .default) {
            [unowned self] action in
            guard let textField = alert.textFields?.first, let nameToSave = textField.text else {
                return
            }
            
            let todoItem = TodoItem(context: self.managedObjectContext)
            todoItem.title = nameToSave
            do{
                try self.managedObjectContext.save()
                self.todoList.append(todoItem)
                self.tableView.reloadData()
                
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addTextField()
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
    
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let item = todoList[indexPath.row]
            managedObjectContext.delete(item)
            
            do{
                try self.managedObjectContext.save()
                todoList.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }catch let error as NSError{
                print("Could not reload. \(error), \(error.userInfo)")
            }
        }
    }
    
}
