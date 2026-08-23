// onInput stays on View: input events do not fire on SVG elements.
public extension View {
    /// Adds a handler for input events.
    ///
    /// Use this modifier to respond to value changes in input elements.
    /// This event fires when the user types, pastes, or otherwise changes
    /// the content of an input field.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// input()
    ///     .onInput { event in
    ///         if let value = event.targetValue {
    ///             searchQuery = value
    ///         }
    ///     }
    /// ```
    ///
    /// - Parameter handler: A closure that receives an ``InputEvent`` when the input changes.
    /// - Returns: A view that responds to input events.
    consuming func onInput(_ handler: @escaping (InputEvent) -> Void) -> some View<Tag> {
        _onEvent(DOMEventHandlers.Input.self, handler: handler)
    }
}

enum DOMEventHandlers {
    enum Click: _DOMEventHandlerConfig {
        static var name: String = "click"
        typealias Event = MouseEvent
    }

    enum MouseDown: _DOMEventHandlerConfig {
        static var name: String = "mousedown"
        typealias Event = MouseEvent
    }

    enum MouseMove: _DOMEventHandlerConfig {
        static var name: String = "mousemove"
        typealias Event = MouseEvent
    }

    enum MouseUp: _DOMEventHandlerConfig {
        static var name: String = "mouseup"
        typealias Event = MouseEvent
    }

    enum KeyDown: _DOMEventHandlerConfig {
        static var name: String = "keydown"
        typealias Event = KeyboardEvent
    }

    enum Input: _DOMEventHandlerConfig {
        static var name: String = "input"
        typealias Event = InputEvent
    }
}
