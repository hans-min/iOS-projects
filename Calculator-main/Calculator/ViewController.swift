//
//  ViewController.swift
//  Calculator
//
//  Created by Thanh Hai NGUYEN on 17/09/2021.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet var label: UILabel!{
        didSet{
            label.numberOfLines = 0
        }
    }
    var numberOnScreen: Double = 0
    var previousNumber: Double = 0
    var operationTag: Int = 0
    
    
    @IBAction func numbers(_ sender: UIButton) {
        if label.text == "÷" && sender.tag == 0 {
            let alert = UIAlertController(title: "You can't divide by 0", message: "", preferredStyle: .alert)
            self.present(alert, animated: true,completion: nil)
            let when = DispatchTime.now() + 2.5
            DispatchQueue.main.asyncAfter(deadline: when){
              // your code with delay
              alert.dismiss(animated: true, completion: nil)
            }
        }
        if numberOnScreen == 0 {
            label.text = String(sender.tag)
            numberOnScreen = Double(label.text!)!
        } else{
            label.text! += String(sender.tag)
            numberOnScreen = Double(label.text!) ?? 0
        }
    }
    
    @IBAction func percentage(_ sender: UIButton){
        label.text! += "%"
        numberOnScreen /= 100
    }
    
    @IBAction func buttons(_ sender: UIButton) {
        if !" +-÷×".contains(label.text!) && sender.tag  != 11 && sender.tag != 10 { //10 is equal, 11 is clear
            previousNumber = numberOnScreen
            numberOnScreen = 0
            if sender.tag == 12 { //Add
                print(label.intrinsicContentSize)
                label.text! += "\n+";
                print(label.intrinsicContentSize)
            }

            if sender.tag == 13 { //Minus
                label.text! = "-";
            }

            if sender.tag == 14 { //Multiply
                label.text! = "×";
            }

            if sender.tag == 15 { //Divide
                label.text! = "÷";
            }
            operationTag = sender.tag
            
        } else if sender.tag == 10{ //user pressed =
            if operationTag == 12 { //Add
                label.text = String(format: "%g", previousNumber + numberOnScreen)
            }

            if operationTag == 13 { //Minus
                label.text = String(format: "%g", previousNumber - numberOnScreen)

            }
            if operationTag == 14 { //Multiply
                label.text = String(format: "%g", previousNumber * numberOnScreen)
            }
            if operationTag == 15 { //Divide
                label.text = String(format: "%g", previousNumber / numberOnScreen)
            }
            numberOnScreen = Double(label.text!)!
            operationTag = 10
            
        } else if sender.tag == 11 {// clear
            label.text = "0"
            previousNumber = 0;
            numberOnScreen = 0;
            operationTag = 0
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

@IBDesignable extension UIButton {

    @IBInspectable var cornerRadius: CGFloat {
        set {
            layer.cornerRadius = newValue
        }
        get {
            return layer.cornerRadius
        }
    }
    @IBInspectable var borderWidth: CGFloat {
        set {
            layer.borderWidth = newValue
        }
        get {
            return layer.borderWidth
        }
    }
}

