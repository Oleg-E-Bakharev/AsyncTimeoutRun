//
//  Copyright (C) Oleg Bakharev 2021. All Rights Reserved
//

import Foundation
import AppKit

/**
    Данный код обобщенным образом реализует решение следующей задачи:
 Имеется функция или метод класса, который выполняется асинхронно и уведомляет о завершении (или возвращает значение) вызовом каллбэка.
 Требуется ограничить по времени выполнение данной функции.

 Если выполнение асинхронной функции(метода) завершается раньше чем таймаут, то каллбэк вызывается штатным образом.
 Если наступает таймаут выполнения, то каллбэк вызывается принудительно с указанием причины вызова по таймауту.

 Опционально можно выставить флаг waitAfterTimeout ожидания сверх таймаута. При этом если наступит таймаут до завершения функции, то каллбэк вызовется
 первый раз с указанием вызова по таймауту, а при завершении выполнения функции(метода) каллбэк вызовется второй раз с результатом выполнения функции.
 В противном случае, вызов каллбэка будет один раз с результатом функции.
 По умолчанию waitAfterTimeout - false.

 Опционально можно указать очередь на которой будет осуществляться уведомление о завершении (не выполнение) функции. По умолчанию - main.

 // Тестовые функция:
 func testFunction(completion: @escaping ()->Void) {
     DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
         completion()
     }
 }

 func testFunction1(completion: @escaping (Int)->Void) {
     DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
         completion(1)
     }
 }

 // Тестовый класс
 final class Test {
     func testMethod(completion: @escaping ()->Void) {
         DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
             completion()
         }
     }

     func testMethod1(completion: @escaping (Int)->Void) {
         DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
             completion(1)
         }
     }
 }
 let test = Test();
 */

/**
 Пример:
 async(timeout: 0.5, run: testFunction) { success in
    print("test_1 0.5: \(success)")
 }
 */
public func async(
    timeout: TimeInterval,
    run closure: (@escaping ()->Void)->Void,
    waitAfterTimeout: Bool = false,
    queue: DispatchQueue = DispatchQueue.main,
    completion: @escaping (Bool)->Void
) {
    var completion: ((Bool)->Void)? = completion
    closure {
        queue.async {
            completion?(true)
            completion = nil
        }
    }
    queue.asyncAfter(deadline: .now() + timeout) {
        completion?(false)
        if !waitAfterTimeout {
            completion = nil
        }
    }
}

/**
 Пример:
 async(timeout: 0.5, run: testFunction1) { success, result in
     print("test_5 0.5: \(success), result: \(String(describing: result))")
 }
 */
public func async<Target>(
    timeout: TimeInterval,
    on target: Target,
    run method: (Target)->(@escaping ()->Void)->Void,
    waitAfterTimeout: Bool = false,
    queue: DispatchQueue = DispatchQueue.main,
    completion: @escaping (Bool)->Void
) {
    var completion: ((Bool)->Void)? = completion
    method(target)() {
        queue.async {
            completion?(true)
            completion = nil
        }
    }
    queue.asyncAfter(deadline: .now() + timeout) {
        completion?(false)
        if !waitAfterTimeout {
            completion = nil
        }
    }
}

/**
 Пример:
 async(timeout: 0.5, run: testFunction1) { success, result in
     print("test_5 0.5: \(success), result: \(String(describing: result))")
 }
 */
public func async<Result>(
    timeout: TimeInterval,
    run function: (@escaping (Result)->Void)->Void,
    waitAfterTimeout: Bool = false,
    queue: DispatchQueue = DispatchQueue.main,
    completion: @escaping (Bool, Result?)->Void
)
{
    var completion: ((Bool, Result?)->Void)? = completion
    function { result in
        queue.async {
            completion?(true, result)
            completion = nil
        }
    }
    queue.asyncAfter(deadline: .now() + timeout) {
        completion?(false, nil)
        if !waitAfterTimeout {
            completion = nil
        }
    }
}

public func async<Parameter, Result>(
    timeout: TimeInterval,
    run function: (Parameter, @escaping (Result)->Void)->Void,
    with parameter: Parameter,
    waitAfterTimeout: Bool = false,
    queue: DispatchQueue = DispatchQueue.main,
    completion: @escaping (Bool, Result?)->Void
) {
    var completion: ((Bool, Result?)->Void)? = completion
    function(parameter) { result in
        queue.async {
            completion?(true, result)
            completion = nil
        }
    }
    queue.asyncAfter(deadline: .now() + timeout) {
        completion?(false, nil)
        if !waitAfterTimeout {
            completion = nil
        }
    }
}

public func async<Target, Parameter>(
    timeout: TimeInterval,
    on target: Target,
    run method: (Target)->(Parameter, @escaping ()->Void)->Void,
    with parameter: Parameter,
    waitAfterTimeout: Bool = false,
    queue: DispatchQueue = DispatchQueue.main,
    completion: @escaping (Bool)->Void
) {
    var completion: ((Bool)->Void)? = completion
    method(target)(parameter) {
        queue.async {
            completion?(true)
            completion = nil
        }
    }
    queue.asyncAfter(deadline: .now() + timeout) {
        completion?(false)
        if !waitAfterTimeout {
            completion = nil
        }
    }
}

