//
//  ViewController.swift
//  RealTime DataBase
//
//  Created by JAYDEN SAWYER on 2/6/25.
//
import UIKit
import FirebaseCore
import FirebaseDatabase

class Student {
    var name: String
    var age: Int
    var key: String = "" // Store Firebase key
    static var ref = Database.database().reference()
    
    init(name: String, age: Int) {
        self.name = name
        self.age = age
    }
    
    init(dict: [String: Any]) {
        self.name = dict["name"] as? String ?? ""
        self.age = dict["age"] as? Int ?? 0
    }
    
    func saveToFirebase() {
        let dict = ["name": name, "age": age] as [String: Any]
        let newRef = Student.ref.child("students2").childByAutoId()
        key = newRef.key ?? "0"
        newRef.setValue(dict)
    }
    
    func deleteFromFirebase() {
        Student.ref.child("students2").child(key).removeValue()
    }
    
    func updateFirebase(dict: [String: Any]) {
        Student.ref.child("students2").child(key).updateChildValues(dict)
    }
    
    static func == (lhs: Student, rhs: Student) -> Bool {
        return lhs.name == rhs.name && lhs.age == rhs.age
    }
}

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableViewOutlet: UITableView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var ageTextField: UITextField!
    
    var students: [Student] = []
    var selectedRow: Int = -1
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableViewOutlet.delegate = self
        tableViewOutlet.dataSource = self
        ref = Database.database().reference()
        
        observeStudents()
    }
    
    func observeStudents() {
        ref.child("students2").observe(.childAdded, with: { snapshot in
            if let dict = snapshot.value as? [String: Any] {
                let student = Student(dict: dict)
                student.key = snapshot.key
                
                if !self.students.contains(where: { $0.key == student.key }) {
                    self.students.append(student)
                    DispatchQueue.main.async {
                        self.tableViewOutlet.reloadData()
                    }
                }
            }
        })
        
        ref.child("students2").observe(.childRemoved, with: { snapshot in
            self.students.removeAll { $0.key == snapshot.key }
            DispatchQueue.main.async {
                self.tableViewOutlet.reloadData()
            }
        })
        
        ref.child("students2").observe(.childChanged, with: { snapshot in
            if let dict = snapshot.value as? [String: Any] {
                let updatedStudent = Student(dict: dict)
                updatedStudent.key = snapshot.key
                
                if let index = self.students.firstIndex(where: { $0.key == updatedStudent.key }) {
                    self.students[index] = updatedStudent
                    DispatchQueue.main.async {
                        self.tableViewOutlet.reloadData()
                    }
                }
            }
        })
    }
    
    @IBAction func saveStudent(_ sender: Any) {
        guard let name = nameTextField.text, !name.isEmpty,
              let ageText = ageTextField.text, let age = Int(ageText) else { return }
        
        let student = Student(name: name, age: age)
        students.append(student)
        student.saveToFirebase()
        
        tableViewOutlet.reloadData()
        nameTextField.text = ""
        ageTextField.text = ""
    }
    
    @IBAction func updateStudent(_ sender: Any) {
        guard selectedRow >= 0 else { return }
        guard let name = nameTextField.text, !name.isEmpty,
              let ageText = ageTextField.text, let age = Int(ageText) else { return }
        
        let student = students[selectedRow]
        student.name = name
        student.age = age
        student.updateFirebase(dict: ["name": name, "age": age])
        
        tableViewOutlet.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return students.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath)
        let student = students[indexPath.row]
        cell.textLabel?.text = "\(student.name) - \(student.age)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedRow = indexPath.row
        let student = students[selectedRow]
        nameTextField.text = student.name
        ageTextField.text = "\(student.age)"
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let student = students[indexPath.row]
            student.deleteFromFirebase()
            students.remove(at: indexPath.row)
            tableViewOutlet.reloadData()
        }
    }
}
