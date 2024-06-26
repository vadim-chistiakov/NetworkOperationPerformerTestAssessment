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

# Решение

## Существующие проблемы
- Исходный код полагался на `NotificationCenter` для отслеживания изменений состояния сети, что может быть ненадежным и не является потокобезопасным. Кроме того, он устарел. Современный код на `Swift` должен использовать `async/await`, `actor`ы и `structured concurrency`.
- Использование `NotificationCenter` и `Timer` делает исходный код трудным для тестирования в контролируемых условиях. Для получения дополнительной информации, как тестировать такой код прочитайте [статью](https://boosty.to/chistiakov/posts/b6a2e779-57a8-4156-9b46-22b099ff43eb?share=post_link) , она поможет глубже понять проблему.
- Отсутствие внедрения зависимостей (dependency injection) в проекте может привести к ряду проблем, связанных с поддерживаемостью, тестируемостью и масштабируемостью.
- Исходный код может приводить к потенциальным состояниям гонок (race condition) и неопределенному поведению.
- Таймеры часто захватывают `self` сильно в своих замыканиях, что приводит к retain cycle. Чтобы этого избежать, используйте `[weak self]`.
- Использование протоколов для сервисов в swift настоятельно рекомендуется для внедрения зависимостей и тестирования. Протоколы помогают определить четкие контракты для ваших сервисов, что позволяет разъединять компоненты, легко заменять реализации и упрощать модульное тестирование с использованием моков и стабов.

## Документация для публичного метода

```swift
protocol NetworkOperationPerformer {
    /// Выполняет заданную асинхронную операцию и гарантирует, что она завершится в пределах указанного времени.
    /// Этот метод запускает предоставленную сетевую операцию в новой задаче, позволяя при необходимости отменить ее.
    /// Если операция не успевает выполниться за отведенный интервал времени, то метод бросает ошибку timeout
    ///
    /// - Параметры:
    ///   - closure: Асинхронное замыкание, представляющее сетевую операцию, которую необходимо выполнить.
    ///   - withinSeconds: `TimeInterval`, указывающий лимит времени в секундах, в течение которого операция должна завершиться.
    func performNetworkOperation(
        using closure: @escaping @Sendable () async -> Void,
        withinSeconds timeoutDuration: TimeInterval
    ) async throws
}
```

Полную реализацию можно посмотреть в проекте. 

**P.S. Пулл реквесты с замечаниями, исправлениями, добавлениями красивого UI слоя - приветствуются!**
















