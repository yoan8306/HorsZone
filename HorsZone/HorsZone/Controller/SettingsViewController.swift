//
//  SettingsViewController.swift
//  HorsZone
//
//  Created by Yoan on 12/11/2021.
//

import UIKit

class SettingsViewController: UIViewController {
    
    // MARK: - Properties
    let settingsList = ["Langues", "Son des alertes"]
    
    
    // MARK: - IBOutlet
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
}

// MARK: - Table View Data source
extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let languageSelected = UserDefaults.standard.string(forKey: SettingService.language)
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCells", for: indexPath)
        cell.textLabel?.text = settingsList[indexPath.row]
        
        if settingsList[indexPath.row] == "Langues" {
            cell.detailTextLabel?.text = languageSelected
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let identifier = indexPath
        if settingsList[identifier.row] == "Langues" {
            performSegue(withIdentifier: "SelectLanguage", sender: self)
        }
    }
}
