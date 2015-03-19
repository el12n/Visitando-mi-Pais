//
//  MunicipioHandler.swift
//  Visitando mi Pais
//
//  Created by Alvaro De la Cruz Lockhart on 3/13/15.
//  Copyright (c) 2015 Alvaro De la Cruz Lockhart. All rights reserved.
//

import Foundation
import CoreData

class MunicipioHandler: APIControllerProtocol {
    
    let MUNICIPIOS_GET = "http://data.developers.do/api/v1/municipios.json"
    
    var id: Int?
    var nombre: String?
    var provincia: Provincia!
    
    init(){
        
    }
    
    init(municipio: Municipio){
        loadHandler(municipio)
    }
    
    init (id: Int, nombre: String, provinciaId: Int){
        self.id = id
        self.nombre = nombre
        self.provincia = ProvinciaController().getProvinciaControllerFromId(provinciaId)
    }
    
    func loadHandler(municipio: Municipio){
        self.id = Int(municipio.id)
        self.nombre = municipio.nombre
        self.provincia = municipio.provincia as Provincia
    }
    
    func requestMunicipios(){
        let apiController = APIController(url: MUNICIPIOS_GET, delegate: self)
        apiController.connect()
    }
    
    func fromJson(json: AnyObject) -> MunicipioHandler{
        let municipioRaw: NSDictionary = json as NSDictionary
        let municipio = MunicipioHandler(id: municipioRaw["id"] as Int, nombre: municipioRaw["nombre"] as String, provinciaId: municipioRaw["provincia_id"] as Int)
        return municipio
    }
    
    func fromJsonArray(json: AnyObject) -> [MunicipioHandler]{
        var municipioList = [MunicipioHandler]()
        let municipioRawArray: NSArray = json as NSArray
        for municipio in municipioRawArray{
            municipioList.append(fromJson(municipio))
        }
        return municipioList
    }
    
    func dbInsertMunicipio(municipios: MunicipioHandler){
        var newMunicipio = NSEntityDescription.insertNewObjectForEntityForName("Municipio", inManagedObjectContext: GlobalVariables.managedObjectContext!) as Municipio
        newMunicipio.id = Int(municipios.id!)
        newMunicipio.nombre = municipios.nombre!
        newMunicipio.provincia = municipios.provincia!
        
        var error: NSError? = nil
        if !GlobalVariables.managedObjectContext!.save(&error){
            println("Error \(error?.userInfo)")
            
        }else{
            println("INSERTING MUNICIPIO WITH ID > \(newMunicipio.id)")
        }
    }
    
    func getAllMunicipiosFromProvinciaWithId(provinciaId: Int) -> [MunicipioHandler]{
        let provincia = ProvinciaController().getProvinciaControllerFromId(provinciaId)
        var municipiosHandler = [MunicipioHandler]()
        for municipio in provincia.municipios{
            municipiosHandler.append(MunicipioHandler(municipio: municipio as Municipio))
        }
        return municipiosHandler
    }
    
    func dbIsFIlledWithData() -> Bool{
        let fetchRequest = NSFetchRequest(entityName: "Municipio")
        let fetchResults = GlobalVariables.managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Municipio]
        if fetchResults?.count > 0 {
            return true
        }
        return false
    }
    
    func getMunicipioByIdentifier(municipioId: Int) -> Municipio{
        let fetchRequest = NSFetchRequest(entityName: "Municipio")
        fetchRequest.predicate = NSPredicate(format: "id = %d", self.id!)
        if let fetchResults = GlobalVariables.managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Municipio]{
            return fetchResults.first!
        }
        return Municipio()
    }
    
    func didReceiveResponse(result: AnyObject) {
        //        TODO proccess Data
        for municipio in fromJsonArray(result){
            dbInsertMunicipio(municipio)
        }
    }
}