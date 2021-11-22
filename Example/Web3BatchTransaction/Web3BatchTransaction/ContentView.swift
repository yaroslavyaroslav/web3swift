//
//  ContentView.swift
//  Web3BatchTransaction
//
//  Created by Yaroslav on 18.11.2021.
//

import SwiftUI
import web3swift
import OSLog

struct ContentView: View {

    var _walletAddress: String {
        didSet{
//            self.continueButton.isHidden = false
//            self.walletAddressLabel.text = newValue
        }
    }

    var _mnemonics: String = ""

    var body: some View {
        Text("Hello, world!")
            .padding()
    }

    mutating func createMnemonics() {
        guard let userDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first else { return }

//        guard let web3KeystoreManager = KeystoreManager.managerForPath(userDir + "/keystore") else { return }

//        guard let addresses = web3KeystoreManager.addresses else { return }

        guard let tempMnemonics = try? BIP39.generateMnemonics(bitsOfEntropy: 256) else {
            self.showAlertMessage(title: "", message: "We are unable to create wallet", actionName: "Ok")
            return
        }

        self._mnemonics = tempMnemonics
        os_log("\(tempMnemonics)")

        guard let tempWalletAddress = try? BIP32Keystore(mnemonics: self._mnemonics , prefixPath: "m/44'/77777'/0'/0") else { return }

        os_log("print(tempWalletAddress?.addresses?.first?.address as Any)")

        guard let walletAddress = tempWalletAddress.addresses?.first else {
            self.showAlertMessage(title: "", message: "We are unable to create wallet", actionName: "Ok")
            return
        }

        self._walletAddress = walletAddress.address

//        guard let privateKey = try? tempWalletAddress.UNSAFE_getPrivateKeyData(password: "", account: walletAddress) else { return }
//
//        os_log("print(privateKey! as Any, \"Is the private key\")")

        guard let keyData = try? JSONEncoder().encode(tempWalletAddress.keystoreParams) else { return }

        FileManager.default.createFile(atPath: userDir + "/keystore" + "/key.json", contents: keyData, attributes: nil)
    }
//
//    private func showImportALert() {
//        let alert = UIAlertController(title: "MyWeb3Wallet", message: "", preferredStyle: .alert)
//        alert.addTextField { textfied in
//            textfied.placeholder = "Enter mnemonics/private Key"
//        }
//        let mnemonicsAction = UIAlertAction(title: "Mnemonics", style: .default) { _ in
//            print("Clicked on Mnemonics Option")
//            guard let mnemonics = alert.textFields?[0].text else { return }
//            print(mnemonics)
//        }
//        let privateKeyAction = UIAlertAction(title: "Private Key", style: .default) { _ in
//            print("Clicked on Private Key Wallet Option")
//            guard let privateKey = alert.textFields?[0].text else { return }
//            print(privateKey)
//            self.importWalletWith(privateKey: privateKey)
//
//        }
//        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
//        alert.addAction(mnemonicsAction)
//        alert.addAction(privateKeyAction)
//        alert.addAction(cancelAction)
////        self.present(alert, animated: true, completion: nil)
//    }

    func importWalletWith(privateKey: String) {
        let formattedKey = privateKey.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let dataKey = Data.fromHex(formattedKey) else {
            self.showAlertMessage(title: "Error", message: "Please enter a valid Private key ", actionName: "Ok")
            return
        }

        guard let keystore = try? EthereumKeystoreV3(privateKey: dataKey) else {
            print("error creating keyStrore")
            print("Private key error.")
            let alert = UIAlertController(title: "Error", message: "Please enter correct Private key", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .destructive)
            alert.addAction(okAction)
            return
        }

        let manager = KeystoreManager([keystore])
        let walletAddress = manager.addresses?.first?.address
//                self.walletAddressLabel.text = walletAddress ?? "0x"
    }

    func importWalletWith(_ mnemonics: String) -> String {
        let walletAddress = try? BIP32Keystore(mnemonics: mnemonics , prefixPath: "m/44'/77777'/0'/0")
        print(walletAddress?.addresses as Any)
        return "\(walletAddress?.addresses?.first?.address ?? "0x")"
    }

    func showAlertMessage(title: String = "MyWeb3Wallet", message: String = "Message is empty", actionName: String = "OK") {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction.init(title: actionName, style: .destructive)
        alertController.addAction(action)
//        self.present(alertController, animated: true)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(_walletAddress: "0x")
    }
}
