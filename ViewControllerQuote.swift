//
//  ViewControllerQuote.swift
//  C$50
//
//  Created by Edouard Jamin on 13/08/15.
//  Copyright © 2015 Gobu. All rights reserved.
//

import UIKit

class ViewControllerQuote: UIViewController {
    
    
    // interface
    @IBOutlet weak var symbolField: UITextField!
    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var buyButton: UIButton!
    
    // get quote button
    @IBAction func getQuote(sender: AnyObject) {
        
        // get symbol asked
        let symbol = symbolField.text!
        
        // clear textField
        self.symbolField.text = ""
        
        // run the function
        _ = lookup(symbol) { name, symbol, price in
            dispatch_async(dispatch_get_main_queue()) {
                self.nameLabel.text = name
                self.symbolLabel.text = symbol
                self.priceLabel.text = "$\(price)"
                self.buyButton.setTitle("Buy some!", forState: UIControlState.Normal)
            }
        }

        self.view.endEditing(true)
    }
    
    // buy some button
    @IBAction func buyButton(sender: AnyObject) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // clear labels
        self.nameLabel.text = ""
        self.symbolLabel.text = ""
        self.priceLabel.text = ""
        self.buyButton.setTitle("", forState: UIControlState.Normal)
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /**
    * Close keyboard
    **/
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(textField :UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
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
