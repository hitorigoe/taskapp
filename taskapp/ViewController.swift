//
//  ViewController.swift
//  taskapp
//
//  Created by new torigoe on 2019/02/28.
//  Copyright © 2019 new torigoe. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,UISearchBarDelegate,UIPickerViewDelegate, UIPickerViewDataSource {

    
    @IBOutlet weak var searchBarField: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var searchPickerView: UIPickerView!
    
    // Realmインスタンスを取得する
    let realm = try! Realm()  // ←追加
    //print(path)
    // DB内のタスクが格納されるリスト。
    // 日付近い順\順でソート：降順
    // 以降内容をアップデートするとリスト内は自動的に更新される。
    var taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: false)
    var dataList = try! Realm().objects(Category.self)
    var drumRollRow:Int!
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBarField?.delegate = self
        // Do any additional setup after loading the view, typically from a nib.
        tableView.delegate = self
        tableView.dataSource = self
        searchPickerView.delegate = self
        searchPickerView.dataSource = self
        self.tableView.reloadData()
        let category = Category()
        let allCategory = realm.objects(Category.self)
        if allCategory.count == 0 {
            
            //category.id = 1
            category.category_title = "全て"
            try! realm.write {
                self.realm.add(category, update: true)
            }
            //realm.add(category, update: true)
        }
        self.searchPickerView.reloadAllComponents()
        
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        drumRollRow = row
        if(row != 0) {
            taskArray = try! Realm().objects(Task.self).filter("category_id = \(row)")
        } else {
            taskArray = try! Realm().objects(Task.self)
        }
        self.tableView.reloadData()
        
    }
    func pickerView(_ pickerView: UIPickerView,
                    numberOfRowsInComponent component: Int) -> Int {
        return dataList.count
    }
    func pickerView(_ pickerView: UIPickerView,
                    titleForRow row: Int,
                    forComponent component: Int) -> String? {
        
        return dataList[row].category_title
    }
    
    // MARK: UITableViewDataSourceプロトコルのメソッド
    // データの数（＝セルの数）を返すメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("startcount")
        print(taskArray.count)
        print("startcount")
        //self.tableView.reloadData()
        return taskArray.count
    }
    
    // 各セルの内容を返すメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // 再利用可能な cell を得る
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        // Cellに値を設定する.  --- ここから ---
        let task = taskArray[indexPath.row]
        dump(indexPath.row)
        cell.textLabel?.text = task.title
            
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
            
        let dateString:String = formatter.string(from: task.date)
        cell.detailTextLabel?.text = dateString

        // --- ここまで追加 ---

        return cell
    }
    // サーチバーで検索ボタンが押された時の処理
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        // キーボードをしまう
        searchBar.resignFirstResponder()
        taskArray = try! Realm().objects(Task.self).filter("category == '\(searchBar.text!)'")
        print("searchcount")
        print(taskArray.count)
        print("searchcount")
        
        // テーブル再表示
        self.tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: false)
        self.tableView.reloadData()
    }
    
    // MARK: UITableViewDelegateプロトコルのメソッド
    // 各セルを選択した時に実行されるメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "cellSegue",sender: nil) // ←追加する
    }
    
    // セルが削除が可能なことを伝えるメソッド
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath)-> UITableViewCell.EditingStyle {
        return .delete
    }
    
    // Delete ボタンが押された時に呼ばれるメソッド
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        // --- ここから ---
        if editingStyle == .delete {
            // 削除するタスクを取得する
            let task = self.taskArray[indexPath.row]
            
            // ローカル通知をキャンセルする
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: [String(task.id)])
            
            // データベースから削除する
            try! realm.write {
                self.realm.delete(task)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            
            // 未通知のローカル通知一覧をログ出力
            center.getPendingNotificationRequests { (requests: [UNNotificationRequest]) in
                for request in requests {
                    print("/---------------")
                    print(request)
                    print("---------------/")
                }
            }
        } // --- ここまで変更 ---
    }
    

    
    // segue で画面遷移するに呼ばれる
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        let inputViewController:InputViewController = segue.destination as! InputViewController
        
        if segue.identifier == "cellSegue" {
            let indexPath = self.tableView.indexPathForSelectedRow
            inputViewController.task = taskArray[indexPath!.row]
        } else {
            // 新規
            let task = Task()
            task.date = Date()
            
            
            let allTasks = realm.objects(Task.self)
            if allTasks.count != 0 {
                task.id = allTasks.max(ofProperty: "id")! + 1
            }
            
            inputViewController.task = task
        }
    }
    
    // 入力画面から戻ってきた時に TableView を更新させる
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        searchPickerView.reloadAllComponents()
    }


}

