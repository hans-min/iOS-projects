//
//  TableViewCell.swift
//  Weather Forecast
//
//  Created by Thanh Hai NGUYEN on 07/10/2021.
//

import UIKit

class TableViewCell: UITableViewCell {
    
  //  @IBOutlet weak var imageView: UIImageView?
    @IBOutlet var number: UILabel?
 //   @IBOutlet var humidity: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(with number: String){
        self.number?.text = number

       // self.weatherImage = hourly.weather[0].main
    }

}
