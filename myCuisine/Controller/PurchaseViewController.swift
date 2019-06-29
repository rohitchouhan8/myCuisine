//
//  PurchaseViewController.swift
//  myCuisine
//
//  Created by Rohit Chouhan on 6/28/19.
//  Copyright © 2019 Rohit Chouhan. All rights reserved.
//

import UIKit
import StoreKit
class PurchaseViewController: UIViewController, SKPaymentTransactionObserver {

    

    let oneRandomSpinId = "com.Chouhan.Rohit.CuisineMe.OneRandomSpin"

    @IBOutlet weak var oneRandomSpinButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        SKPaymentQueue.default().add(self)
    }
    
    @IBAction func oneRandomSpin(_ sender: UIButton) {
        if SKPaymentQueue.canMakePayments() {
            //Can make payments
            let paymentRequest = SKMutablePayment()
            paymentRequest.productIdentifier = oneRandomSpinId
            SKPaymentQueue.default().add(paymentRequest)
        } else {
            // Can't make payments
            print("User can't make payments")
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            if transaction.transactionState == .purchased {
                //User payment successful
                print("Transaction successful")
            } else if transaction.transactionState == .failed {
                // Payment failed
                print("Transaction failed")
            }
        }
    }
}
