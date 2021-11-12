//
//  PointList.swift
//  HorsZone
//
//  Created by Yoan on 08/11/2021.
//

import Foundation
import CoreData

class PointList: NSManagedObject {
    static var all: [PointList] {
        let request: NSFetchRequest<PointList> = PointList.fetchRequest()
        guard let pointList = try? AppDelegate.viewContext.fetch(request) else {
            return []
        }
        return pointList
    }
}
