//
//  Provincia.swift
//  Visitando mi Pais
//
//  Created by Alvaro De la Cruz Lockhart on 3/16/15.
//  Copyright (c) 2015 Alvaro De la Cruz Lockhart. All rights reserved.
//

import Foundation
import CoreData

@objc(Provincia)
class Provincia: NSManagedObject {

    @NSManaged var id: NSNumber
    @NSManaged var nombre: String
    @NSManaged var municipios: NSSet

}
