//
//  File.swift
//  HorsZone
//
//  Created by Yoan on 02/11/2021.
//

import Foundation
import CoreData

class ZoneIdentify: NSManagedObject {
    static var all: [ZoneIdentify] {
        let request: NSFetchRequest<ZoneIdentify> = ZoneIdentify.fetchRequest()
        guard let zoneIdentify = try? AppDelegate.viewContext.fetch(request) else {
            return []
        }
        return zoneIdentify
    }
}
