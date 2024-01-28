//
//  ViewController.swift
//  InputAccessoryView
//
//  Created by Payal Kandlur on 1/21/24.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    
    // accessory textField
    private lazy var accessoryTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.backgroundColor = .clear
        textField.returnKeyType = .done
        textField.delegate = self
        textField.autocorrectionType = .no
        textField.spellCheckingType = .no
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.layer.borderColor = UIColor.black.cgColor
        return textField
    }()
    
    private struct Constants {
        
        let textFieldHeight: CGFloat = 44
        let Offset16: CGFloat = 16
        let Offset8: CGFloat = 8
        
        // textfield tags
        let tag1 = 1
        let tag2 = 2
        let tag3 = 3
        let tag4 = 4
    }
    
    private let constants = Constants()
    private var firstName: String = ""
    private var lastName: String = ""
    private var accessoryView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addTapGestureOnView()
        addTags()
        accessoryView = createAccessoryInputView(accessoryTextField)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(notification:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(notification:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
}

extension ViewController: UITextFieldDelegate {
    override var inputAccessoryView: UIView {
        return accessoryView
    }
    
    func createAccessoryInputView(_ accessoryTextField: UITextField) -> UIView {
        let containerView = UIView()
        containerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 70)
        containerView.addSubview(accessoryTextField)
        NSLayoutConstraint.activate([
            accessoryTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: constants.Offset16),
            accessoryTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -constants.Offset16),
            accessoryTextField.topAnchor.constraint(equalTo: containerView.topAnchor, constant: constants.Offset8),
            accessoryTextField.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -constants.Offset8),
        ])
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .white
        return containerView
    }
    
    // set initial tags
    func addTags() {
        firstNameTextField.tag = constants.tag1
        lastNameTextField.tag = constants.tag2
    }

    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.tag == constants.tag3 {
            firstNameTextField.text = textField.text
            firstName = firstNameTextField.text ?? ""
            textField.resignFirstResponder()
            textField.endEditing(true)
        } else if textField.tag == constants.tag4 {
            lastNameTextField.text = textField.text
            lastName = lastNameTextField.text ?? ""
            accessoryTextField.text = ""
            textField.resignFirstResponder()
            textField.endEditing(true)
        }
        accessoryTextField.resignFirstResponder()
        accessoryTextField.endEditing(true)
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField.tag == 3 {
            firstNameTextField.text = textField.text
            firstName = firstNameTextField.text ?? ""
        } else if textField.tag == 4 {
            lastNameTextField.text = textField.text
            lastName = lastNameTextField.text ?? ""
        }
        return true
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let textfield = view.selectedTextField {
            if textfield.tag == constants.tag1 {
                accessoryTextField.text = firstNameTextField.text
                accessoryTextField.placeholder = firstNameTextField.placeholder
                accessoryTextField.tag = constants.tag3
            } else if textfield.tag == constants.tag2 {
                accessoryTextField.text = lastNameTextField.text
                accessoryTextField.placeholder = lastNameTextField.placeholder
                accessoryTextField.tag = constants.tag4
            }
        }
        accessoryTextField.becomeFirstResponder()
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        
    }
}

// MARK: - Keyboard Gesture control
extension ViewController: UIGestureRecognizerDelegate {
    
    private func addTapGestureOnView() {
        let tapGesture = UITapGestureRecognizer(target: self,
                                                action: #selector(handleTapOnImageView(_:)))
        tapGesture.delegate = self
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapGesture)
    }
    
    @objc func handleTapOnImageView(_ sender: UITapGestureRecognizer? = nil) {
        accessoryTextField.resignFirstResponder()
        accessoryTextField.endEditing(true)
    }
}



extension UIView {
    
    // returns the textfields present in your current view
    var textFieldsInView: [UITextField] {
        return subviews
            .filter({ !($0 is UITextField) })
            .reduce(( subviews.compactMap { $0 as? UITextField }), { sum, current in
                return sum + current.textFieldsInView
            })
    }
    
    // returns the textfield currently in focus/selected/firstResponder
    var selectedTextField: UITextField? {
        return textFieldsInView.filter { $0.isFirstResponder }.first
    }
}

