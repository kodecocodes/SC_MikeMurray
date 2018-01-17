/// Copyright (c) 2017 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.
/*:
 # Protocol Oriented Programming in Swift
 ---
 Protocol Oriented Programming, or POP, is a new paradigm introduced during the Protocol-Oriented Programming in Swift talk at WWDC 2015. It is commonly thought of as an alternative to OOP so it may seem like a completely different way of solving problems using Swift. I'm not sure that is the case, in fact I think it may be more productive to think of it as Protocol Oriented Object Oriented Programming. Although I'm not convinced that POOOP will catch on :]
 
 In POP we still use many of the same pillars of OOP that we already know
 * Abstraction - In POP we will default to using protocols and structs/enums over classes to create our abstractions
 * Encapsulation - In POP we still use access levels, source files, and modules to decide what to expose in the APIS of our objects
 * Inheritance - When using protocols we tend not to think of inheriting from them, we would normally say that we adopt, or conform to, a protocol
 * Polymorphism - We still get to harness Polymorphism when using protocols
 
 Before we get started, I'd just like to quickly make a point. Remember that POP is not the silver bullet to address all our problems in Swift development, it is very easy to POP on your protocol oriented glasses (pun intended) and all of a sudden everything looks like a nail. POP can be the simpler, more flexible alternative to a class heirarchy but there may also be an even simpler solution to your problem than using protocols. Rob Napier gave a brilliant talk on this topic, I'd highly recommend giving it a watch [here](https://www.dotconferences.com/2016/01/rob-napier-beyond-crusty-real-world-protocols).
 */
/*:
 ### Modeling Abstract Entities
 ---
 First up on our tour of POP, a horribly named title! What I mean by abstract entity is an object that wouldn't make any sense to have an instance of, and that serves only to declare common functionality amongst a group of related objects.
 
 `Animal` would be a great example, we wouldn't want to have an instance of an abstract concept like Animal, we would need a concrete instance like Dog, Cat, or Mouse.
 Here's what that might look like if we created it using OOP and classes
 */
class OldAndBustedAnimal {
    
    var isInvertebrate = true
    
    func speak() -> String {
        preconditionFailure("Implement me!")
    }
}

class OldAndBustedDog: OldAndBustedAnimal {
    
    override init() {
        super.init()
        self.isInvertebrate = false
    }
    
    override func speak() -> String {
        return "Woof!"
    }
}
/*:
 So, quite a few problems here, let's do a quick post mortem.
 
 1. Stored properties in classes need a default value, so we need to initialise the `isInvertebrate` property with a value. An `Animal` is neither a vertebrate, nor an invertebrate, a specialization (subclass) of `Animal` is either a vertebrate or an invertebrate. We've introduced a small lie into our `Animal` class by saying that all `Animal`s are invertebrates. This might be slightly confusing for anyone writing a subclass of `Animal`, if it is an invertebrate do we stil assign true to the `isInvertebrate` property?
 2. No compile time safety for functions which trap and must be overriden, if we forget to provide an overriden implementation of the `speak` function then the app will crash if in a release build.
 3. Superclass initializer burden and maintaining invariants, it is not immediatetly obvious when to call the superclass initialiser, if at all. Do we do it before initializing `OldAndBustedDog`, or after? Are there any properties we need to set manually that aren't set in the superclass initializer?
 
 It just feels a little bit hacky, we are able to create instances of `Animal` and therefore we must provide default values to properties and method bodies to our methods. In C# or Java we would use abstract/virtual classes and methods. In Swift, we use protocols.
 */
protocol NewHotnessAnimal {
    
    var isInvertebrate: Bool { get }
    
    func speak() -> String
}

class NewHotnessDog: NewHotnessAnimal {
    
    var isInvertebrate = false
    
    func speak() -> String {
        return "Woof!"
    }
}
/*:
 Much better! Protocols can be thought of as a blueprint, or a contract, that an adopting object must abide by. So we don't need an initial value for `isInvertebrate`, and we don't need to write the method body for `speak`!
 */
/*:
 ### Multiple inheritance
 ---
 Using classes and inheritance in Swift locks you to only being able to have one superclass, which can lead to some problems. Let's continue our `Animal` trend with an example.
 */
