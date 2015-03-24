//
//  DetaPickerViewController.swift
//  Visitando mi Pais
//
//  Created by Alvaro De la Cruz Lockhart on 3/13/15.
//  Copyright (c) 2015 Alvaro De la Cruz Lockhart. All rights reserved.
//

import UIKit
import EventKit

class DatePickerViewController: UIViewController {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    var appDelegate: AppDelegate?
    var municipio: MunicipioHandler?
    
    override func viewDidLoad(){
        super.viewDidLoad()
        self.appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate
        self.title = "Visitar \(self.municipio!.nombre!)"
        limitateDatePicker()
        dateLabel.text = dateFormatter(NSDate())
        self.datePicker.addTarget(self, action: Selector("datePickerChanged:"), forControlEvents: UIControlEvents.ValueChanged)
    }
    
    func limitateDatePicker(){
        self.datePicker.date = NSDate(timeIntervalSinceNow: NSTimeInterval(2))
        self.datePicker.minimumDate = NSDate(timeIntervalSinceNow: NSTimeInterval(0))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func dateFormatter(date: NSDate) -> String{
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.FullStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
        var strDate = dateFormatter.stringFromDate(date)
        return strDate
    }
    
    func datePickerChanged(datePicker: UIDatePicker){
        self.dateLabel.text = dateFormatter(datePicker.date)
    }
    
    
    func displayGoodAlert(){
        let alert = UIAlertController(title: "Visitas", message: "Visita agregada exitosamente", preferredStyle: UIAlertControllerStyle.Alert)
        var agree = UIAlertAction(title: "Aceptar", style: UIAlertActionStyle.Default){
            UIAlertAction in
            self.closeViewController()
        }
        alert.addAction(agree)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func closeViewController(){
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    @IBAction func createReminder(sender: AnyObject) {
        var eventHandler = EventHandler()
        eventHandler.titulo = "Visitar \(municipio!.nombre!)"
        eventHandler.inicio = datePicker.date
        eventHandler.fin = datePicker.date.dateByAddingTimeInterval(60*60)
        eventHandler.municipio = self.municipio!.getMunicipioByIdentifier(self.municipio!.id!)
        if eventHandler.createEvent(appDelegate!.eventStore!){
            displayGoodAlert()
        }
    }
}