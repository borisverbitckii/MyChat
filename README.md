# MyChat

Мессенджер на базе webSockets + сервер для webSockets на golang.
Приложение для демонстрации кодоорганизации и навыков.

## Возможности:
- Авторизироваться/регистрироваться с Google/Facebook/Apple/Email с возможностью подтверждения email
- Искать пользователей для общения
- Оформлять личный аккаунт(изображение/имя)
- Вести переписку
- Менять светлую/темную тему
- Настраивать удаленно цвета/шрифты/тексты с помощью push уведомлений в режиме реального времени

Ссылка на AppStore: 
!!!

#### Скриншоты

<img src="https://is3-ssl.mzstatic.com/image/thumb/PurpleSource112/v4/0f/87/70/0f8770e4-d8b2-96f4-23f3-78c07370d96f/c70ce64d-01f8-4ed2-b132-d2e2aadd828e_IMG_0146.PNG/1284x2778bb.png" width="250"> <img src="https://is2-ssl.mzstatic.com/image/thumb/PurpleSource122/v4/82/e1/8e/82e18ee4-3d3f-ac27-4602-25a3996a4039/f645fb74-b92d-4113-8abb-a1ad8ac44dd6_IMG_0151.PNG/1284x2778bb.png" width="250"> <img src="https://is1-ssl.mzstatic.com/image/thumb/PurpleSource112/v4/02/52/d7/0252d717-bd60-f331-5d08-c8291a228154/a1857f3b-90e8-4463-9847-128f0681aa11_IMG_0153.PNG/1284x2778bb.png" width="250"> <img src="https://is2-ssl.mzstatic.com/image/thumb/PurpleSource122/v4/0e/3a/31/0e3a31af-8aeb-4e3b-08af-cc3015e5cdcf/c95d06c2-6863-414d-8cac-3bc2d8ecbadf_IMG_0149.PNG/1284x2778bb.png" width="250">

#### Видео демонстрация
https://youtu.be/bcHw3vSEdbg

### Особенности:
- Микросервисная архитектура
- Подсчет layout в фоновом потоке(Texture)
- Кастомный activity indicator с анимацией Lottie
- Кеширование скачанных изображений

+ Написанный на golang сервер для обмена сообщениями по webSockets

## Техническая часть
### Архитектура - MVVM + C

### Технологии:
- WebSockets
- Асинхронный расчет layout
- GCD, NSOperation
- NotificationCenter
- Самописанный логер с возможностью вести запись в файл, а также отправкой данных в Firebase Analytics и Firebase Crashlytics

### Паттерны:
- Coordinator
- Factory
- Builder
- Singleton
- Delegate
- Facade

### Библиотеки:
- CoreData
- RxSwift (https://github.com/ReactiveX/RxSwift)
- Texture (https://texturegroup.org)
- Lottie (https://github.com/airbnb/lottie-ios)
- Firebase Auth (https://github.com/firebase/firebase-ios-sdk)
- Firebase RemoteConfig (https://github.com/firebase/firebase-ios-sdk)
- Firebase Analytics (https://github.com/firebase/firebase-ios-sdk)
- Firebase Crashlytics (https://github.com/firebase/firebase-ios-sdk)
- Firebase Storage (https://github.com/firebase/firebase-ios-sdk)
- Firebase Messaging (https://github.com/firebase/firebase-ios-sdk)
- GoogleSignIn (https://github.com/google/GoogleSignIn-iOS)
- FBSDKLoginKit (https://github.com/facebook/facebook-ios-sdk)
- SwiftLint (https://github.com/realm/SwiftLint)
- Periphery (https://github.com/peripheryapp/periphery)

### Зависимости - Cocoa pods
