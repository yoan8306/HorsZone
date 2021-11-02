//
//  extensionMKPolygon.swift
//  HorsZone
//
//  Created by Yoan on 02/11/2021.
//

import Foundation
import MapKit

extension MKPolygon {
    func contain(coordonate: CLLocationCoordinate2D) -> Bool {
        let polygonRenderer = MKPolygonRenderer(polygon: self)
        let currentMapPoint: MKMapPoint = MKMapPoint(coordonate)
        let polygonViewPoint: CGPoint = polygonRenderer.point(for: currentMapPoint)
        if polygonRenderer.path == nil {
            return false
        } else {
            return polygonRenderer.path.contains(polygonViewPoint)
        }
    }
}
