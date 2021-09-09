//
//  ViewController.swift
//  TodoApp
//
//  Created by Afir Thes on 08.09.2021.
//

import UIKit
import RealmSwift

protocol ToDoListDelegate: AnyObject {
    func update()
}

class ToDoListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    // no cachig
    var toDoItems: Results<Task>? {
        guard let realm = LocalDatabaseManager.realm else {
            return nil
        }
        
        return realm.objects(Task.self) // all objects
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.tableFooterView = UIView() // убрать линию разделения
        title = "To Do List"
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self , action: #selector(addTapped))
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self , action: #selector(editTapped))
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(addNewTask(_ :)),
                                               name: NSNotification.Name.init("ru.windwail.addtask"),
                                               object: nil)

    }
    
    @objc func addNewTask(_ notification: NSNotification) {
        // everything is in database
        tableView.reloadData()
    }
    
    
    @objc func addTapped() {
        tableView.setEditing(false, animated: false)
        performSegue(withIdentifier: "AddTaskSegue", sender: nil)
    }
    
    @objc func editTapped() {
        self.tableView.setEditing(!tableView.isEditing, animated: true)
        
        if tableView.isEditing == true {
                navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(editTapped))
        } else {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self , action: #selector(editTapped))
        }
    }
    
    // TODO: UITableViewRowAction' was deprecated in iOS 13.0: Use UIContextualAction and related APIs instead.
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        // action to perform
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { action, indexPath in
            
            guard let realm = LocalDatabaseManager.realm else { return }
            guard let item = self.toDoItems?[indexPath.row] else { return }
            
            do {
                try realm.write({
                    realm.delete(item)
                })
            } catch let error as NSError {
                print(error)
                return
            }
            
            self.tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
        }
        
        return [delete]
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let todo = toDoItems![indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItem")!
        
        cell.textLabel?.text = todo.name
        cell.detailTextLabel?.text = todo.isComplete ? "Complete" : "Incomplete"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        toDoItems?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let todoSelected = toDoItems![indexPath.row] // force, ith should exist
        performSegue(withIdentifier: "TaskDetailsSegue", sender: (todoSelected, indexPath.row))
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "TaskDetailsSegue" {
        
            guard let detailsView = segue.destination as? ToDoDetailsViewController else { return }
            
            guard let sender = sender as? (Task, Int) else { return }
            
            (detailsView.todo, detailsView.todoIndex) = sender
            detailsView.delegate = self
        }
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.init("ru.windwail.addtask"), object: nil)
    }


}

extension ToDoListViewController: ToDoListDelegate {
    func update() {
        tableView.reloadData()
    }
}

