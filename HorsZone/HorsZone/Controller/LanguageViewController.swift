//
//  LanguageViewController.swift
//  HorsZone
//
//  Created by Yoan on 04/12/2021.
//

import UIKit

class LanguageViewController: UITableViewController {
    var checked = [Bool]()
    var choices = ["English", "French", "Polska", "Deutsh", "Spanish"]
    var selected = UserDefaults.standard.string(forKey: SettingService.language)

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.allowsMultipleSelection = false
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tableView.reloadData()
        updateLangueSelected()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "languageChoiceCell", for: indexPath)
        cell.textLabel?.text = choices[indexPath.row]

        if !(choices[indexPath.row] == selected) {
            cell.accessoryType = .none
        } else if choices[indexPath.row] == selected {
            cell.accessoryType = .checkmark
        }

        return cell
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return choices.count
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {

        if choices[indexPath.row] == selected {
            tableView.selectRow(at: indexPath,
                                animated: false,
                                scrollPosition: UITableView.ScrollPosition.none)
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // If we are selecting a row that is already checked we do nothing
        guard !(choices[indexPath.row] == selected) else { return }

        if let cell = tableView.cellForRow(at: indexPath) {
            if cell.accessoryType == .checkmark {
                cell.accessoryType = .none
                selected = choices[indexPath.row]
            } else {
                cell.accessoryType = .checkmark
                selected = choices[indexPath.row]
            }
        }
        updateLangueSelected()
    }

    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            if cell.accessoryType == .checkmark {
                cell.accessoryType = .none
                selected = choices[indexPath.row]
            } else {
                cell.accessoryType = .checkmark
                selected = choices[indexPath.row]
            }
        }
        updateLangueSelected()
    }

    func updateLangueSelected() {
        let defaults = UserDefaults.standard
        defaults.set(selected, forKey: SettingService.language)
    }

}
