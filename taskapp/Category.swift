//
//  Category.swift
//  taskapp
//
//  Created by 鳥越洋之 on 2019/03/04.
//  Copyright © 2019 new torigoe. All rights reserved.
//

import RealmSwift

class Category: Object {
    // 管理用 ID。プライマリーキー
    @objc dynamic var id = 0
    
    /// カテゴリ
    @objc dynamic var category_title = ""
    /**
     id をプライマリーキーとして設定
     */
    override static func primaryKey() -> String? {
        return "id"
    }
}

