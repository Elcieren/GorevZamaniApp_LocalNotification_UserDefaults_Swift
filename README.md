## Swift-LocalNotifications Uygulama Kullanımı
| Gorev Ekleme Bildirim Yollanması | Uygulama Kapali Bildirim Yollama |
|---------|---------|
| ![Video 1](https://github.com/user-attachments/assets/16a69555-35f1-46fe-af3a-cbfc760a0c2f) | ![Video 2](https://github.com/user-attachments/assets/7e6b327b-c721-43cd-85f8-52332cf291df) |

 <details>
    <summary><h2>Uygulma Amacı</h2></summary>
    Proje Amacı
   Bu Swift uygulaması, iOS'ta yerel bildirimlerin kullanımını göstermektedir. Uygulama, başlangıçta kullanıcıdan bildirim izni ister ve iki tür bildirim sunar: Standart Bildirim ve Etkileşimli Bildirim. Standart bildirim, kullanıcıya bir seçim sunmadan direkt bir uyarı verirken, etkileşimli bildirim kullanıcıya üç seçenek sunar: "Cevapla", "İptal Et" ve "Daha Sonra Hatırlat". Bu seçenekler, kullanıcıya daha etkileşimli bir deneyim sunar.
  </details>  

  <details>
    <summary><h2>viewDidLoad()</h2></summary>
    tableView için veri kaynağı ve delege ayarlanır.
    Ekranın sağ üst köşesine "Ekle" butonu eklenir.
    UserDefaults ile önceden kaydedilmiş görevler varsa yüklenir ve tasks dizisine eklenir.
    Bildirim izni alınır. Kullanıcı izin verirse bilgi mesajı gösterilir
    
    ```
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

    ```
  </details> 

  <details>
    <summary><h2>tableView(_:cellForRowAt:)</h2></summary>
    Her bir hücre için görev adı ve zamanı gösterilir.

    
    ```
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = UITableViewCell()
    var content = cell.defaultContentConfiguration()
    let task = tasks[indexPath.row]
    content.text = task.task
    content.secondaryText = "saat:\(task.saat) dakika:\(task.dakika)"
    cell.contentConfiguration = content
    return cell
    }



    ```
  </details> 

  <details>
    <summary><h2>addTask()</h2></summary>
    Yeni görev eklemek için uyarı ekranı açar.
    Görev adı ve saat/dakika değerlerini kullanıcıdan alır.
    Ekle butonuna basıldığında, girilen bilgileri submit fonksiyonuna gönderir.
    
    ```
     @objc func addTask() {
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


    
    ```
  </details> 


  <details>
    <summary><h2>submit(_:_:_:)</h2></summary>
    Yeni bir Task nesnesi oluşturur ve tasks dizisine ekler.
    Görevleri kaydeder ve tableView’i günceller.
    Bildirim içeriği (UNMutableNotificationContent) ve tetikleme zamanı (UNCalendarNotificationTrigger) ayarlanır.
    UNUserNotificationCenter üzerinden bildirim planlanır
    
    ```
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
        } else {
            print("Bildirim gonderilcek ")
        }
    }
    }



    ```
  </details> 

  <details>
    <summary><h2>save()</h2></summary>
    tasks listesini UserDefaults içine JSON formatında kaydeder.
     Kayıt başarılı olmazsa hata mesajı yazdırır.
    
    ```
    func save(){
    let jsonEncoder = JSONEncoder()
    if let saveData = try? jsonEncoder.encode(tasks) {
        let defaults = UserDefaults.standard
        defaults.set(saveData, forKey: "task")
    } else {
        print("failed to save people")
    }
    }



    ```
  </details> 

  <details>
    <summary><h2>Task Modeli</summary>
   Task modeli, task, saat, ve dakika bilgilerini içerir.
   Codable protokolünü kullanarak tasks listesini JSON formatında UserDefaults’e kaydetmek ve okumak mümkündür.
    
    ```
    class Task: Codable {
    var task: String
    var saat: String
    var dakika: String
    
    init(task: String, saat: String, dakika: String) {
        self.task = task
        self.saat = saat
        self.dakika = dakika
    }
    }




    ```
  </details> 


<details>
    <summary><h2>Uygulama Görselleri </h2></summary>
    
    
 <table style="width: 100%;">
    <tr>
        <td style="text-align: center; width: 16.67%;">
            <h4 style="font-size: 14px;">Bildirim Izni</h4>
            <img src="https://github.com/user-attachments/assets/7c2c7cad-f7fe-4037-aa22-5da31576794b" style="width: 100%; height: auto;">
        </td>
        <td style="text-align: center; width: 16.67%;">
            <h4 style="font-size: 14px;">Gorev ve Saat Girilim Alani</h4>
            <img src="https://github.com/user-attachments/assets/e45e4105-a492-42b8-b99d-80b730bc6d58" style="width: 100%; height: auto;">
        </td>
        <td style="text-align: center; width: 16.67%;">
            <h4 style="font-size: 14px;">Bildirim Yollanmasi</h4>
            <img src="https://github.com/user-attachments/assets/216ef2ed-2382-454a-9785-e5b4431f5861" style="width: 100%; height: auto;">
        </td>
    </tr>
</table>
  </details> 
