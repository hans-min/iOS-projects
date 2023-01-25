//
//  ViewController.swift
//  RBGtoHSV
//
//  Created by Thanh Hai NGUYEN on 08/10/2021.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var valueL: UILabel!
    @IBOutlet weak var saturationL: UILabel!
    @IBOutlet weak var hueLabel: UILabel!
    @IBOutlet weak var complementaire: UIImageView!
    @IBOutlet weak var triade1: UIImageView!
    
    @IBOutlet weak var tetrade3: UIImageView!
    @IBOutlet weak var tetrade1: UIImageView!
    @IBOutlet weak var tetrade2: UIImageView!
    @IBOutlet weak var triade2: UIImageView!
    
    var hue: CGFloat = 0
    var saturation: CGFloat = 0
    var value: CGFloat = 0
    var backgroundHue: CGFloat = 0
    
    
    let colorWell: UIColorWell = {
        let colorWell = UIColorWell()
        colorWell.supportsAlpha = false
        colorWell.selectedColor = .systemRed
        return colorWell
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        colorWell.backgroundColor = .init(white: 0.9, alpha: 0.4)
        view.backgroundColor = .systemRed
        view.addSubview(colorWell)
        colorWell.addTarget(self, action: #selector(colorChanged), for: .valueChanged)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        colorWell.frame = CGRect(x: 20, y: view.safeAreaInsets.top, width: view.frame.size.width-40, height: 80)
        
    }
    
    @objc private func colorChanged(){
        view.backgroundColor = colorWell.selectedColor
        colorWell.selectedColor?.getHue(&hue, saturation: &saturation, brightness: &value, alpha: nil)
        hueLabel.text = String(round(Double(hue)*360))+"°"
        saturationL.text = String(round(Double(saturation) * 1000)/10)+"%"
        valueL.text = String(round(Double(value) * 1000)/10)+"%"
        complementaire.backgroundColor = UIColor(hue:(hue+0.5).truncatingRemainder(dividingBy: 1.0), saturation: saturation, brightness: value, alpha: 1)
        triade1.backgroundColor = UIColor(hue: (hue+1/3).truncatingRemainder(dividingBy: 1.0), saturation: saturation, brightness: value, alpha: 1)
        triade2.backgroundColor = UIColor(hue: (hue+2/3).truncatingRemainder(dividingBy: 1.0), saturation: saturation, brightness: value, alpha: 1)
        tetrade1.backgroundColor = UIColor(hue: (hue+1/4).truncatingRemainder(dividingBy: 1.0), saturation: saturation, brightness: value, alpha: 1)
        tetrade2.backgroundColor = complementaire.backgroundColor
        tetrade3.backgroundColor = UIColor(hue: (hue+3/4).truncatingRemainder(dividingBy: 1.0), saturation: saturation, brightness: value, alpha: 1)
    }


}

