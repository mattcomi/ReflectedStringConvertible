//  Copyright © 2016 Matt Comi. All rights reserved.

public protocol ReflectedStringConvertible : CustomStringConvertible { }

extension ReflectedStringConvertible {
  public var description: String {
    let mirror = Mirror(reflecting: self)
    
    let children: [String] = mirror.children.flatMap { (label, value) in
      if let label = label {
        return "\(label): \(value)"
      }
      
      return nil
    }
  
    return "\(mirror.subjectType)(\(children.joinWithSeparator(", ")))"
  }
}
