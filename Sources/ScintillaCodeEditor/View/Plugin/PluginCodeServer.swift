// FoxTerm | PluginCodeServer.swift
// Copyright (c) 2025-2026 foxterm.app
// Created by foxterm@foxmail.com

// import Foundation
// import Scintilla
//
// class PluginCodeServer: PluginDelegate {
//    private var connectionToService: NSXPCConnection?
//    func setup(_: some CodeView) {
//        connectionToService = NSXPCConnection(serviceName: "cn.runecode.LSPClient")
//        connectionToService?.remoteObjectInterface = NSXPCInterface(with: (any LSPClientProtocol).self)
//        connectionToService?.resume()
//        test()
//    }
//
//    func setupTheme(_: some CodeView) {
//        // 主题设置变更时不需要特殊处理
//    }
//
//    func notification(_: some CodeView, _: UnsafeMutablePointer<SCNotification>?) {
//        // service?.notification(view, notification)
//    }
//
//    func notify(_: some CodeView, _: NotificationType, message _: String, location _: NSPoint, value _: Float) {}
//
//    func test() {
//        if let proxy {
//            proxy.performCalculation(firstNumber: 23, secondNumber: 19) { result in
//                NSLog("😯Result of calculation is: \(result)")
//            }
//        }
//    }
//
//    var proxy: LSPClientProtocol? {
//        guard let connectionToService else {
//            return nil
//        }
//
//        // Return the connection's remote object proxy
//        return connectionToService.remoteObjectProxyWithErrorHandler { err in
//            print(err)
//        } as? LSPClientProtocol
//    }
//
//    deinit {
//        connectionToService?.invalidate()
//    }
// }
//
// @objc protocol LSPClientProtocol {
//    func run() async
//
//    /// Replace the API of this protocol with an API appropriate to the service you are vending.
//    func performCalculation(firstNumber: Int, secondNumber: Int, with reply: @escaping (Int) -> Void)
// }
