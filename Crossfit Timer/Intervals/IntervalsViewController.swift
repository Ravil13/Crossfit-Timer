//
//  IntervalsViewController.swift
//  Crossfit Timer
//
//  Created by Равиль Вильданов on 08.04.18.
//  Copyright © 2018 Равиль Вильданов. All rights reserved.
//

import UIKit

class IntervalsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
    }
    
}

extension IntervalsViewController {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
        cell.backgroundColor = .black
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat(26)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let height = CGFloat(26)
        let frame = CGRect(x: 0, y: 0, width: (self.tableView.frame.size.width), height: height)
        let view = UIView(frame: frame)
        view.backgroundColor = #colorLiteral(red: 0.05882352941, green: 0.05882352941, blue: 0.05882352941, alpha: 1)
        let label = UILabel(frame: CGRect(x: 16, y: 0, width: 150, height: 26))
        label.text = "Раунд \(section + 1)"
        label.textColor = .white
        label.backgroundColor = .clear
        view.addSubview(label)
        return view
    }
}
