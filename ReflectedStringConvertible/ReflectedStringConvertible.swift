// Copyright © 2016 Matt Comi. All rights reserved.

import Foundation

/// Indicates that a type can be safely included in a JSON object without being converted to a string. In other words, 
/// it may appear as a value without being quoted.
public protocol JSONConvertible {}

extension Double: JSONConvertible {}
extension Float: JSONConvertible {}
extension Bool: JSONConvertible {}
extension Int: JSONConvertible {}
extension UInt: JSONConvertible {}

func jsonConvertibleObject<T>(_ value: T) -> Any {
  if case let reflectedStringConvertible as ReflectedStringConvertible = value {
    // handle ReflectedStringConvertibles recursively.
    return reflectedStringConvertible.dictionary(Mirror(reflecting: reflectedStringConvertible).allChildren)
  } else if value is JSONConvertible {
    let anyObject = value
    return anyObject
  } else if case let collection as JSONConvertibleCollection = value {
    return collection.jsonConvertibleObjects
  } else if case let dictionaryValue as JSONConvertibleDictionary = value {
    return dictionaryValue.jsonConvertibleElements
  } else {
    return String(describing: value)
  }
}

protocol JSONConvertibleCollection {
  var jsonConvertibleObjects: [Any] { get }
}

protocol JSONConvertibleDictionary {
  var jsonConvertibleElements: [String: Any] { get }
}

extension Array: JSONConvertibleCollection {
  var jsonConvertibleObjects: [Any] {
    return self.map { jsonConvertibleObject($0) }
  }
}

extension Set: JSONConvertibleCollection {
  var jsonConvertibleObjects: [Any] {
    return self.map { jsonConvertibleObject($0) }
  }
}

extension Dictionary: JSONConvertibleDictionary {
  var jsonConvertibleElements: [String: Any] {
    var dict: [String: Any] = [:]
    for (key, value) in self {
      dict[String(describing: key)] = jsonConvertibleObject(value)
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
  case normal
  /// Pretty JSON style.
  case json
}

extension ReflectedStringConvertible {
  /// A detailed textual representation of `self`.
  ///
  /// - parameter style: The style of the textual representation.
  public func reflectedDescription(_ style: Style) -> String {
    switch style {
    case .normal:
      return self.description
    case .json:
      return self.jsonDescription
    }
  }
  
  /// A `Normal` style detailed textual representation of `self`. This is the same as calling
  /// `reflectedDescription(.normal)`
  public var description: String {
    let mirror = Mirror(reflecting: self)

    let descriptions: [String] = mirror
      .allChildren
      .sorted {
        $0.label ?? "" < $1.label ?? ""
      }
      .compactMap { (label: String?, value: Any) in
        if let label = label {
          var value = value

          if value is String {
            value = "\"\(value)\""
          }
        
          return "\(label): \(value)"
        }
      
        return nil
      }
    
    return "\(mirror.subjectType)(\(descriptions.joined(separator: ", ")))"
  }
  
  /// A `JSON` style detailed textual representation of `self`.
  fileprivate var jsonDescription: String {
    let dictionary = self.dictionary(Mirror(reflecting: self).allChildren)
    var jsonOptions: JSONSerialization.WritingOptions = [.prettyPrinted]
    if #available(iOS 11.0, *) {
        jsonOptions = [.prettyPrinted, .sortedKeys]
    }
    let data = try! JSONSerialization.data(withJSONObject: dictionary, options: jsonOptions)
    return String(data: data, encoding: String.Encoding.utf8)!
  }
  
  /// A dictionary representation of a `Mirror`'s children. Any child that conforms to `ReflectedStringConvertible` is
  /// handled recursively.
  fileprivate func dictionary(_ children: [Mirror.Child]) -> [String: Any] {
    var dictionary: [String: Any] = [:]
    
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
    
    var superclassMirror = self.superclassMirror
    
    while let mirror = superclassMirror {
      children.append(contentsOf: mirror.children)
      superclassMirror = mirror.superclassMirror
    }
    
    return children
  }
}