/**
 Пример:
 async(timeout: 0.5, on: test, run: Test.testMethod1) { success, result in
     print("test_13 0.5: \(success), result: \(String(describing: result))")
 }
 */
public func async<Target, Result>(
    timeout: TimeInterval,
    on target: Target,
    run method: (Target)->(@escaping (Result)->Void)->Void,
    waitAfterTimeout: Bool = false,
    queue: DispatchQueue = DispatchQueue.main,
    completion: @escaping (Bool, Result?)->Void
) {
    var completion: ((Bool, Result?)->Void)? = completion
    method(target)() { result in
        queue.async {
            completion?(true, result)
            completion = nil
        }
    }
    queue.asyncAfter(deadline: .now() + timeout) {
        completion?(false, nil)
        if !waitAfterTimeout {
            completion = nil
        }
    }
}

public func async<Target, Parameter, Result>(
    timeout: TimeInterval,
    on target: Target,
    run method: (Target)->(Parameter, @escaping (Result)->Void)->Void,
    with parameter: Parameter,
    waitAfterTimeout: Bool = false,
    queue: DispatchQueue = DispatchQueue.main,
    completion: @escaping (Bool, Result?)->Void
) {
    var completion: ((Bool, Result?)->Void)? = completion
    method(target)(parameter) { result in
        queue.async {
            completion?(true, result)
            completion = nil
        }
    }
    queue.asyncAfter(deadline: .now() + timeout) {
        completion?(false, nil)
        if !waitAfterTimeout {
            completion = nil
        }
    }
}

/**
 Протокол для ограниченного по времени асинхронного выполнения. Имеется реализация по умолчанию.
 Класс, поддерживающий данный протокол должен быть помечен final

 // Пример использования
 extension Test: AsyncTimeoutRunnable {}

 test.async(timeout: 0.5, run: Test.testMethod) { success in
     print("test_17 0.5: \(success)")
 }

 test.async(timeout: 0.5, run: Test.testMethod1) { success, result in
     print("test_21 0.5: \(success), result: \(String(describing: result))")
 }
 */
public protocol AsyncTimeoutRunnable {
    func async(
        timeout: TimeInterval,
        run method: (Self)->(@escaping ()->Void)->Void,
        waitAfterTimeout: Bool,
        queue: DispatchQueue,
        completion: @escaping (Bool)->Void
    )

    func async<Result>(
        timeout: TimeInterval,
        run method: (Self)->(@escaping (Result)->Void)->Void,
        waitAfterTimeout: Bool,
        queue: DispatchQueue,
        completion: @escaping (Bool, Result?)->Void
    )

    func async<Parameter, Result>(
        timeout: TimeInterval,
        run method: (Self)->(Parameter, @escaping (Result)->Void)->Void,
        with parameter: Parameter,
        waitAfterTimeout: Bool,
        queue: DispatchQueue,
        completion: @escaping (Bool, Result?)->Void
    )
}

public extension AsyncTimeoutRunnable {
    func async(timeout: TimeInterval,
               run method: (Self)->(@escaping ()->Void)->Void,
               waitAfterTimeout: Bool = false,
               queue: DispatchQueue = DispatchQueue.main,
               completion: @escaping (Bool)->Void )
    {
        var completion: ((Bool)->Void)? = completion
        method(self)() {
            queue.async {
                completion?(true)
                completion = nil
            }
        }
        queue.asyncAfter(deadline: .now() + timeout) {
            completion?(false)
            if !waitAfterTimeout {
                completion = nil
            }
        }
    }

    func async<Result>(
        timeout: TimeInterval,
        run method: (Self)->(@escaping (Result)->Void)->Void,
        waitAfterTimeout: Bool = false,
        queue: DispatchQueue = DispatchQueue.main,
        completion: @escaping (Bool, Result?)->Void
    ) {
        var completion: ((Bool, Result?)->Void)? = completion
        method(self)() { result in
            queue.async {
                completion?(true, result)
                completion = nil
            }
        }
        queue.asyncAfter(deadline: .now() + timeout) {
            completion?(false, nil)
            if !waitAfterTimeout {
                completion = nil
            }
        }
    }

    func async<Parameter, Result>(
        timeout: TimeInterval,
        run method: (Self)->(Parameter, @escaping (Result)->Void)->Void,
        with parameter: Parameter,
        waitAfterTimeout: Bool = false,
        queue: DispatchQueue = DispatchQueue.main,
        completion: @escaping (Bool, Result?)->Void
    ) {
        var completion: ((Bool, Result?)->Void)? = completion
        method(self)(parameter) { result in
            queue.async {
                completion?(true, result)
                completion = nil
            }
        }
        queue.asyncAfter(deadline: .now() + timeout) {
            completion?(false, nil)
            if !waitAfterTimeout {
                completion = nil
            }
        }
    }
}
