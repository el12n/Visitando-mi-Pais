//
//  ViewController.swift
//  Visitando mi Pais
//
//  Created by Alvaro De la Cruz Lockhart on 3/12/15.
//  Copyright (c) 2015 Alvaro De la Cruz Lockhart. All rights reserved.
//

import UIKit

struct GlobalVariables {
    static var managedObjectContext = (UIApplication.sharedApplication().delegate as AppDelegate).managedObjectContext
    static var applicatioCalendar = (UIApplication.sharedApplication().delegate as AppDelegate).calendar
}

class ViewController: UIViewController, ProvinciaProtocol, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var provinciaController: ProvinciaController!
    var provincias = [ProvinciaController]()
    let PROVINCIA_CELL_IDENTIFIER = "ProvinciaCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.provinciaController = ProvinciaController(delegate: self)
        if !self.provinciaController.dbIsFilledWithData(){
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            self.provinciaController.requestProvincias()
            var municipioHandler = MunicipioHandler() as MunicipioHandler
            municipioHandler.requestMunicipios()
        }else{
            self.provincias = self.provinciaController.getAllProvinciasFromDb()
            self.tableView.reloadData()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return provincias.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier(PROVINCIA_CELL_IDENTIFIER) as UITableViewCell
        let provincia: ProvinciaController = provincias[indexPath.row] as ProvinciaController
        cell.textLabel?.text = provincia.name
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showMunicipios"{
            let municipioViewController = segue.destinationViewController as MunicipioViewController
            
            let myIndexPath = self.tableView.indexPathForSelectedRow()
            let row = myIndexPath?.row
            municipioViewController.provinciaId = self.provincias[row!].id
        }else if segue.identifier == "ProvinciaToMap"{
            let navController = segue.destinationViewController as UINavigationController
            let mapViewController  = navController.topViewController as MapViewController
            let myIndexPath = sender as NSIndexPath
            let row = myIndexPath.row
            mapViewController.itemToSearch = self.provincias[row].name
        }
    }
    
    func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("ProvinciaToMap", sender: indexPath)
    }
    
    func didListLoad() {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        self.provincias = self.provinciaController.getAllProvinciasFromDb()
        self.tableView.reloadData()
    }
}

