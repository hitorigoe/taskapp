//
//  InputCategoryViewController.swift
//  taskapp
//
//  Created by 鳥越洋之 on 2019/03/04.
//  Copyright © 2019 new torigoe. All rights reserved.
//

import UIKit
import RealmSwift

class InputCategoryViewController: UIViewController {

    @IBOutlet weak var categorytitleTextField: UITextField!
    
    let realm = try! Realm()
    let category = Category()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let category = Category()
        let allCategory = realm.objects(Category.self)
        if allCategory.count != 0 {
            category.id = allCategory.max(ofProperty: "id")! + 1
        }
        self.category.id = category.id
        self.category.category_title = category.category_title
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        try! realm.write {
            if(self.categorytitleTextField.text != "") {
                self.category.category_title = self.categorytitleTextField.text!
                self.realm.add(self.category, update: true)
            }
        }
        super.viewWillDisappear(animated)
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
