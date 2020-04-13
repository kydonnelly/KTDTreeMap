//
//  ViewController.swift
//  TreeMapCollectionView
//
//  Created by Kyle Donnelly on 3/15/20.
//  Copyright © 2020 Kyle Donnelly. All rights reserved.
//

import UIKit
import KTDTreeMap

class ViewController: UIViewController {
    
    @IBOutlet var inputField: UITextField!
    @IBOutlet var pickerView: UIPickerView!
    
    @IBAction func nextButtonTapped() {
        guard let inputText = self.inputField.text else {
            return
        }
        
        // Take any properly-input values and silently discard the rest
        let inputValues = inputText.components(separatedBy: ", ").compactMap { Double($0) }.filter { $0 >= 0.0 }
        let type = pickerView.selectedRow(inComponent: 0)
        let layoutType = TreeMapCollectionView.LayoutType(rawValue: type) ?? .squares
        
        let storyboard = UIStoryboard(name: "TreeMap", bundle: .main)
        guard let treeMapVC = storyboard.instantiateInitialViewController() as? TreeMapViewController else {
            return
        }
        
        treeMapVC.setup(sizes: inputValues, layoutType: layoutType)
        self.navigationController?.pushViewController(treeMapVC, animated: true)
    }

}

extension ViewController : UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 4
    }
    
}

extension ViewController : UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 32.0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let titles = ["Rows", "Columns", "Squares", "Spiral"]
        return titles[row]
    }
    
}
