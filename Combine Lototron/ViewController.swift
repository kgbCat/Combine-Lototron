//
//  ViewController.swift
//  Combine Lototron
//
//  Created by Anna Delova on 2/14/22.
//

import UIKit
import Combine
import CombineCocoa

class ViewController: UIViewController {

    @IBOutlet var label1: UILabel!
    @IBOutlet var label2: UILabel!
    @IBOutlet var label3: UILabel!
    @IBOutlet weak var startBtn: UIButton!

    private var isGameOn: Bool = false
    private var resultCombination = [UILabel?]()
    private var cancelables = Set<AnyCancellable>()
    private let emojis = ["🍇", "🍑", "🍋", "🍓", "🍎"]

    override func viewDidLoad() {
        super.viewDidLoad()

        setInitialEmoji()

        startBtn
            .tapPublisher
            .sink { _ in
                self.isGameOn.toggle()
                self.setTimer()
            }
            .store(in: &cancelables)
    }

    private func setInitialEmoji() {
        [label1, label2, label3].forEach { $0?.text = "❔" }
    }
    private func setEmojis() {
        let combination = [label1, label2, label3]
        combination.forEach { $0?.text = emojis.randomElement()}
        self.resultCombination = combination
    }
    private func setTimer() {
        Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .share()
            .scan(0) { counter, _ in counter + 1 }
            .sink { counter in
                if self.isGameOn {
                    self.setEmojis()
                    if counter == 15 {
                        self.isGameOn.toggle()
                        self.checkIfEqual(combination: self.resultCombination)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                            self.setInitialEmoji()
                        }
                    }
                }
            }
            .store(in: &cancelables)
    }
    private func checkIfEqual(combination: [UILabel?]) {
        let set = Set(combination.map({ $0?.text }))
        let hasAllItemsEqual = set.count <= 1
        if hasAllItemsEqual {
            showAlert(message: "Jack Pot!")
        } else {
            showAlert(message: "You lose")
        }
    }
    private func showAlert(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.view.accessibilityIdentifier = "myAlert"
        alert.addAction(UIAlertAction(title: "Ок", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

