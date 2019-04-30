//
//  ViewController.swift
//  CSwitcherView

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var switcher: CSwitcherView! {
        didSet {
            switcher.addTarget(target: self, action: #selector(switcherDidToggle), for: .valueChanged)
        }
    }
    @IBOutlet weak var stateLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupStateLabel()
    }
    
    private func setupStateLabel() {
        switch switcher.state {
        case .on:
            stateLabel.text = "ON"
        case .off:
            stateLabel.text = "OFF"
        }
    }
}

@objc private extension ViewController {
    func switcherDidToggle() {
        setupStateLabel()
    }
}
