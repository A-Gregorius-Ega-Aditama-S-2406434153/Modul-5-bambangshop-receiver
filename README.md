# BambangShop Receiver App
Tutorial and Example for Advanced Programming 2024 - Faculty of Computer Science, Universitas Indonesia

---

## About this Project
In this repository, we have provided you a REST (REpresentational State Transfer) API project using Rocket web framework.

This project consists of four modules:
1.  `controller`: this module contains handler functions used to receive request and send responses.
    In Model-View-Controller (MVC) pattern, this is the Controller part.
2.  `model`: this module contains structs that serve as data containers.
    In MVC pattern, this is the Model part.
3.  `service`: this module contains structs with business logic methods.
    In MVC pattern, this is also the Model part.
4.  `repository`: this module contains structs that serve as databases.
    You can use methods of the struct to get list of objects, or operating an object (create, read, update, delete).

This repository provides a Rocket web framework skeleton that you can work with.

As this is an Observer Design Pattern tutorial repository, you need to implement a feature: `Notification`.
This feature will receive notifications of creation, promotion, and deletion of a product, when this receiver instance is subscribed to a certain product type.
The notification will be sent using HTTP POST request, so you need to make the receiver endpoint in this project.

## API Documentations

You can download the Postman Collection JSON here: https://ristek.link/AdvProgWeek7Postman

After you download the Postman Collection, you can try the endpoints inside "BambangShop Receiver" folder.

Postman is an installable client that you can use to test web endpoints using HTTP request.
You can also make automated functional testing scripts for REST API projects using this client.
You can install Postman via this website: https://www.postman.com/downloads/

## How to Run in Development Environment
1.  Set up environment variables first by creating `.env` file.
    Here is the example of `.env` file:
    ```bash
    ROCKET_PORT=8001
    APP_INSTANCE_ROOT_URL=http://localhost:${ROCKET_PORT}
    APP_PUBLISHER_ROOT_URL=http://localhost:8000
    APP_INSTANCE_NAME=Safira Sudrajat
    ```
    Here are the details of each environment variable:
    | variable                | type   | description                                                     |
    |-------------------------|--------|-----------------------------------------------------------------|
    | ROCKET_PORT             | string | Port number that will be listened by this receiver instance.    |
    | APP_INSTANCE_ROOT_URL   | string | URL address where this receiver instance can be accessed.       |
    | APP_PUUBLISHER_ROOT_URL | string | URL address where the publisher instance can be accessed.       |
    | APP_INSTANCE_NAME       | string | Name of this receiver instance, will be shown on notifications. |
2.  Use `cargo run` to run this app.
    (You might want to use `cargo check` if you only need to verify your work without running the app.)
3.  To simulate multiple instances of BambangShop Receiver (as the tutorial mandates you to do so),
    you can open new terminal, then edit `ROCKET_PORT` in `.env` file, then execute another `cargo run`.

    For example, if you want to run 3 (three) instances of BambangShop Receiver at port `8001`, `8002`, and `8003`, you can do these steps:
    -   Edit `ROCKET_PORT` in `.env` to `8001`, then execute `cargo run`.
    -   Open new terminal, edit `ROCKET_PORT` in `.env` to `8002`, then execute `cargo run`.
    -   Open another new terminal, edit `ROCKET_PORT` in `.env` to `8003`, then execute `cargo run`.

## Mandatory Checklists (Subscriber)
-   [ ] Clone https://gitlab.com/ichlaffterlalu/bambangshop-receiver to a new repository.
-   **STAGE 1: Implement models and repositories**
    -   [ ] Commit: `Create Notification model struct.`
    -   [ ] Commit: `Create SubscriberRequest model struct.`
    -   [ ] Commit: `Create Notification database and Notification repository struct skeleton.`
    -   [ ] Commit: `Implement add function in Notification repository.`
    -   [ ] Commit: `Implement list_all_as_string function in Notification repository.`
    -   [ ] Write answers of your learning module's "Reflection Subscriber-1" questions in this README.
