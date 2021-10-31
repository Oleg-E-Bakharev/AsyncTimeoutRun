# AsyncTimeoutRun
 Обобщенное решение следующей задачи:
 Имеется функция или метод класса, который выполняется асинхронно и уведомляет о завершении (или возвращает значение) вызовом каллбэка.
 Требуется ограничить по времени выполнение данной функции.

 Если выполнение асинхронной функции(метода) завершается раньше чем таймаут, то каллбэк вызывается штатным образом.
 Если наступает таймаут выполнения, то каллбэк вызывается принудительно с указанием причины вызова по таймауту.
 
 Опционально можно выставить флаг waitAfterTimeout ожидания сверх таймаута. При этом если наступит таймаут до завершения функции, то каллбэк вызовется
 первый раз с указанием вызова по таймауту, а при завершении выполнения функции(метода) каллбэк вызовется второй раз с результатом выполнения функции.
 В противном случае, вызов каллбэка будет один раз с результатом функции.
 По умолчанию waitAfterTimeout - false.
 
Поддериживаются функции и методы класса с одним или без параметра, с или без возвращаемого значения через каллбэк. 

 Опционально можно указать очередь на которой будет осуществляться уведомление о завершении (не выполнение) функции. По умолчанию - main.
 
# Использование
Swift Package Manager: https://github.com/Oleg-E-Bakharev/AsyncTimeoutRun

# Для чего нужно
 Например, сетевой запрос может ожидать ответа интервал времени, при наступлении которого возвращать данные из кэша с
 последующим ожиданием сетевого ответа, обновления кэша и уведомления отправителя запроса.
 
 Другой вариант: На сцене UI композируется отправная точка различных сервисов, доступность которых определяется
 индивидуальным сетевым запросом (возможно в различные микросервисы), пока запросы выполняются рисуются шиммеры.
 Но при наступлении таймаута, шиммеры стираются и мы считаем сервисы недоступными. Но если они впоследствии прогрузятся,
 то мы показываем доступный сервис в сцене.

# Примеры использования
```swift
 // Тестовые функция:
 func foo(completion: @escaping ()->Void) {
     DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
         completion()
     }
 }

 func fooInt(completion: @escaping (Int)->Void) {
     DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
         completion(1)
     }
 }
 
  func fooIntInt(_ parameter: Int, completion: @escaping (Int)->Void) {
     DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
         completion(parameter)
     }
 }

 // Тестовый класс
 final class Test {
     func mee(completion: @escaping ()->Void) {
         DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
             completion()
         }
     }

     func meeInt(completion: @escaping (Int)->Void) {
         DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
             completion(1)
         }
     }
 }
 let test = Test();
 
 async(timeout: 0.5, run: foo) { success in
     print("foo 0.5: \(success)")
 }
 
 async(timeout: 0.5, run: fooInt) { success, result in
      print("fooInt 0.5: \(success), result: \(String(describing: result))")
 }
 
 async(timeout: 0.5, run: fooIntInt, with: 1) { success, result in
      print("fooIntInt 0.5: \(success), result: \(String(describing: result))")
 }
```

# протокол AsyncTimeoutRunnable

 Протокол для ограниченного по времени асинхронного выполнения. Имеется реализация по умолчанию.
 Класс, поддерживающий данный протокол должен быть помечен final

```swift
 // Пример использования
 extension Test: AsyncTimeoutRunnable {}

 test.async(timeout: 0.5, run: Test.mee) { success in
     print("test_17 0.5: \(success)")
 }

 test.async(timeout: 0.5, run: Test.meeInt) { success, result in
     print("test_21 0.5: \(success), result: \(String(describing: result))")
 }
```
