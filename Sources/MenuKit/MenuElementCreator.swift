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
    var title: String { get }
    #if os(iOS)
        var image: UIImage? { get }
    #endif

    #if os(macOS)
        var keyEquivalentModifierMask: NSEvent.ModifierFlags { get }
    #endif
}

public protocol AbstractSingleMenuElement: MenuElement {
    var handler: MenuElementHandler { get set }
    #if os(iOS)
        var identifier: UIAction.Identifier? { get }
        var discoverabilityTitle: String? { get }
        var attributes: UIMenuElement.Attributes { get set }
        var modifierFlags: UIKeyModifierFlags { get }
        var wantsPriorityOverSystemBehavior: Bool { get }
    #endif

    var input: String { get }
}

public protocol AbstractSubMenuElement: MenuElement {
    #if os(iOS)

        @available(iOS 16.0, *)
        var subtitle: String? { get set }

        var identifier: UIMenu.Identifier? { get }
        var options: UIMenu.Options { get set }

        @available(iOS 16.0, *)
        var preferredElementSize: UIMenu.ElementSize { get set }

        var children: [any MenuElement] { get set }
    #endif
}

public protocol MenuElementCreator {
    var menuElement: any MenuElement { get set }
    func makeMenuElement() -> PlatformMenuElement?
}

public extension MenuElementCreator {
    private static func makeChildren(_ children: [any MenuElement]) -> [PlatformMenuElement] {
        var results = children.compactMap { element in
            let creator = AnyMenuElementCreator(menuElement: element)
            return creator.makeMenuElement()
        }

        #if targetEnvironment(macCatalyst)
            results = results.reversed()
        #endif

        return results
    }

    func makeMenuElement() -> PlatformMenuElement? {
        if let element = menuElement as? any AbstractSubMenuElement {
            #if os(iOS)
                if #available(iOS 16.0, *) {
                    return UIMenu(
                        title: element.title,
                        subtitle: element.subtitle,
                        image: element.image,
                        identifier: element.identifier,
                        options: element.options,
                        preferredElementSize: element.preferredElementSize,
                        children: Self.makeChildren(element.children)
                    )
                } else {
                    return UIMenu(
                        title: element.title,
                        image: element.image,
                        identifier: element.identifier,
                        options: element.options,
                        children: Self.makeChildren(element.children)
                    )
                }
            #endif

            #if os(macOS)
                fatalError("Implement here")
            #endif
        }
        if let menuElement = menuElement as? any AbstractSingleMenuElement {
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
        return nil
    }
}

public struct AnyMenuElementCreator: MenuElementCreator {
    public var menuElement: any MenuElement

    public init(menuElement: any MenuElement) {
        self.menuElement = menuElement
    }
}