-   **STAGE 3: Implement services and controllers**
    -   [ ] Commit: `Create Notification service struct skeleton.`
    -   [ ] Commit: `Implement subscribe function in Notification service.`
    -   [ ] Commit: `Implement subscribe function in Notification controller.`
    -   [ ] Commit: `Implement unsubscribe function in Notification service.`
    -   [ ] Commit: `Implement unsubscribe function in Notification controller.`
    -   [ ] Commit: `Implement receive_notification function in Notification service.`
    -   [ ] Commit: `Implement receive function in Notification controller.`
    -   [ ] Commit: `Implement list_messages function in Notification service.`
    -   [ ] Commit: `Implement list function in Notification controller.`
    -   [ ] Write answers of your learning module's "Reflection Subscriber-2" questions in this README.

## Your Reflections
This is the place for you to write reflections:

### Mandatory (Subscriber) Reflections

#### Reflection Subscriber-1
`RwLock<Vec<Notification>>` is appropriate here because the notification repository has two different access patterns: writes happen when a new notification is received, while reads happen when the app lists all stored notifications. Those operations can happen from different request handlers at the same time, so access to the shared `Vec<Notification>` must be synchronized to prevent data races and invalid concurrent mutation. `RwLock` fits this case because it allows many readers to access the notification list concurrently when no writer is active, and only becomes exclusive when a write is needed. Using `Mutex<Vec<Notification>>` would still be correct, but it would be more restrictive because every read would block all other reads, even though listing notifications does not mutate the vector. In a web app where reads can be more frequent than writes, `RwLock` gives better concurrency semantics for this repository.

Rust also does not allow us to mutate an ordinary `static` variable the way Java allows mutation of class-level static state through static methods, because Rust treats unsynchronized global mutable state as unsafe by default. A `static` item must be valid for the entire program lifetime, and unrestricted mutation could create aliasing violations or data races across threads. That is why Rust requires interior mutability and synchronization primitives such as `RwLock`, `Mutex`, or concurrent containers like `DashMap` when shared global state must change at runtime. The `lazy_static` crate helps because values like `Vec<Notification>` or a map-based store cannot always be initialized as compile-time constants, so `lazy_static` performs safe one-time runtime initialization and then exposes them as shared statics behind a synchronization mechanism. In short, Java permits mutable static state as part of its runtime model, while Rust forces that mutability to be explicit, synchronized, and therefore safer.

#### Reflection Subscriber-2
1. Yes, I explored parts outside the step-by-step tutorial, especially `src/lib.rs`, `src/main.rs`, `src/controller/mod.rs`, and the helper script `run_3_instances.ps1`. From `src/lib.rs` I learned that the project centralizes shared configuration and infrastructure in one place through `APP_CONFIG`, `REQWEST_CLIENT`, and `compose_error_response`, which makes the service layer cleaner because subscribe and unsubscribe only need to focus on request flow instead of rebuilding configuration or HTTP clients repeatedly. From `src/main.rs` and `src/controller/mod.rs`, I also learned how Rocket route registration is separated from the handler logic through `route_stage()`, which keeps application startup simple and makes the controller module easier to extend. The `run_3_instances.ps1` file was also useful because it shows the intended way to test the observer setup with several receiver instances at once, which helped me understand the full system behavior beyond just individual endpoint implementation.

2. The Observer pattern makes it easy to plug in more subscribers because the publisher only needs a common subscription contract, not hardcoded knowledge of each receiver. Each receiver instance exposes the same subscribe, unsubscribe, and receive interface, so adding more subscribers is mostly a matter of registering another URL and letting the publisher broadcast notifications to all registered observers. That decoupling is the main advantage here: the sender does not need to change its product logic whenever a new receiver is added. If we spawn more than one instance of the Main app, the system becomes less simple, because then we are no longer just adding observers to one publisher, we are introducing multiple publishers that each maintain their own subscription state. It is still possible to extend, but it would usually require extra coordination such as shared state, service discovery, or a message broker so subscribers know which publisher instance they are attached to and publishers stay consistent with one another.

3. I have not added my own automated tests or extended the Postman collection yet, but both would be useful for this project and for future group work. Automated tests would help verify repository behavior, message formatting, and controller responses without repeatedly testing everything manually. Improving the Postman collection would also be practical because this project depends on interaction between multiple running instances, so a documented sequence of subscribe, publish, receive, list, and unsubscribe requests would make regression testing much faster. For tutorial work it reduces repetitive manual setup, and for a larger group project it would improve handoff, debugging, and shared understanding of how the API is supposed to behave.
