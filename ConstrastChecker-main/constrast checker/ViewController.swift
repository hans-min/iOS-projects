//
//  ViewController.swift
//  constrast checker
//
//  Created by Thanh Hai NGUYEN on 15/10/2021.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var passFail: UILabel!
    @IBOutlet weak var fr: UISlider!
    @IBOutlet weak var bg: UISlider!
    @IBOutlet weak var bb: UISlider!
    @IBOutlet weak var backgroundColor: UIImageView!
    @IBOutlet weak var br: UISlider!
    @IBOutlet weak var demoLine: UILabel!
    @IBOutlet weak var fg: UISlider!
    @IBOutlet weak var constrastNumber: UILabel!
    @IBOutlet weak var fb: UISlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        let green = bg.value/255
        let blue = bb.value/255
        backgroundColor.backgroundColor = UIColor(red: CGFloat(br.value / 255) , green: CGFloat(green), blue: CGFloat(blue), alpha: 1.0)
        demoLine.textColor = UIColor(red: CGFloat(fr.value/255), green: CGFloat(fg.value/255), blue: CGFloat(fb.value/255), alpha: 1.0)
        constrastNumber.text = String(format: "%g", contrast())
        passFail.text = """
        AA-level large text: \(contrast() > 3 ? "PASS" : "FAIL")
        AA-level small text: \(contrast() > 4.5 ? "PASS" : "FAIL")
        AAA-level large text:\(contrast() > 4.5 ? "PASS" : "FAIL")
        AAA-level small text: \(contrast() > 7 ? "PASS" : "FAIL")
        """
    }
    
    func luminance(r: Float,g:Float, b:Float) -> Float {
        var a = [r, g, b].map{$0/255}
        a  =  a.map({ $0 <= 0.03928 ? $0 / 12.92 : pow(($0 + 0.055)/1.055, 2.4) })
        return a[0] * 0.2126 + a[1] * 0.7152 + a[2] * 0.0722
    }
    func contrast() -> Float{
        let lum1 = luminance(r:br.value,g:bg.value,b: bb.value)
        let lum2 = luminance(r:fr.value,g:fg.value, b:fb.value)
        let brightest = [lum1, lum2].max()!
        let darkest = [lum1, lum2].min()!
        return (brightest + 0.05) / (darkest + 0.05)
    }
}

