//
//  TestViewController.swift
//  Visitando mi Pais
//
//  Created by Alvaro De la Cruz Lockhart on 3/17/15.
//  Copyright (c) 2015 Alvaro De la Cruz Lockhart. All rights reserved.
//

import UIKit
import CoreData

class EventViewController: UITableViewController, NSFetchedResultsControllerDelegate, EventCellProtocoll {
    
    var managedObjectContext = (UIApplication.sharedApplication().delegate as AppDelegate).managedObjectContext!
    
    //    Initialicing the fetcher
    var fetchedResultsController: NSFetchedResultsController{
        if self._fetchedResultsController != nil{
            return self._fetchedResultsController!
        }
        let managedObjectContext = self.managedObjectContext
        let event = NSEntityDescription.entityForName("Evento", inManagedObjectContext: managedObjectContext)
        let sort = NSSortDescriptor(key: "provincia", ascending: true)
        let req = NSFetchRequest()
        req.entity = event
        req.sortDescriptors = [sort]
        
        let aFetchedResultController = NSFetchedResultsController(fetchRequest: req, managedObjectContext: managedObjectContext, sectionNameKeyPath: "provincia", cacheName: nil)
        aFetchedResultController.delegate = self
        self._fetchedResultsController = aFetchedResultController
        
        var e: NSError?
        if !self._fetchedResultsController!.performFetch(&e){
            println("Error \(e?.localizedDescription)")
            abort()
        }
        return self._fetchedResultsController!
    }
    var eventStore = (UIApplication.sharedApplication().delegate as AppDelegate).eventStore
    var _fetchedResultsController: NSFetchedResultsController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.fetchedResultsController.sections?.count ?? 0
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let info = self.fetchedResultsController.sections![section] as NSFetchedResultsSectionInfo
        return info.numberOfObjects
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("Cell") as EventCell
        self.configureCell(cell, atIndexPath: indexPath)
        return cell
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let info = self.fetchedResultsController.sections![section] as NSFetchedResultsSectionInfo
        return info.name
    }
    
    func configureCell(cell: EventCell, atIndexPath indexPath: NSIndexPath){
        let item = self.fetchedResultsController.objectAtIndexPath(indexPath) as Evento
        cell.delegate = self
        cell.indexPath = indexPath
        cell.title.text = item.titulo
        cell.startDate.text = "Inicio: \(self.dateFormatter(item.inicio))"
        cell.endDate.text = "Fin: \(self.dateFormatter(item.fin))"
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type{
        case .Delete:
            self.tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: UITableViewRowAnimation.Fade)
        default:
            return
        }
    }
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            self.tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: UITableViewRowAnimation.Fade)
        case .Update:
            let cell = self.tableView.cellForRowAtIndexPath(indexPath!)
            self.configureCell(cell! as EventCell, atIndexPath: indexPath!)
            self.tableView.reloadRowsAtIndexPaths([indexPath!], withRowAnimation: UITableViewRowAnimation.Fade)
        case .Move:
            self.tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: UITableViewRowAnimation.Fade)
            self.tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: UITableViewRowAnimation.Fade)
        case .Delete:
            self.tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: UITableViewRowAnimation.Fade)
        default:
            return
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.endUpdates()
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete{
            var event = self.fetchedResultsController.objectAtIndexPath(indexPath) as Evento
            var eventoHandler = EventHandler(evento: event)
            eventoHandler.deleteEvent(self.eventStore!)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "EventToMap"{
            let navController = segue.destinationViewController as UINavigationController
            let mapViewController = navController.topViewController as MapViewController
            let myIndexPath = sender as NSIndexPath
            var evento = self.fetchedResultsController.objectAtIndexPath(myIndexPath) as Evento
            mapViewController.itemToSearch = "\(evento.municipio.nombre), \(evento.municipio.provincia.nombre)"
        }
    }
    
    func dateFormatter(date: NSDate) -> String{
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
        var strDate = dateFormatter.stringFromDate(date)
        return strDate
    }
    
    func onLocationButtonTapped(indexPathAt myIndexPath: NSIndexPath) {
        performSegueWithIdentifier("EventToMap", sender: myIndexPath)
    }
    
    @IBAction func deleteEvent(sender: UIBarButtonItem) {
        if (tableView.indexPathForSelectedRow() != nil){
            let indexPath = self.tableView.indexPathForSelectedRow()
            var event = self.fetchedResultsController.objectAtIndexPath(indexPath!) as Evento
            var eventoHandler = EventHandler(evento: event)
            eventoHandler.deleteEvent(self.eventStore!)
        }else{
            let alert = UIAlertController(title: "Error al eliminar", message: "Primero debe selecionar el evento a eliminar", preferredStyle: UIAlertControllerStyle.Alert) as UIAlertController
            let okAction = UIAlertAction(title: "Aceptar", style: UIAlertActionStyle.Default, handler: nil) as UIAlertAction
            alert.addAction(okAction)
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
}
