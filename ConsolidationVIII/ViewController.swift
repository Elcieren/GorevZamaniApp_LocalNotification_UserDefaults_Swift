//
//  ViewController.swift
//  ConsolidationVIII
//
//  Created by Eren Elçi on 15.11.2024.
//

import UIKit
import UserNotifications

class ViewController: UIViewController , UITableViewDelegate ,  UITableViewDataSource{

    @IBOutlet var tableView: UITableView!
    
    var tasks = [Task]()
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(addTask))
        
        let defaults = UserDefaults.standard
        if let savedTask = defaults.object(forKey: "task") as? Data {
            let jsonDecoder = JSONDecoder()
            
            do {
                tasks = try jsonDecoder.decode([Task].self, from: savedTask)
            } catch {
                print("Failed to load people")
            }
        }
        
        let center = UNUserNotificationCenter.current()
        
        center.requestAuthorization(options: [.alert , .badge , .sound]) { granted , error in
            if granted {
                
                DispatchQueue.main.async {
                    self.alertMessage(title: "Bilgilendirme", message: "Eklediginiz gorevler icin bildirim alicaksiniz")
                }
                
            } else {
                DispatchQueue.main.async {
                    self.alertMessage(title: "Bilgilendirme", message: "Eklediginiz gorevler icin bildirim alamicaksiniz")
                }
                
            }
        }
       
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        var content = cell.defaultContentConfiguration()
        let task = tasks[indexPath.row]
        content.text = task.task
        content.secondaryText = "saat:\(task.saat) dakika:\(task.dakika)"
        cell.contentConfiguration = content
        return cell
    }
    
    @objc func addTask(){
        let ac = UIAlertController(title: "Gorev Ekle", message: "Eklemek istediginiz gorev ve hatirlatici suresini giriniz", preferredStyle: .alert)
        
        ac.addTextField { textfiled in
            textfiled.placeholder = "Gorev Giriniz"
        }
        ac.addTextField { textfiled in
            textfiled.placeholder = "hatirlatici saat giriniz"
        }
        ac.addTextField { textfiled in
            textfiled.placeholder = "hatirlatici dakika giriniz"
        }
        
        let submitAction = UIAlertAction(title: "Ekle", style: .default) { [weak self, weak ac] _ in
                    guard let taskText = ac?.textFields?[0].text, !taskText.isEmpty,
                        let saatText = ac?.textFields?[1].text, let saat = Int(saatText), (0...23).contains(saat),
                        let dakikaText = ac?.textFields?[2].text, let dakika = Int(dakikaText), (0...59).contains(dakika) else { return }
            self?.submit(taskText, "\(saat)", "\(dakika)")
        }
        
        let cancel = UIAlertAction(title: "Çıkış", style: UIAlertAction.Style.cancel, handler: nil)
        ac.addAction(submitAction)
        ac.addAction(cancel)
        present(ac, animated: true)
    }
    
    func submit(_ taskler: String , _ saat: String , _ dakika: String) {
        let task = Task(task: taskler, saat: saat  , dakika: dakika )
        tasks.append(task)
        save()
        tableView.reloadData()
        
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        
        let content = UNMutableNotificationContent()
        content.title = "Ekledigin gorev Hatirlatici"
        content.body = taskler
        content.categoryIdentifier = "alarm"
        content.sound = .default
        
        var dateComponents = DateComponents()
        dateComponents.hour = Int(saat)
        dateComponents.minute = Int(dakika)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        center.add(request) { error in
            if let error = error {
                print("Bildirimde hata olustu \(error.localizedDescription)")
            } else{
                print("Bildirim gonderilcek ")
            }
        }
        
        
        
    }
    
    func save(){
        let jsonEncoder = JSONEncoder()
        if let saveData = try? jsonEncoder.encode(tasks) {
            let defaults = UserDefaults.standard
            defaults.set(saveData, forKey: "task")
        } else {
            print("failed to save people")
        }
    }
    
    
    func alertMessage(title: String , message:String) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Tamam", style: .default, handler: nil))
        present(ac, animated: true)
    }


}