class OldAndBustedHorse: OldAndBustedAnimal {
    
    override init() {
        super.init()
        self.isInvertebrate = false
    }
    
    override func speak() -> String {
        return "Neigh!"
    }
}
/*:
 OK, cool, we now have a horse object. What if we were writing a game, set in the wild west say, where a horse is both an `Animal` and also a mode of transportation? Where would we put the functionality to make our `OldAndBustedHorse` a mode of transport? It wouldn't make any sense to add it to the superclass, as all animals are not modes of transport. We wouldn't just add it to the `OldAndBustedHorse` class as there may well be more than one kind of mode of transport in the game. Once again, protocols come to the rescue, with a splash of retroactive modeling.
 */
protocol ModeOfTransport {
    func transport()
}

extension OldAndBustedHorse: ModeOfTransport {
    func transport() {
        // Implement transportation here
    }
}
/*:
 Our `OldAndBustedHorse` can now be used as a mode of transport! We could have changed the superclass to a protocol and done it that way, but sometimes you may have a class heirarchy that needs to stay that way. Whilst classes cannot inherit from more than one superclass, there is nothing stopping you from inheriting from a superclass and also adopting a protocol. Protocols allow you to augment these objects with extra behaviour without altering the original implementation, this is called retroactive modeling.
 */
/*:
 ### Naming conventions
 ---
 Up until this point we haven't really followed any sort of naming conventions for our protocols, we should really be following the Swift API design guidelines, which state
 * Protocols that describe what something is should read as nouns (e.g. Collection).
 * Protocols that describe a capability should be named using suffixes able, ible, or ing (e.g. Equatable, ProgressReporting)
 */
/*:
 ### Value types
 ---
 Protocols support values types (structs and enums). Value types are a large part of POP, we prefer to use structs and value semantics over classes and reference semantics/implicit sharing. Let's look at an example of why implicit sharing can sometimes cause headaches.
 */
class Pet {
    var name = ""
    
    func willReturnWhenCalled(by name: String) -> Bool {
        if name == self.name {
            // Return to owner
            return true
        } else {
            // Go on an adventure!
            return false
        }
    }
}

class PetDog: Pet {
    override init() {
        super.init()
        self.name = "Fido"
    }
}

let myDog = PetDog()

// If we pass the reference to myDog to another part of our application, a background process perhaps, and a mutation is applied to our dog
let myOtherDog = myDog
myOtherDog.name = "Steve"

// Later we go to call on our pet
myDog.willReturnWhenCalled(by: "Fido") // Returns false, Steve embarks on an adventure, never to be seen again! (he'll probably be back by dinner time)
/*:
 Implicit sharing can sometimes cause problems, in this scenario a dog owner can no longer get their beloved pet to respond to them! As `PetDog` is a reference type, we only have the pointer to where the `PetDog` lives on the heap, so someone else can point to our same `PetDog`, mutate it, and then when we come back later to take our `PetDog` a walk and then call on it to come home it completely ignores us as its name has changed. If we were using value types we wouldn't have had this problem. Bear in mind this is a very small example of the types of issues reference semantics can bring to the table, and the benefits of value types. If I were to summarize I think I would always default to value types, and only use classes if I needed reference semantics. That way implicit sharing won't unexpectedly sneak up on you.
 
 Just to note, this isn't the best example in the world for the benefit of value types but the point we're trying to drive home here is that it makes no sense for an instance of `PetDog` to mutate, if we had our dog on a leash (have a reference to it) it makes no sense for it to suddenly change color or breed. Apply this thinking when creating abstractions for your models, you'll be surprised that when you start defaulting to structs instead of classes you realise how little you need reference semantics.
 */
/*:
 ### Using Self in protocols
 ---
 You might have seen the `Self` keyword in some protocols you have come across. The `Self` keyword is essentially a typealias for the type of object adopting the protocol. Let's take a look at an example.
 */
protocol Hero {
    func assemble(with heroes: [Self])
    func saveTheWorld()
}

final class Avenger: Hero {
    func assemble(with heroes: [Avenger]) {
        // Avengers assemble!
    }
    
