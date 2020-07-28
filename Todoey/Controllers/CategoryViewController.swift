//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Olena Rostovtseva on 20.07.2020.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import ChameleonFramework
import RealmSwift
import UIKit

class CategoryViewController: SwipeTableViewController {
    let realm = try! Realm()
    var categories: Results<CategoryItem>?

    override func viewDidLoad() {
        super.viewDidLoad()
        loadItems()
        tableView.separatorStyle = .none
    }

    override func viewWillAppear(_ animated: Bool) {
        guard let navBar = navigationController?.navigationBar else {
            fatalError("Navigation controller does not exist")
        }
        navBar.backgroundColor = UIColor(hexString: K.navBarColor)
    }

    // MARK: -  Adding categories

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()

        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Item", style: .default) { _ in
            let item = CategoryItem()
            item.name = textField.text!
            item.hexColor = UIColor.randomFlat().hexValue()
            print("category name: \(item.name) hexColor: \(item.hexColor)")
            self.save(category: item)
        }
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Create new category"
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }

    // MARK: -  Tableview datasource methods

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if let category = categories?[indexPath.row] {
            print("category name: \(category.name) hexColor: \(category.hexColor)")
            cell.textLabel?.text = category.name
            let categoryColor = UIColor(hexString: category.hexColor) ?? UIColor.white
            cell.textLabel?.textColor = ContrastColorOf(categoryColor, returnFlat: true)
            cell.backgroundColor = categoryColor
        } else {
            cell.textLabel?.text = "No Categories Added yet"
            cell.backgroundColor = UIColor.white
        }
        return cell
    }

    // MARK: -  Tableview delegate method

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "gotoItems", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodolistViewController
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = self.categories?[indexPath.row]
        }
    }

    // MARK: - Items managing

    fileprivate func save(category: CategoryItem) {
        do {
            try realm.write {
                realm.add(category)
            }
        } catch {
            print("Error saving category \(error)")
        }
        tableView.reloadData()
    }

    override func updateModel(at index: IndexPath) {
        if let category = categories?[index.row] {
            do {
                try realm.write {
                    realm.delete(category)
                }
            } catch {
                print("Error deleting category \(error)")
            }
        }
    }

    fileprivate func loadItems() {
        categories = realm.objects(CategoryItem.self)
        tableView.reloadData()
    }
}
