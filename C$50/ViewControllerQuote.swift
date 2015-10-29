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
        let symbolUser = symbolField.text!
        let symbolEnter = symbolUser.uppercaseString
        
        // clear textField
        self.symbolField.text = ""
        
        // run the function
        _ = lookup(symbolEnter) { name, symbol, price in
            dispatch_async(dispatch_get_main_queue()) {
                self.nameLabel.text = name
                self.symbolLabel.text = symbol
                self.priceLabel.text = "$\(price)"

                
                // alert if error
                if self.nameLabel.text == "" {
                    alert("Error", message: "Could not find the symbol \(symbolEnter)")
                }
            }
        }
        

        self.view.endEditing(true)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // clear labels
        self.nameLabel.text = ""
        self.symbolLabel.text = ""
        self.priceLabel.text = ""
        
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
