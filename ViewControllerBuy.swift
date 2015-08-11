//
//  ViewControllerBuy.swift
//  C$50
//
//  Created by Edouard Jamin on 11/08/15.
//  Copyright © 2015 Gobu. All rights reserved.
//

import UIKit
import CoreData

class ViewControllerBuy: UIViewController {
    
    // protypes
    var wanted :Int = 0
    
    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var sharesLabel: UILabel!
    @IBOutlet weak var worthLabel: UILabel!

    @IBOutlet weak var sharesBuy: UILabel!
    
    @IBOutlet weak var worthBuy: UILabel!
    
    @IBOutlet weak var sharesStepper: UIStepper!
    
    @IBAction func buyButton(sender: AnyObject) {
        
        buy(shareSelected, number: wanted)
        self.performSegueWithIdentifier("back", sender: self)
    }
    
    @IBAction func backButton(sender: AnyObject) {
        self.performSegueWithIdentifier("buyToHome", sender: self)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // stepper configs
        sharesStepper.wraps = false
        sharesStepper.autorepeat = true
        sharesStepper.maximumValue = 99
        
        var number :Double = 0.00
        
        _ = lookup(shareSelected) { name, symbol, price in
            dispatch_async(dispatch_get_main_queue()) {
                self.symbolLabel.text = symbol
                self.priceLabel.text = price
            }
        }
        
        let appDel :AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context :NSManagedObjectContext = appDel.managedObjectContext
        
        let request = NSFetchRequest(entityName: "Shares")
        request.returnsObjectsAsFaults = false
        
        
        do {
            let results = try context.executeFetchRequest(request)
            
            if results.count > 0 {
                for result in results as! [NSManagedObject] {
                    if result.valueForKey("symbol") as! String == shareSelected {
                        number = result.valueForKey("shares")! as! Double
                        self.sharesLabel.text = String(Int(number))
                    }
                }
            }
        } catch {
            print(error)
        }
        
        _ = price(shareSelected) { price in
            dispatch_async(dispatch_get_main_queue()) {
                let worthInt = price * number
                let worth = String(worthInt)
                self.worthLabel.text = "$\(worth)"
            }
        }


        // Do any additional setup after loading the view.
    }
    
    // stepper changed
    @IBAction func stepperChanged(sender: UIStepper) {
        
        self.sharesBuy.text = Int(sender.value).description
        wanted = Int(sender.value)
        _ = price(shareSelected) { price in
            dispatch_async(dispatch_get_main_queue()) {
                let worthInt = Int(price) * self.wanted
                self.worthBuy.text = String(worthInt)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
