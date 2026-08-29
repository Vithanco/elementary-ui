// Mirrored per namespace like key(_:) in KeyedView.swift. One extension on
// MarkupContent & _Mountable would serve both, but only by making the wrapper and
// its modifier protocol public.
//
// onInput is deliberately absent - input events do not fire on SVG elements.

public extension SVGView {
    // TODO: embedded - must be public, see the matching note on View.
    consuming func _onEvent<Config: _DOMEventHandlerConfig>(
        _ type: Config.Type,
        handler: @escaping (Config.Event) -> Void
    ) -> some SVGView<Tag> {
        DOMEffectView<EventHandlerModifier<Config>, Self>(value: handler, wrapped: self)
    }

    consuming func _onEvent<Config: _DOMEventConfig>(
        _ type: Config.Type,
        handler: @escaping () -> Void
    ) -> some SVGView<Tag> {
        DOMEffectView<EventActionModifier<Config>, Self>(value: handler, wrapped: self)
    }

    /// Adds a handler for click events with event details.
    ///
    /// - Parameter handler: A closure that receives a ``MouseEvent`` when clicked.
    /// - Returns: SVG content that responds to click events.
    consuming func onClick(_ handler: @escaping (MouseEvent) -> Void) -> some SVGView<Tag> {
        _onEvent(DOMEventHandlers.Click.self, handler: handler)
    }

    /// Adds a handler for click events.
    ///
    /// - Parameter handler: A closure invoked when the element is clicked.
    /// - Returns: SVG content that responds to click events.
    consuming func onClick(_ handler: @escaping () -> Void) -> some SVGView<Tag> {
        _onEvent(DOMEventHandlers.Click.self, handler: handler)
    }

    /// Adds a handler for mouse down events.
    ///
    /// - Parameter handler: A closure that receives a ``MouseEvent`` when the mouse button is pressed.
    /// - Returns: SVG content that responds to mouse down events.
    consuming func onMouseDown(_ handler: @escaping (MouseEvent) -> Void) -> some SVGView<Tag> {
        _onEvent(DOMEventHandlers.MouseDown.self, handler: handler)
    }

    /// Adds a handler for mouse move events.
    ///
    /// - Parameter handler: A closure that receives a ``MouseEvent`` as the mouse moves.
    /// - Returns: SVG content that responds to mouse move events.
    consuming func onMouseMove(_ handler: @escaping (MouseEvent) -> Void) -> some SVGView<Tag> {
        _onEvent(DOMEventHandlers.MouseMove.self, handler: handler)
    }

    /// Adds a handler for mouse up events.
    ///
    /// - Parameter handler: A closure that receives a ``MouseEvent`` when the mouse button is released.
    /// - Returns: SVG content that responds to mouse up events.
    consuming func onMouseUp(_ handler: @escaping (MouseEvent) -> Void) -> some SVGView<Tag> {
        _onEvent(DOMEventHandlers.MouseUp.self, handler: handler)
    }

    /// Adds a handler for keyboard key down events.
    ///
    /// The element must be focusable to receive key events - set `tabindex` on it or on
    /// an ancestor.
    ///
    /// - Parameter handler: A closure that receives a ``KeyboardEvent`` when a key is pressed.
    /// - Returns: SVG content that responds to key down events.
    consuming func onKeyDown(_ handler: @escaping (KeyboardEvent) -> Void) -> some SVGView<Tag> {
        _onEvent(DOMEventHandlers.KeyDown.self, handler: handler)
    }
}
