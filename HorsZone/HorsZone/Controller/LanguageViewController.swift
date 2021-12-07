//
//  LanguageViewController.swift
//  HorsZone
//
//  Created by Yoan on 04/12/2021.
//

import UIKit

class LanguageViewController: UITableViewController {
    var checked = [Bool]()
    var choices = ["English", "French"]
    var selected = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.allowsMultipleSelection = false

        let defaults = UserDefaults.standard
        checked = defaults.array(forKey: "Language")  as? [Bool] ?? [true, false]
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateSwitchState()
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateSwitchState()
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let languageSelected = SettingService.language
        let cell = tableView.dequeueReusableCell(withIdentifier: "languageChoiceCell", for: indexPath)

        cell.textLabel?.text = choices[indexPath.row]
        cell.detailTextLabel?.text = languageSelected
        if !checked[indexPath.row] {
            cell.accessoryType = .none
        } else if checked[indexPath.row] {
            cell.accessoryType = .checkmark
        }

        return cell
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return choices.count
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {

        if checked[indexPath.row] {

            tableView.selectRow(at: indexPath, animated: false, scrollPosition: UITableView.ScrollPosition.none)

        }

    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        // If we are selecting a row that is already checked we do nothing

        guard !checked[indexPath.row] else { return }

        // Reset all checked state.

        checked = [Bool](repeating: false, count: choices.count)

        // And set the current row to true.

        checked[indexPath.row] = true

        if let cell = tableView.cellForRow(at: indexPath) {
            if cell.accessoryType == .checkmark {
                cell.accessoryType = .none
                checked[indexPath.row] = false
                selected = choices[indexPath.row]
            } else {
                cell.accessoryType = .checkmark
                checked[indexPath.row] = true
                selected = choices[indexPath.row]
            }
        }

        updateSwitchState()

    }

    // did ** DE ** Select

    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {

        if let cell = tableView.cellForRow(at: indexPath) {
            if cell.accessoryType == .checkmark {
                cell.accessoryType = .none
                checked[indexPath.row] = false
                selected = choices[indexPath.row]
            } else {
                cell.accessoryType = .checkmark
                checked[indexPath.row] = true
                selected = choices[indexPath.row]
            }
        }

        updateSwitchState()

    }

    func updateSwitchState() {
        
        let defaults = UserDefaults.standard
        defaults.set(checked, forKey: "Language")
        defaults.set(selected, forKey: SettingService.language)
        
        
    }

}
