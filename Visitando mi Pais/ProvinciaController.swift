//
//  ProvinciasController.swift
//  Visitando mi Pais
//
//  Created by Alvaro De la Cruz Lockhart on 3/12/15.
//  Copyright (c) 2015 Alvaro De la Cruz Lockhart. All rights reserved.
//

import Foundation
import CoreData

protocol ProvinciaProtocol{
    func didListLoad()
}

class ProvinciaController: APIControllerProtocol{
    
    //    Constants
    let PROVINCIAS_GET = "http://data.developers.do/api/v1/provincias.json"
    //    Variables
    var id: Int?
    var name: String?
    var delegate: ProvinciaProtocol!
    
    init(){
        
    }
    
    init(delegate: ProvinciaProtocol){
        self.delegate = delegate
    }
    
    init(id: Int, name: String){
        self.id = id
        self.name = name
    }
    
    init(provincia: Provincia){
        loadHandler(provincia)
    }
    
    func loadHandler(provincia: Provincia){
        self.id = Int(provincia.id)
        self.name = provincia.nombre
    }
    
    //    Method that request provincias from WS
    func requestProvincias(){
        var apiController = APIController(url: PROVINCIAS_GET, delegate: self)
        apiController.connect()
    }
    //    Method that parse from any object to ProvinciaController
    func fromJson(json: AnyObject) -> ProvinciaController{
        var provinciaDictionary = json as NSDictionary
        return ProvinciaController(id:provinciaDictionary["id"] as Int, name: provinciaDictionary["nombre"] as String)
    }
    //    Method that parse from any object to ProvinciaController Array
    func fromJsonArray(json: AnyObject) -> [ProvinciaController]{
        var provincias = [ProvinciaController]()
        var provinciasArray = json as NSArray
        for provincia in provinciasArray{
            provincias.append(fromJson(provincia))
        }
        return provincias
    }
    
    func dbIsFilledWithData() -> Bool{
        let fetchRequest = NSFetchRequest(entityName: "Provincia")
        let fetchResults = GlobalVariables.managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Provincia]
        if fetchResults?.count > 0 {
            return true
        }
        return false
    }
    
    func getProvinciaControllerFromId(id: Int) -> Provincia{
        let fetchRequest = NSFetchRequest(entityName: "Provincia")
        fetchRequest.predicate = NSPredicate(format: "id = %d", id)
        let fetchResults = GlobalVariables.managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Provincia]
        if fetchResults?.count > 0 {
            let provincia = fetchResults?.first
            return provincia!
        }
        return Provincia()
    }
    
    func getAllProvinciasFromDb() -> [ProvinciaController]{
        var provinciasController = [ProvinciaController]()
        let fetchRequest = NSFetchRequest(entityName: "Provincia")
        if let fetchResults = GlobalVariables.managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Provincia]{
            for provincia in fetchResults{
                provinciasController.append(ProvinciaController(provincia: provincia))
            }
        }
        return provinciasController
    }
    
    func dbInsert(provincia: ProvinciaController){
        var newProvincia = NSEntityDescription.insertNewObjectForEntityForName("Provincia", inManagedObjectContext: GlobalVariables.managedObjectContext!) as Provincia
        newProvincia.id = provincia.id!
        newProvincia.nombre = provincia.name!
        var error: NSError? = nil
        if !GlobalVariables.managedObjectContext!.save(&error){
            println("Error \(error!.userInfo)")
        }else{
            println("INSERTING PROVINCIA WITH ID > \(newProvincia.id)")
        }
    }
    
    func didReceiveResponse(result: AnyObject) {
        //        TODO get result and choose what to do with it
        for provincia in fromJsonArray(result){
            dbInsert(provincia)
        }
        if(delegate != nil){
            delegate.didListLoad()
        }
    }
}