//
//  SettingsViewController.swift
//  HorsZone
//
//  Created by Yoan on 12/11/2021.
//

import UIKit

class SettingsViewController: UIViewController {
    
    // MARK: - Properties
    var settingsList = Translate().settingList()
    var translateText = Translate()
   
    
    // MARK: - IBOutlet
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var settingsNavigationItem: UINavigationItem!
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        settingsList = Translate().settingList()
        super.viewWillAppear(animated)
        translateText = Translate()
        tableView.reloadData()
        initializeTranslateView()
    }
    
    private func initializeTranslateView() {
        settingsNavigationItem.title = translateText.settingBarItem()
//        SettingNavigationViewController().initializeLanguage()
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
        
        if indexPath.row == 0 {
            cell.detailTextLabel?.text = languageSelected
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let identifier = indexPath
        if identifier.row == 0 {
            performSegue(withIdentifier: "SelectLanguage", sender: self)
        }
    }
}
