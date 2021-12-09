//
//  LanguageViewController.swift
//  HorsZone
//
//  Created by Yoan on 04/12/2021.
//

import UIKit

class LanguageViewController: UITableViewController {
    var checked = [Bool]()
    let listLanguage = LanguageAvailable.allCases
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
        cell.textLabel?.text = listLanguage[indexPath.row].rawValue

        if !(listLanguage[indexPath.row].rawValue == selected) {
            cell.accessoryType = .none
        } else if listLanguage[indexPath.row].rawValue == selected {
            cell.accessoryType = .checkmark
        }

        return cell
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listLanguage.count
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {

        if listLanguage[indexPath.row].rawValue == selected {
            tableView.selectRow(at: indexPath,
                                animated: false,
                                scrollPosition: UITableView.ScrollPosition.none)
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // If we are selecting a row that is already checked we do nothing
        guard !(listLanguage[indexPath.row].rawValue == selected) else { return }

        if let cell = tableView.cellForRow(at: indexPath) {
            if cell.accessoryType == .checkmark {
                cell.accessoryType = .none
                selected = listLanguage[indexPath.row].rawValue
            } else {
                cell.accessoryType = .checkmark
                selected = listLanguage[indexPath.row].rawValue
            }
        }
        updateLangueSelected()
    }

    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            if cell.accessoryType == .checkmark {
                cell.accessoryType = .none
                selected = listLanguage[indexPath.row].rawValue
            } else {
                cell.accessoryType = .checkmark
                selected = listLanguage[indexPath.row].rawValue
            }
        }
        updateLangueSelected()
    }

    func updateLangueSelected() {
        let defaults = UserDefaults.standard
        defaults.set(selected, forKey: SettingService.language)
    }
}
