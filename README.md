# Test assessment

## Задание
_Переведено с английского языка. Оригинал задания лежит в проекте. Coding exercise.pdf_

### Часть 1
### Описание проблемы
Предоставленный код является неэффективным с точки зрения тестируемости, современности и API-дизайна. Он также некорректен при неправильном использовании. Ваша задача - переписать код так, чтобы он стал корректным, полностью тестируемым, потокобезопасным и легким при повторном использовании. 
Современные концепции, такие как `async/await`, `actor`'ы и `structured concurrency`, должны использоваться вместо устаревших концепций, таких как `NotificationCenter`.

### Требования
Переписанный код должен:

- Гарантировать, что переданная замыкание не будет вызвана, если сеть недоступна.
- Вызвать переданную замыкание, если сеть изначально доступна.
- Вызвать переданную замыкание, если сеть станет доступной в течение заданного времени ожидания.
- Не вызывать замыкание, если сеть станет доступной только после истечения времени ожидания.

### Исходный проблемный код

```swift
import Foundation
import Network

public class NetworkOperationPerformer {

  private let networkMonitor: NetworkMonitor
  private var timer: Timer?
  private var closure: (() -> Void)?

  public init() {
    self.networkMonitor = NetworkMonitor()
  }

  /// Пытается выполнить сетевую операцию, используя переданное замыкание, в течение заданного времени ожидания.
  /// Если сеть недоступна в течение заданного времени ожидания, операция не выполняется.
  public func performNetworkOperation(
    using closure: @escaping () -> Void,
    withinSeconds timeoutDuration: TimeInterval
  ) {
    self.closure = closure

    if self.networkMonitor.hasInternetConnection() {
      closure()
    } else {
      tryPerformingNetworkOperation(withinSeconds: timeoutDuration)
    }
  }

  private func tryPerformingNetworkOperation(withinSeconds timeoutDuration: TimeInterval) {
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(networkStatusDidChange(_:)),
      name: .networkStatusDidChange,
      object: nil
    )

    self.timer = Timer.scheduledTimer(withTimeInterval: timeoutDuration, repeats: false) { _ in
      self.closure = nil
      self.timer = nil
      NotificationCenter.default.removeObserver(self)
    }
  }

  @objc func networkStatusDidChange(_ notification: Notification) {
    guard
      let connected = notification.userInfo?["connected"] as? Bool,
      connected,
      let closure
    else {
      return
    }
    closure()
  }
}

private class NetworkMonitor {
  private let monitor = NWPathMonitor()

  init() {
    startMonitoring()
  }

  private func startMonitoring() {
    monitor.pathUpdateHandler = { _ in
      NotificationCenter.default.post(
        name: .networkStatusDidChange,
        object: nil,
        userInfo: ["connected": self.hasInternetConnection()]
      )
    }
    monitor.start(queue: DispatchQueue(label: "NetworkMonitor"))
  }

  func hasInternetConnection() -> Bool {
    return monitor.currentPath.status == .satisfied
  }
}

private extension Notification.Name {
  static let networkStatusDidChange = Notification.Name("NetworkStatusDidChange")
}
```

## Пример использования кода

```swift
let networkOperationClosure: () async -> SomeType = { // Long-lasting network operation.
    return result
}
let result = await NetworkOperationPerformer().perform(withinSeconds: 3) {
    return await networkOperationClosure()
}
```
## Бонусное задание
- Опишите существующие в оригинальном коде проблемы
- Улучши свой код, таким образом чтобы была возможность отмены задач на выполнение. Подумай, как лучше это организовать
- Добавь документацию на публичный метод в твоем коде

## Часть 2. Приложение на основе SwiftUI

## Описание проблемы
Создайте простое приложение на основе `SwiftUI` с двумя экранами: 
- Экран загрузки и экран отображения изображения
- Используйте `NetworkOperationPerformer` из Части 1 для выполнения операции загрузки изображения.

### На что обратить внимание?
- Правильно управляйте состоянием приложения.
- Разделите логику и интерфейс, чтобы упростить тестирование.
  
### Поведение приложения

- При запуске приложения отображается экран загрузки со спиннингом.
- Если интернет недоступен в течение 0,5 секунд, отображается дополнительный текст, указывающий на отсутствие сети.
- Выполните операцию загрузки изображения, используя метод perform из `NetworkOperationPerformer` с временем ожидания 2 секунды.
- После загрузки изображения или по истечении времени ожидания отображается второй экран:
    - Если изображение было загружено, оно отображается.
    - Если загрузка не удалась, отображается текст, указывающий на ошибку.

