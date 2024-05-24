//
//  MenuCreator.swift
//
//  Created by Long Vu on 06/12/2022.
//

#if os(iOS)
    import UIKit

    public typealias PlatformMenu = UIMenu
    public typealias PlatformMenuElement = UIMenuElement
#endif

#if os(macOS)
    import AppKit

    public typealias PlatformMenu = NSMenu
    public typealias PlatformMenuElement = NSMenuItem
#endif

public protocol MenuCreator {
    func makeMenu() -> PlatformMenu
    func makeChildren() -> [PlatformMenuElement]
}
