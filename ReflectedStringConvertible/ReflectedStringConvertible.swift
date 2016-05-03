//  Copyright © 2016 Matt Comi. All rights reserved.

import Foundation

/// Indicates that a type can be safely included in a JSON object without being converted to a string. In other words, 
/// it may appear as a value without being quoted.
public protocol JSONConvertible {}

extension Double: JSONConvertible {}
extension Float: JSONConvertible {}
extension Bool: JSONConvertible {}
extension Int: JSONConvertible {}
extension UInt: JSONConvertible {}

func jsonConvertibleObject<T>(value: T) -> AnyObject {
  if case let reflectedStringConvertible as ReflectedStringConvertible = value {
    // handle ReflectedStringConvertibles recursively.
    return reflectedStringConvertible.dictionary(Mirror(reflecting: reflectedStringConvertible).allChildren)
  } else if value is JSONConvertible {
    let anyObject = value as! AnyObject
    return anyObject
  } else if case let collection as JSONConvertibleCollection = value {
    return collection.jsonConvertibleObjects
  } else if case let dictionaryValue as JSONConvertibleDictionary = value {
    return dictionaryValue.jsonConvertibleElements
  } else {
    return String(value)
  }
}

protocol JSONConvertibleCollection {
  var jsonConvertibleObjects: [AnyObject] { get }
}

protocol JSONConvertibleDictionary {
  var jsonConvertibleElements: [String:AnyObject] { get }
}

extension Array: JSONConvertibleCollection {
  var jsonConvertibleObjects: [AnyObject] {
    return self.map { jsonConvertibleObject($0) }
  }
}

extension Set: JSONConvertibleCollection {
  var jsonConvertibleObjects: [AnyObject] {
    return self.map { jsonConvertibleObject($0) }
  }
}

extension Dictionary: JSONConvertibleDictionary {
  var jsonConvertibleElements: [String:AnyObject] {
    var dict: [String: AnyObject] = [:]
    for (key, value) in self {
      dict[String(key)] = jsonConvertibleObject(value)
    }
    
    return dict
  }
}

/// A protocol that extends CustomStringConvertible to add a detailed textual representation to any class.
///
/// Two styles are supported:
/// - `Normal`: Similar to Swift's default textual representation of structs.
/// - `JSON`: Pretty JSON representation.
public protocol ReflectedStringConvertible : CustomStringConvertible { }

/// The textual representation style.
public enum Style {
  /// Similar to the default textual representation of structs.
  case Normal
  /// Pretty JSON style.
  case JSON
}

extension ReflectedStringConvertible {
  /// A detailed textual representation of `self`.
  ///
  /// - parameter style: The style of the textual representation.
  public func reflectedDescription(style: Style) -> String {
    switch style {
    case .Normal:
      return self.description
    case .JSON:
      return self.jsonDescription
    }
  }
  
  /// A `Normal` style detailed textual representation of `self`. This is the same as calling
  /// `reflectedDescription(.Normal)`
  public var description: String {
    let mirror = Mirror(reflecting: self)
    
    let descriptions: [String] = mirror.allChildren.flatMap { (label: String?, value: Any) in
      if let label = label {
        var value = value
        if value is String {
          value = "\"\(value)\""
        }
        return "\(label): \(value)"
      }
      
      return nil
    }
    
    return "\(mirror.subjectType)(\(descriptions.joinWithSeparator(", ")))"
  }
  
  /// A `JSON` style detailed textual representation of `self`.
  private var jsonDescription: String {
    let dictionary = self.dictionary(Mirror(reflecting: self).allChildren)
    let data = try! NSJSONSerialization.dataWithJSONObject(dictionary, options: .PrettyPrinted)
    return String(data: data, encoding: NSUTF8StringEncoding)!
  }
  
  /// A dictionary representation of a `Mirror`'s children. Any child that conforms to `ReflectedStringConvertible` is
  /// handled recursively.
  private func dictionary(children: [Mirror.Child]) -> [String:AnyObject] {
    var dictionary: [String:AnyObject] = [:]
    
    for child in children {
      if let label = child.label {
        dictionary[label] = jsonConvertibleObject(child.value)
      }
    }
    
    return dictionary
  }
}

extension Mirror {
  /// The children of the mirror and its superclasses.
  var allChildren: [Mirror.Child] {
    var children = Array(self.children)
    
    var superclassMirror = self.superclassMirror()
    
    while let mirror = superclassMirror {
      children.appendContentsOf(mirror.children)
      superclassMirror = mirror.superclassMirror()
    }
    
    return children
  }
}