    func saveTheWorld() {
        // Beat the bad guys
    }
}
/*:
 Pretty cool, right? We can also use the `Self` typealias as a generic constraint in protocol extensions, let's take a look at how that might work.
 */
extension Hero where Self: Avenger {
    func assemble(with heroes: [Avenger]) {
        // Avengers assemble!
    }
}
/*:
 We now get the `assemble(with:)` function for free in our `Avenger` class! A few things to note here.
 * `Avenger` cannot be a struct, from the Swift programming guide: "the requirements in a where clause specify that a type parameter inherits from a class or conforms to a protocol or protocol composition."
 * We need to mark the class as final because any subclasses will not be able to fulfil the `Self` requirement. There are workarounds but we will not be covering them here.
 */
/*:
 ### Protocols with Associated Types (PATs)
 ---
 Let's say we've been tasked with writing the persistence service for an application, and we would like to ensure that any dependency to our database solution of choice doesn't leak out into the rest of the application. So we decide to write a `CRUD` protocol to abstract away our implementation of the persistence service.
 */
import Foundation

protocol CRUD {
    
    associatedtype Model
    
    func create(newModel model: Model)
    func read(filter: NSPredicate?) -> [Model]
    func update(predicate: NSPredicate, newModel: Model)
    func delete(predicate: NSPredicate)
}
/*:
 We are making use of `associatedtype`, which in a nutshell enables us to use generics in our protocols. An `associatedtype` is essentially a `typealias` that we provide in any objects which adopt the `CRUD` protocol, let's take a look at an implementation of our protocol.
 */
class InMemoryPersistenceService<ModelType>: CRUD {
    
    typealias Model = ModelType
    
    var inMemoryStore = [Model]()
    
    func create(newModel model: Model) {
        inMemoryStore.append(model)
    }
    
    func read(filter: NSPredicate?) -> [Model] {
        guard let filter = filter else {
            return inMemoryStore
        }
        
        return inMemoryStore.filter { filter.evaluate(with: $0) }
    }
    
    func update(predicate: NSPredicate, newModel: Model) {
        var updatedStore = inMemoryStore.filter { !(predicate.evaluate(with: $0)) }
        updatedStore.append(newModel)
        inMemoryStore = updatedStore
    }
    
    func delete(predicate: NSPredicate) {
        inMemoryStore = inMemoryStore.filter { !(predicate.evaluate(with: $0)) }
    }
}
/*:
 
 So, in order to not be coupled with a particular implementation of `CRUD` we'd best make the type of our reference to the persistence service of type `CRUD`. We actually get an error message when we try to do just that:
 ```
 let persistenceService: CRUD <- Protocol 'CRUD' can only be used as a generic constraint because it has Self or associated type requirements
 ```
 We don't get dynamic dispatch in PATs, so we need to know what the associated type in `CRUD` is at compile time. The technique to achieve this is called Type Erasure, let's take a look at an example.
 */
struct AnyCRUD<ModelType>: CRUD {
    
    typealias Model = ModelType
    
    private let _create: (Model) -> ()
    private let _read: (NSPredicate?) -> [Model]
    private let _update: (NSPredicate, Model) -> ()
    private let _delete: (NSPredicate) -> ()
    
    init<U: CRUD>(_ base: U) where U.Model == ModelType {
        _create = base.create
        _read = base.read
        _update = base.update
        _delete = base.delete
    }
    
    func create(newModel model: Model) {
        return _create(model)
    }
    
    func read(filter: NSPredicate?) -> [Model] {
        return _read(filter)
    }
    
    func update(predicate: NSPredicate, newModel: Model) {
        return _update(predicate, newModel)
    }
    
    func delete(predicate: NSPredicate) {
        return _delete(predicate)
    }
}
/*:
 There's quite a lot going on here, essentially what we are doing is wrapping around a 'base' implementation of `CRUD` and we forward all method calls to the underlying base implementation. In the initialiser we are constraining the associated type of the `CRUD` implementation to one of our choosing, giving us the compile time safety we were looking for. So now we set the type of our reference to the persistence service to:
 */
let persistenceService: AnyCRUD<Data> = AnyCRUD(InMemoryPersistenceService<Data>())
