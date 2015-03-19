//
//  Evento.swift
//  Visitando mi Pais
//
//  Created by Alvaro De la Cruz Lockhart on 3/17/15.
//  Copyright (c) 2015 Alvaro De la Cruz Lockhart. All rights reserved.
//

import Foundation
import CoreData

@objc(Evento)
class Evento: NSManagedObject {

    @NSManaged var fin: NSDate
    @NSManaged var id: String
    @NSManaged var inicio: NSDate
    @NSManaged var titulo: String
    @NSManaged var provincia: String
    @NSManaged var municipio: Municipio

}
