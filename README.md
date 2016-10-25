# swift-executor
A lightweight simple implementation of Foundation's Concurrent Operation

##Introduction
Leverages ``` Operation ``` & ``` OperationQueue ```.  ``` AsyncOperation ``` is a ```concurrent operation``` that generates the appropriate ```KVO``` notifications as required by a concurrent ```Operation``` subclass.

####Additional Reading:
######Concurrency Programming Guide:

######Operation Class Reference:

##Supported Platforms:
```macOS``` ```iOS``` ```tvOS``` ```watchOS``` ```linux```
##Installation:

***Swift Package Manager:***

add to your ```Package.swift```:

```
Package swift code here:
```
***Carthage:***

Add to your ```Cartfile```

```
github "dcilia/swift-executor"
```


***CocoaPods***

What youre using cocoapods?

##How to use:

The main class to use is ```AsyncOperation```:

```
class Foo : AsyncOperation {
    
    var bar: String = "Hello World"
    
    override func execute() {
        super.execute()
        
        //Some long running task (or not).
        bar = String(bar.characters.reversed())
        
        //Call finish when done
        finish()
    }
}

```

then ...

```
var p = Foo(identifier: "com.your.bundle.id")
p.completionBlock = {
    print("I am a completion block")
}
```

create an observer for your ```AsyncOperation``` ...

```
struct FooObserver : ExecutorObserver {
    
    func did<Foo>(start operation: Foo) {
        dump(self)
        print(#function)
    }
    
    func did<Foo>(cancel operation: Foo) {
        dump(self)
        print(#function)
    }
    
    func did<Foo>(finish operation: Foo) {
        dump(self)
        print(#function)
    }
    
    func did<Foo>(becomeReady operation: Foo) {
        dump(self)
        print(#function)
    }
}
```
Note that we set the generic constraint parameter to use our concrete ```AyncOperation``` subclass. ``` did<Foo>...```

```
let observer = FooObserver()
p.add(observer: observer)
```
the ```add<T : ExecutorObserver> ... ``` function adds an observer to the array of ```ExecutorObserver``` in the ```AsyncOperation```.  This allows you to have multiple observers to an operation.

```
let first = FooObserver() //observer that is a class
let second = Barz() //observer that is a struct
p.add(observer: observer)
p.add(observer: two)
```
You can continue to use the normal properties of ```Operation``` to manage state:
```isReady``` ```isExecuting``` ```isCancelled```

you can also use the default properties of ```Operation```

Lastly, to finally execute your operation simply follow the accepted pattern of ```Operation``` & ```OperationQueue```

```
let queue = OperationQueue()
queue.name = "com.someQueue"
queue.addOperation(operation)
```
   
