//
//  MunicipioViewController.swift
//  Visitando mi Pais
//
//  Created by Alvaro De la Cruz Lockhart on 3/13/15.
//  Copyright (c) 2015 Alvaro De la Cruz Lockhart. All rights reserved.
//

import UIKit

class MunicipioViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    var municipios = [MunicipioHandler]()
    var provinciaId: Int?
    let MUNICIPIO_CELL_IDENTIFIER = "MunicipioCell"
    override func viewDidLoad() {
        super.viewDidLoad()
        var municipios = MunicipioHandler().getAllMunicipiosFromProvinciaWithId(self.provinciaId!)
        self.municipios = municipios
        self.title = self.municipios.first?.provincia.nombre
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(self.MUNICIPIO_CELL_IDENTIFIER) as UITableViewCell
        let municipio = self.municipios[indexPath.row] as MunicipioHandler
        
        cell.textLabel?.text = municipio.nombre
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.municipios.count
    }
    
    func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("MunicipioToMap", sender: indexPath)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "MakeVisit"{
            let datePickerViewController = segue.destinationViewController as DatePickerViewController
            let myIndexPath = self.tableView.indexPathForSelectedRow()
            let row = myIndexPath?.row
            datePickerViewController.municipio = self.municipios[row!]
        }else if segue.identifier == "MunicipioToMap"{
            let navController = segue.destinationViewController as UINavigationController
            let mapViewController = navController.topViewController as MapViewController
            let myIndexPath = sender as NSIndexPath
            let row = myIndexPath.row
            mapViewController.itemToSearch = "\(municipios[row].nombre!), \(municipios[row].provincia.nombre)"
        }
    }
    
}
