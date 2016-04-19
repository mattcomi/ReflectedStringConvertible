# ReflectedStringConvertible
A protocol that allows any class to be printed as if it were a struct.

Here is the problem:

```swift
class Person {
  var name: String
  var age: Int
  var social: Social
  
  init(name: String, age: Int, social: Social) {
    self.name = name
    self.age = age
    self.social = social
  }
}

let matt = Person(name: "Matt", age: 32, social: Social(twitter: "@mattcomi"))

print(matt)
```

Outputs:

```swift
Person
```

When outputting classes, if a string representation isn't provided, Swift uses Ad-Hoc printing. For classes, this means just the class name.

If `Person` were a struct however, we'd see something very different:

```swift
Person(name: "Matt", age: 32, social: Social(twitter: "@mattcomi"))
```

To get this kind of output from any class, just conform to `ReflectedStringConvertible`. There's nothing to implement, the implementation is provided by a protocol extension. 

```swift
class Person: ReflectedStringConvertible {
  var name: String
  var age: Int
  var social: Social
  
  init(name: String, age: Int, social: Social) {
    self.name = name
    self.age = age
    self.social = social
  }
}

let matt = Person(name: "Matt", age: 32, social: Social(twitter: "@mattcomi"))

print(matt)
```

Outputs:

```
Person(name: Matt, age: 32, social: Social(twitter: "@mattcomi"))
```

Just like a struct.
