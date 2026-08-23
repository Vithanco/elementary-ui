// The wrapper is named so its conditional conformances pick the namespace; the
// modifier stays opaque so the concrete modifiers, and their value types, need not
// be public.

public extension MarkupContent where Self: _Mountable {
    // TODO: embedded - for whatever reason this must be public or the embedded compiler freaks out. investigate why, check if still an issue in 6.3
    consuming func _onEvent<Config: _DOMEventHandlerConfig>(
        _: Config.Type,
        handler: @escaping (Config.Event) -> Void
    ) -> _DOMEffectView<some _DOMElementModifier, Self> {
        _DOMEffectView<EventHandlerModifier<Config>, Self>(value: handler, wrapped: self)
    }

    // TODO: embedded - for whatever reason this must be public or the embedded compiler freaks out. investigate why, check if still an issue in 6.3
    consuming func _onEvent<Config: _DOMEventConfig>(
        _: Config.Type,
        handler: @escaping () -> Void
    ) -> _DOMEffectView<some _DOMElementModifier, Self> {
        _DOMEffectView<EventActionModifier<Config>, Self>(value: handler, wrapped: self)
    }

    /// Adds a handler for click events with event details.
    ///
    /// Use this modifier to respond to click events and access information about
    /// the click, such as position, modifier keys, and button.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// button { "Click me" }
    ///     .onClick { event in
    ///         print("Clicked at (\(event.clientX), \(event.clientY))")
    ///     }
    /// ```
    ///
    /// - Parameter handler: A closure that receives a ``MouseEvent`` when clicked.
    /// - Returns: Content that responds to click events.
    consuming func onClick(
        _ handler: @escaping (MouseEvent) -> Void
    ) -> _DOMEffectView<some _DOMElementModifier, Self> {
        _onEvent(DOMEventHandlers.Click.self, handler: handler)
    }

    /// Adds a handler for click events.
    ///
    /// Use this modifier to respond to click events without needing event details.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// button { "Increment" }
    ///     .onClick {
    ///         count += 1
    ///     }
    /// ```
    ///
    /// - Parameter handler: A closure to execute when clicked.
    /// - Returns: Content that responds to click events.
    consuming func onClick(
        _ handler: @escaping () -> Void
    ) -> _DOMEffectView<some _DOMElementModifier, Self> {
        _onEvent(DOMEventHandlers.Click.self, handler: handler)
    }

    /// Adds a handler for mouse down events.
    ///
    /// Use this modifier to respond when the user presses a mouse button down
    /// on the content, before releasing it.
    ///
    /// ```swift
    /// div { "Press me" }
    ///     .onMouseDown { event in
    ///         startDragging(at: event.clientX, event.clientY)
    ///     }
    /// ```
    ///
    /// - Parameter handler: A closure that receives a ``MouseEvent`` when the mouse button is pressed.
    /// - Returns: Content that responds to mouse down events.
    consuming func onMouseDown(
        _ handler: @escaping (MouseEvent) -> Void
    ) -> _DOMEffectView<some _DOMElementModifier, Self> {
        _onEvent(DOMEventHandlers.MouseDown.self, handler: handler)
    }

    /// Adds a handler for mouse move events.
    ///
    /// Use this modifier to track mouse movement over the content.
    ///
    /// ```swift
    /// div { "Hover zone" }
    ///     .onMouseMove { event in
    ///         mousePosition = (event.clientX, event.clientY)
    ///     }
    /// ```
    ///
    /// - Parameter handler: A closure that receives a ``MouseEvent`` as the mouse moves.
    /// - Returns: Content that responds to mouse move events.
    consuming func onMouseMove(
        _ handler: @escaping (MouseEvent) -> Void
    ) -> _DOMEffectView<some _DOMElementModifier, Self> {
        _onEvent(DOMEventHandlers.MouseMove.self, handler: handler)
    }

    /// Adds a handler for mouse up events.
    ///
    /// Use this modifier to respond when the user releases a mouse button
    /// after pressing it down.
    ///
    /// ```swift
    /// div { "Release me" }
    ///     .onMouseUp { event in
    ///         finishDragging()
    ///     }
    /// ```
    ///
    /// - Parameter handler: A closure that receives a ``MouseEvent`` when the mouse button is released.
    /// - Returns: Content that responds to mouse up events.
    consuming func onMouseUp(
        _ handler: @escaping (MouseEvent) -> Void
    ) -> _DOMEffectView<some _DOMElementModifier, Self> {
        _onEvent(DOMEventHandlers.MouseUp.self, handler: handler)
    }

    /// Adds a handler for keyboard key down events.
    ///
    /// Use this modifier to respond to keyboard input when a key is pressed.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// div { "Press a key" }
    ///     .onKeyDown { event in
    ///         if event.key == "Enter" {
    ///             submitForm()
    ///         }
    ///     }
    /// ```
    ///
    /// - Parameter handler: A closure that receives a ``KeyboardEvent`` when a key is pressed.
    /// - Returns: Content that responds to key down events.
    consuming func onKeyDown(
        _ handler: @escaping (KeyboardEvent) -> Void
    ) -> _DOMEffectView<some _DOMElementModifier, Self> {
        _onEvent(DOMEventHandlers.KeyDown.self, handler: handler)
    }
}
