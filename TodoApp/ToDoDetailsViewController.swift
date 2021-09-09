//
//  ViewController.swift
//  TodoApp
//
//  Created by Afir Thes on 08.09.2021.
//


import UIKit

class ToDoDetailsViewController: UIViewController {
    
    var todo: ToDoItem!
    
    var todoIndex: Int!
    
    weak var delegate: ToDoListDelegate?
    
    @IBOutlet weak var taskTitleLabel: UILabel!
    
    @IBOutlet weak var taskDetailsTextView: UITextView!
    
    @IBOutlet weak var taskCompletionButton: UIButton!
    
    @IBOutlet weak var taskCompletionDate: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        taskTitleLabel.text = todo.name
        taskDetailsTextView.text = todo.details
        if todo.isCompleted {
            disableCompleteButton()
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy hh:mm"
        let taskDateStr = formatter.string(from: todo.completionDate!)
        taskCompletionDate.text = taskDateStr
    }
    
   
    func disableCompleteButton() {
        taskCompletionButton.backgroundColor = UIColor.gray
        taskCompletionButton.isEnabled = false
    }
    
    @IBAction func taskDidComplete(_ sender: Any) {
        
        todo.isCompleted = true
        
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        
        disableCompleteButton()
        delegate?.update()

    }
    

}
