//
//  DailyForecastTableViewCell.swift
//  Weather Forecast
//
//  Created by Thanh Hai NGUYEN on 04/10/2021.
//

import UIKit

class DailyForecastTableViewCell: UITableViewCell {
    
    @IBOutlet weak var dayOfWeek: UILabel!
    @IBOutlet var tempMaxMin: UILabel!
    @IBOutlet var humidity: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
  /*  static let identifier = "DailyForecastTableViewCell"
    static func nib() -> UINib {
        return UINib(nibName: "DailyForecastTableViewCell", bundle: nil)
    }
    */
    func configure(with daily: Daily){
        self.humidity.text = String(daily.humidity)+"%"
        self.tempMaxMin.text = String(format: "%.0f", round(daily.temp.max))+"°/"+String(format: "%.0f", round(daily.temp.min))+"°"
        let rawDate = Date(timeIntervalSince1970: TimeInterval(daily.dt))
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        self.dayOfWeek.text = "\(rawDate.dayOfTheWeek())"
       // self.weatherImage = hourly.weather[0].main
    }
    
}
