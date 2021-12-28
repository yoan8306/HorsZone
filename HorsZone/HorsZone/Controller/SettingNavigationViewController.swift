//
//  SettingNavigationViewController.swift
//  HorsZone
//
//  Created by Yoan on 14/12/2021.
//

import UIKit

class SettingNavigationViewController: UINavigationController {

    var translateText = Translate()
    
    @IBOutlet weak var navigationTitle: UINavigationBar!
    @IBOutlet weak var settingBarItem: UITabBarItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeLanguage()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        translateText = Translate()
        initializeLanguage()
    }
        
    public func initializeLanguage() {
        print("navigationTitle")
        navigationTitle.topItem?.title = translateText.navigationTitle()
        settingBarItem.title = translateText.settingBarItem()
    }
    
}
