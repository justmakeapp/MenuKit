//
//  MenuElementCreator.swift
//
//
//  Created by longvu on 24/5/24.
//

import Foundation
#if os(iOS)
    import UIKit
#endif

#if os(macOS)
    import AppKit
#endif

public enum MenuElementHandler {
    #if os(iOS)
        case action(UIActionHandler)
        case selector(Selector)
    #endif
    #if os(macOS)
        case selector(Selector?)
    #endif
}

public protocol MenuElementType: RawRepresentable {}

public protocol MenuElement {
    associatedtype ElementType: MenuElementType
    var type: ElementType { get set }
    var handler: MenuElementHandler { get set }
    var title: String { get }
    #if os(iOS)
        var image: UIImage? { get }
        var identifier: UIAction.Identifier? { get }
        var discoverabilityTitle: String? { get }
        var attributes: UIMenuElement.Attributes { get set }
        var modifierFlags: UIKeyModifierFlags { get }
        var wantsPriorityOverSystemBehavior: Bool { get }
    #endif

    #if os(macOS)
        var keyEquivalentModifierMask: NSEvent.ModifierFlags { get }
    #endif

    var input: String { get }
}

public protocol MenuElementCreator {
    associatedtype Element: MenuElement
    var menuElement: Element { get set }
    func makeMenuElement() -> PlatformMenuElement?
}

public extension MenuElementCreator {
    func makeMenuElement() -> PlatformMenuElement? {
        switch menuElement.handler {
        #if os(iOS)
            case let .action(handler):
                return UIAction(
                    title: menuElement.title,
                    image: menuElement.image,
                    identifier: menuElement.identifier,
                    discoverabilityTitle: menuElement.discoverabilityTitle,
                    attributes: menuElement.attributes,
                    handler: handler
                )
        #endif

        case let .selector(selector):
            #if os(macOS)
                let menuItem = NSMenuItem(
                    title: menuElement.title,
                    action: selector,
                    keyEquivalent: menuElement.input
                )
                menuItem.keyEquivalentModifierMask = menuElement.keyEquivalentModifierMask
                return menuItem
            #endif

            #if os(iOS)
                let keyCmd = UIKeyCommand(
                    title: menuElement.title,
                    image: menuElement.image,
                    action: selector,
                    input: menuElement.input,
                    modifierFlags: menuElement.modifierFlags,
                    propertyList: menuElement.type.rawValue,
                    discoverabilityTitle: menuElement.discoverabilityTitle,
                    attributes: menuElement.attributes
                )
                if #available(iOS 15.0, *) {
                    keyCmd.wantsPriorityOverSystemBehavior = menuElement.wantsPriorityOverSystemBehavior
                }
                return keyCmd
            #endif
        }
    }
}

public struct AnyMenuElementCreator<M: MenuElement>: MenuElementCreator {
    public var menuElement: M

    public init(menuElement: M) {
        self.menuElement = menuElement
    }
}
