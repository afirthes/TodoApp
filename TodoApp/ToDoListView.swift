//
//  ViewController.swift
//  TodoApp
//
//  Created by Afir Thes on 08.09.2021.
//

import UIKit

protocol ToDoListDelegate: AnyObject {
    
    func update(task: ToDoItem, index: Int)
    
}

class ToDoListView: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var todoItems: [ToDoItem] = [ToDoItem]()

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.tableFooterView = UIView() // убрать линию разделения
        title = "To Do List"
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self , action: #selector(addTapped))
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self , action: #selector(editTapped))
        
        var testItem = ToDoItem(name: "Test item 1", details: "Test details 1", completionDate: Date())
        todoItems.append(testItem)
        
        testItem = ToDoItem(name: "Test item 2", details: "Test details 2", completionDate: Date())
        testItem.isComplete = true
        todoItems.append(testItem)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(addNewTask(_ :)),
                                               name: NSNotification.Name.init("ru.windwail.addtask"),
                                               object: nil)

    }
    
    @objc func addNewTask(_ notification: NSNotification) {
        var todoItem: ToDoItem!
        
        if let task = notification.object as? ToDoItem {
            todoItem = task
        } else {
            return
        }
        
        todoItems.append(todoItem)
        todoItems.sort{ $0.completionDate > $1.completionDate }
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
            self.todoItems.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
        }
        
        return [delete]
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let todo = todoItems[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItem")!
        
        cell.textLabel?.text = todo.name
        cell.detailTextLabel?.text = todo.isComplete ? "Complete" : "Incomplete"
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        todoItems.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let todoSelected = todoItems[indexPath.row]
        performSegue(withIdentifier: "TaskDetailsSegue", sender: (todoSelected, indexPath.row))
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "TaskDetailsSegue" {
        
            guard let detailsView = segue.destination as? ToDoDetailsViewController else { return }
            
            guard let sender = sender as? (ToDoItem, Int) else { return }
            
            (detailsView.todo, detailsView.todoIndex) = sender
            detailsView.delegate = self
        }
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.init("ru.windwail.addtask"), object: nil)
    }


}

extension ToDoListView: ToDoListDelegate {
    func update(task: ToDoItem, index: Int) {
        todoItems[index] = task
        tableView.reloadData()
    }
}

