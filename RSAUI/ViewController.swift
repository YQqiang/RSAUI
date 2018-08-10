//
//  ViewController.swift
//  RSAUI
//
//  Created by sungrow on 2018/8/9.
//  Copyright © 2018年 sungrow. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    @IBOutlet weak var fileDragDropView: YQDragDropView!
    @IBOutlet weak var publicDragDropView: YQDragDropView!
    @IBOutlet weak var privateDragDropView: YQDragDropView!
    @IBOutlet weak var inputPasswordTF: NSTextField!
    
    var fileModel: YQFileModel?
    var publicFileModel: YQFileModel?
    var privateFileModel: YQFileModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fileDragDropView.delegate = self
        publicDragDropView.delegate = self
        privateDragDropView.delegate = self
    }
    
    @IBAction func lock(_ sender: NSButton) {
        encrypt()
    }
    
    @IBAction func unlock(_ sender: NSButton) {
        decrypt()
    }
}

// MARK: - encrypt and decrypt
extension ViewController {
    fileprivate func encrypt() {
        configDefaultDragTextColor()
        guard let fileM = fileModel else {
            fileDragDropView.textColor = NSColor.red
            showAlert("请选择待加密文件")
            return;
        }
        guard let publicFileM = publicFileModel else {
            publicDragDropView.textColor = NSColor.red
            showAlert("请选择公钥文件")
            return;
        }
        let filePath = fileM.filePath
        let derFilePath = publicFileM.filePath
        let file = RSA.encryptString((try? String.init(contentsOfFile: filePath)), publicKeyWithContentsOfFile: derFilePath)
        if let file = file, !file.isEmpty {
            try? file.write(toFile: filePath, atomically: true, encoding: .utf8)
            showAlert("加密成功")
        } else {
            showAlert("加密失败")
        }
    }
    
    fileprivate func decrypt() {
        guard let fileM = fileModel else {
            fileDragDropView.textColor = NSColor.red
            showAlert("请选择待加密文件")
            return;
        }
        guard let privateFileM = privateFileModel else {
            privateDragDropView.textColor = NSColor.red
            showAlert("请选择私钥文件")
            return;
        }
        let filePath = fileM.filePath
        let p12FilePath = privateFileM.filePath
        let password = inputPasswordTF.stringValue
        let file = RSA.decryptString((try? String.init(contentsOfFile: filePath)), privateKeyWithContentsOfFile: p12FilePath, password: password)
        if let file = file, !file.isEmpty {
            try? file.write(toFile: filePath, atomically: true, encoding: .utf8)
            showAlert("加密成功")
        } else {
            showAlert("解密失败")
        }
    }
}

// MARK: - YQDragDropViewDelegate
extension ViewController: YQDragDropViewDelegate {
    func draggingFileAccept(_ dragDropView: YQDragDropView, files: [String]) {
        guard interceptDragDrop(dragDropView) else {
            return
        }
        if files.count > 1 {
            configDefaultDragText(dragDropView)
            return
        }
        let currentFileModel = YQFileModel(filePath: files.first!)
        dragDropView.text = currentFileModel.fileName
        
        if dragDropView == fileDragDropView {
            fileModel = currentFileModel
        } else if dragDropView == publicDragDropView {
            publicFileModel = currentFileModel
        } else if dragDropView == privateDragDropView {
            privateFileModel = currentFileModel
        }
    }
    
    func draggingEntered(_ dragDropView: YQDragDropView) {
        guard interceptDragDrop(dragDropView) else {
            return
        }
        dragDropView.text = "释放完成拖拽";
    }
    
    func draggingExited(_ dragDropView: YQDragDropView) {
        guard interceptDragDrop(dragDropView) else {
            return
        }
        configDefaultDragText(dragDropView)
    }
    
    fileprivate func configDefaultDragText(_ dragDropView: YQDragDropView) {
        if dragDropView == fileDragDropView {
            dragDropView.text = "拖拽待加密文件到这"
        } else if dragDropView == publicDragDropView {
            dragDropView.text = "拖拽加密公钥文件到这"
        } else if dragDropView == privateDragDropView {
            dragDropView.text = "拖拽解密私钥文件到这"
        }
    }
    
    fileprivate func configDefaultDragTextColor() {
        fileDragDropView.textColor = NSColor.darkGray
        publicDragDropView.textColor = NSColor.darkGray
        privateDragDropView.textColor = NSColor.darkGray
    }
    
    fileprivate func interceptDragDrop(_ dragDropView: YQDragDropView) -> Bool {
        configDefaultDragTextColor()
        if dragDropView == fileDragDropView {
            if let _ = fileModel {
                return false;
            }
        } else if dragDropView == publicDragDropView {
            if let _ = publicFileModel {
                return false;
            }
        } else if dragDropView == privateDragDropView {
            if let _ = privateFileModel {
                return false;
            }
        }
        return true
    }
    
    fileprivate func showAlert(_ message: String) {
        let alert = NSAlert()
        alert.addButton(withTitle: "确定")
        alert.messageText = message
        alert.alertStyle = .warning
        alert.beginSheetModal(for: view.window!, completionHandler: nil)
    }
}

