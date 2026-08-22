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

public enum DOMEventHandlers {
    public enum Click: _DOMEventHandlerConfig {
        public static var name: String = "click"
        public typealias Event = MouseEvent
    }

    public enum MouseDown: _DOMEventHandlerConfig {
        public static var name: String = "mousedown"
        public typealias Event = MouseEvent
    }

    public enum MouseMove: _DOMEventHandlerConfig {
        public static var name: String = "mousemove"
        public typealias Event = MouseEvent
    }

    public enum MouseUp: _DOMEventHandlerConfig {
        public static var name: String = "mouseup"
        public typealias Event = MouseEvent
    }

    public enum KeyDown: _DOMEventHandlerConfig {
        public static var name: String = "keydown"
        public typealias Event = KeyboardEvent
    }

    public enum Input: _DOMEventHandlerConfig {
        public static var name: String = "input"
        public typealias Event = InputEvent
    }
}
