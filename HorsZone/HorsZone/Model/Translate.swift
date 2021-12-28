//
//  Translate.swift
//  HorsZone
//
//  Created by Yoan on 11/12/2021.
//

import Foundation

class Translate {
    let languageRecorded = UserDefaults.standard.string(forKey: SettingService.language)
    let langueAvailable = LanguageAvailable.allCases
    
    func buttonStartMonitoringText() -> String {
        let language = languageSelected()
        switch language {
        case .english:
            return "Start monitoring"
        case .french:
            return "Commencer la surveillance"
        case .spanish:
            return "Empezar a monitorear"
        case .deutsh:
            return "Überwachung starten"
        }
    }
    
    func buttonStopMonitoringText() -> String {
        let language = languageSelected()

        switch language {
        case .english:
            return "Stop monitoring"
        case .french:
            return "Arrêter la surveillance"
        case .spanish:
            return "Detener el seguimiento"
        case .deutsh:
            return "Überwachung beenden"
        }
    }
    
    func alertLeftZoneTitle() -> String {
        let language = languageSelected()
        
        switch language {
        case .english:
            return "Error"
        case .french:
            return "Erreur"
        case .spanish:
            return "Error"
        case .deutsh:
            return "Fehler"
        }
    }
    
    func alertLeftZoneMessage() -> String {
        let language = languageSelected()
        switch language {
        case .english:
            return "You have left the area !"
        case .french:
            return "Vous avez quittez la zone !"
        case .spanish:
            return "¡Has salido de la zona !"
        case .deutsh:
            return "Sie haben das Gebiet verlassen !"
        }
    }
    
    func addZoneLabelText() -> String {
        let language = languageSelected()
        switch language {
        case .english:
            return "Add zone"
        case .french:
            return "Ajouter une zone"
        case .spanish:
            return "Agregar una zona"
        case .deutsh:
            return "Zone hinzufügen"
        }
    }
    
    func cancelButtonText() -> String {
        let language = languageSelected()

        switch language {
        case .english:
            return "Cancel"
        case .french:
            return "Annuler"
        case .spanish:
            return "Anular"
        case .deutsh:
            return "Abbrechen"
        }
    }
    
    func userLocalizationIssue() -> String {
        let language = languageSelected()
        switch language {
        case .english:
            return "Please activate localization."
        case .french:
            return "Veuillez activer la localisation."
        case .spanish:
            return "Active la localización."
        case .deutsh:
            return "Bitte aktivieren Sie die Lokalisierung."
        }
    }
    
    func mapBarItem() -> String {
        let language = languageSelected()
        switch language {
        case .english:
            return "Map"
        case .french:
            return "Plan"
        case .spanish:
            return "Mapa"
        case .deutsh:
            return "Karte"
        }
    }
    
    func settingBarItem() -> String {
        let language = languageSelected()
        switch language {
        case .english:
            return "Settings"
        case .french:
            return "Réglages"
        case .spanish:
            return "Ajustes"
        case .deutsh:
            return "Einstellungen"
        }
    }
    
    func navigationTitle() -> String {
        let language = languageSelected()
        switch language {
        case .english:
            return "Settings"
        case .french:
            return "Réglages"
        case .spanish:
            return "Ajustes"
        case .deutsh:
            return "Einstellungen"
        }
    }
    
     func settingList() -> [String] {
        let language = languageSelected()
        switch language {
        case .english:
            return ["Languages", "Notification"]
        case .french:
            return ["Langues", "Notification"]
        case .spanish:
            return ["Idiomas", "Notificación"]
        case .deutsh:
            return ["Sprachen", "Benachrichtigung"]
        }
    }
    
    func latitudeTranslate() ->String {
        let language = languageSelected()
        switch language {
        case .english:
           return "Latitude"
        case .french:
          return  "Latitude"
        case .spanish:
          return  "Latitud"
        case .deutsh:
           return "Breite"
        }
    }
    
    func longitudeTranslate() -> String {
        let language = languageSelected()
        switch language {
        case .english:
           return "Longitude"
        case .french:
           return "Longitude"
        case .spanish:
           return "Longitud"
        case .deutsh:
           return "Längengrad"
        }
    }
    
    private func languageSelected() -> LanguageAvailable {
        var languageSelected = LanguageAvailable.english
        for language in langueAvailable {
            if language.rawValue == languageRecorded {
                languageSelected = language
            }
        }
        return languageSelected
    }
    
    
    
}
