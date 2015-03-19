//
//  EventHandler.swift
//  Visitando mi Pais
//
//  Created by Alvaro De la Cruz Lockhart on 3/17/15.
//  Copyright (c) 2015 Alvaro De la Cruz Lockhart. All rights reserved.
//

import Foundation
import CoreData
import EventKit

class EventHandler {
    
    var id: String?
    var titulo: String?
    var inicio: NSDate?
    var fin: NSDate?
    var municipio: Municipio?
    var provincia: String?
    
    init(){
        
    }
    
    init(evento: Evento){
        loadHandler(evento)
    }
    
    func loadHandler(evento: Evento){
        self.id = evento.id
        self.titulo = evento.titulo
        self.inicio = evento.inicio
        self.fin = evento.fin
        self.municipio = evento.municipio
        self.provincia = evento.municipio.provincia.nombre
    }
    
    func createEvent(eventStore: EKEventStore) -> Bool{
        var event = EKEvent(eventStore: eventStore)
        event.title = "Visitar \(municipio!.nombre)"
        event.startDate = self.inicio
        event.endDate = self.fin
        event.calendar = GlobalVariables.applicatioCalendar as EKCalendar?
        var err: NSError?
        eventStore.saveEvent(event, span: EKSpanThisEvent, commit: true, error: &err)
        if err != nil{
            println("Error al insertar. \(err?.localizedDescription)")
            return false
        }else{
            dbCreateEvent(event.eventIdentifier)
            println("Evento insertado con identificador \(event.eventIdentifier)")
            return true
        }
    }
    
    func deleteEvent(eventStore: EKEventStore) -> Bool{
        var event = eventStore.eventWithIdentifier(self.id)
        if(event != nil){
            dbDeleteEvent(event.eventIdentifier)
            var error: NSError?
            eventStore.removeEvent(event, span: EKSpanThisEvent, commit: true, error: &error)
            if error != nil{
                println("Error borrando evento: \(error?.localizedDescription)")
                return false
            }else{
                println("Evento borrado exitosamente")
                return true
            }
        }
        return false
    }
    
    func dbCreateEvent(eventId: String){
        let newEvent = NSEntityDescription.insertNewObjectForEntityForName("Evento", inManagedObjectContext: GlobalVariables.managedObjectContext!) as Evento
        newEvent.id = eventId
        newEvent.titulo = self.titulo!
        newEvent.inicio = self.inicio!
        newEvent.fin = self.fin!
        newEvent.municipio = self.municipio!
        newEvent.provincia = self.municipio!.provincia.nombre
        
        var error: NSError?
        if !GlobalVariables.managedObjectContext!.save(&error){
            println("Error al insertar evento en DB: \(error?.localizedDescription)")
        }else{
            println("Evento agregado exitosamente")
        }
    }
    
    func dbDeleteEvent(eventId: String){
        let event = getEventByIdentifier(eventId)
        GlobalVariables.managedObjectContext!.deleteObject(event)
        var error: NSError?
        if !GlobalVariables.managedObjectContext!.save(&error){
            println("Error: \(error?.localizedDescription)")
        }else{
            println("Evento borrado de la base de datos")
        }
    }
    
    func getEventByIdentifier(eventId: String) -> Evento{
        let fetchRequest = NSFetchRequest(entityName: "Evento")
        fetchRequest.predicate = NSPredicate(format: "id = %@", eventId)
        println(fetchRequest.predicate!)
        if let fetchResult = GlobalVariables.managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as?[Evento]{
            var evento = fetchResult.first as Evento?
            return evento!
        }
        return Evento()
    }
    
    func getAllEvents() -> [EventHandler]{
        var events = [EventHandler]()
        let fetchRequest = NSFetchRequest(entityName: "Evento")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "inicio", ascending: true)]
        if let fetchResult = GlobalVariables.managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [Evento]{
            for event in fetchResult{
                events.append(EventHandler(evento: event))
            }
        }
        return events
    }
}
