//
//  Category.swift
//  Todoey
//
//  Created by Olena Rostovtseva on 24.07.2020.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift

class CategoryItem: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var hexColor: String = ""
    let items = List<TodoItem>()
}
