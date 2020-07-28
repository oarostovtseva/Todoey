//
//  ViewController.swift
//  Todoey
//
//  Created by Olena Rostovtseva on 24.07.2020.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import ChameleonFramework
import RealmSwift
import UIKit

class TodolistViewController: SwipeTableViewController {
    let realm = try! Realm()

    var todoItems: Results<TodoItem>?
    var selectedCategory: CategoryItem? {
        didSet {
            loadItems()
        }
    }

    @IBOutlet var searchBar: UISearchBar!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorStyle = .none
    }

    override func viewWillAppear(_ animated: Bool) {
        if let navBarColor = UIColor(hexString: selectedCategory?.hexColor ?? K.defaultRowColor) {
            title = selectedCategory!.name
            guard let navBar = navigationController?.navigationBar else {
                fatalError("Navigation controller does not exist")
            }
            navBar.backgroundColor = navBarColor
            let contrastedColor: UIColor = ContrastColorOf(navBarColor, returnFlat: true)
            navBar.tintColor = contrastedColor
            navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: contrastedColor]
            searchBar.barTintColor = navBarColor
        }
    }

    // MARK: -  Tableview datasource methods

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)

        if let item = todoItems?[indexPath.row] {
            cell.textLabel?.text = item.title
            cell.accessoryType = item.isDone ? .checkmark : .none

            let backgroundColor = UIColor(hexString: selectedCategory?.hexColor ?? K.defaultRowColor)?.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(todoItems!.count))

            if let color = backgroundColor {
                cell.backgroundColor = color
                cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
            }

        } else {
            cell.textLabel?.text = "No Items Added Yet"
        }

        return cell
    }

    // MARK: - Tableview delegate methods

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let item = todoItems?[indexPath.row] {
            do {
                try self.realm.write {
                    item.isDone = !item.isDone
                }
            } catch {
                print("Error saving done status \(error)")
            }
            self.tableView.reloadData()
        }
    }

    // MARK: - Add new items

    @IBAction func addItemButtonPressed(_ sender: UIButton) {
        var textField = UITextField()

        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Item", style: .default) { _ in
            if let category = self.selectedCategory {
                do {
                    try self.realm.write {
                        let item = TodoItem()
                        item.title = textField.text!
                        item.dateCreated = Date()
                        category.items.append(item)
                    }
                } catch {
                    print(error)
                }
            }
            self.tableView.reloadData()
        }
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }

    // MARK: - Items managing

    fileprivate func saveItems(todoItem: TodoItem) {
        do {
            try realm.write {
                realm.add(todoItem)
            }
        } catch {
            print("Error saving category \(error)")
        }
        tableView.reloadData()
    }

    fileprivate func loadItems() {
        let sortProperties = [SortDescriptor(keyPath: "dateCreated", ascending: false), SortDescriptor(keyPath: "title", ascending: true)]
        todoItems = selectedCategory?.items.sorted(by: sortProperties)
        tableView.reloadData()
    }

    override func updateModel(at index: IndexPath) {
        if let item = todoItems?[index.row] {
            do {
                try realm.write {
                    realm.delete(item)
                }
            } catch {
                print("Error deleting todo item \(error)")
            }
        }
    }
}

// MARK: - Searchbar methods

extension TodolistViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: false)
        tableView.reloadData()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}
