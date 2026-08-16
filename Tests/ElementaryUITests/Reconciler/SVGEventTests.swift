import ElementaryUI
import Reactivity
import Testing

/// The SVG counterparts of the event tests in `DOMMountingTests`.
struct SVGEventTests {
    let svgNamespaceURI = "http://www.w3.org/2000/svg"

    private enum TestAction: _DOMEventConfig {
        static let name = "action-a"
    }

    @Test
    func setsEventListenersOnNestedSVGElements() {
        let dom = TestDOM()
        dom.mount {
            SVG.svg {
                SVG.rect(.x(1), .y(2), .width(10), .height(11)).onClick { _ in }
            }
        }
        dom.runNextFrame()

        #expect(dom.ops.contains(.addListener(node: "<rect>", event: "click")))
        #expect(dom.eventSinkKinds == [.event])
    }

    @Test
    func setsNoArgumentEventListenersOnNestedSVGElements() {
        let dom = TestDOM()
        dom.mount {
            SVG.svg {
                SVG.circle(.cx(4), .cy(5), .r(6)).onClick {}
            }
        }
        dom.runNextFrame()

        #expect(dom.ops.contains(.addListener(node: "<circle>", event: "click")))
        #expect(dom.eventSinkKinds == [.action])
    }

    @Test
    func setsTheRemainingMouseAndKeyboardListeners() {
        let dom = TestDOM()
        dom.mount {
            SVG.svg {
                SVG.rect(.x(0), .y(0), .width(1), .height(1))
                    .onMouseDown { _ in }
                    .onMouseMove { _ in }
                    .onMouseUp { _ in }
                    .onKeyDown { _ in }
            }
        }
        dom.runNextFrame()

        #expect(dom.ops.contains(.addListener(node: "<rect>", event: "mousedown")))
        #expect(dom.ops.contains(.addListener(node: "<rect>", event: "mousemove")))
        #expect(dom.ops.contains(.addListener(node: "<rect>", event: "mouseup")))
        #expect(dom.ops.contains(.addListener(node: "<rect>", event: "keydown")))
    }

    @Test
    func theModifierLeavesTheWrappedElementUntouched() {
        let dom = TestDOM()
        dom.mount {
            SVG.svg {
                SVG.rect(.x(1), .y(2), .width(10), .height(11), .fill("red")).onClick { _ in }
            }
        }
        dom.runNextFrame()

        #expect(
            dom.ops == [
                .createElementNS(namespaceURI: svgNamespaceURI, element: "svg"),
                .createElementNS(namespaceURI: svgNamespaceURI, element: "rect"),
                .setAttr(node: "<rect>", name: "x", value: "1"),
                .setAttr(node: "<rect>", name: "y", value: "2"),
                .setAttr(node: "<rect>", name: "width", value: "10"),
                .setAttr(node: "<rect>", name: "height", value: "11"),
                .setAttr(node: "<rect>", name: "fill", value: "red"),
                .addListener(node: "<rect>", event: "click"),
                .addChild(parent: "<svg>", child: "<rect>"),
                .addChild(parent: "<>", child: "<svg>"),
            ]
        )
    }

    @Test
    func stacksModifiersOnOneSVGElement() {
        let dom = TestDOM()
        dom.mount {
            SVG.svg {
                SVG.g {
                    SVG.rect(.x(0), .y(0), .width(1), .height(1))
                        .onClick { _ in }
                        ._onEvent(TestAction.self) {}
                }
            }
        }
        dom.runNextFrame()

        #expect(dom.ops.contains(.addListener(node: "<rect>", event: "click")))
        #expect(dom.ops.contains(.addListener(node: "<rect>", event: "action-a")))
    }

    @Test
    func aRecursiveSVGViewCanCarryAHandlerPerElement() {
        let dom = TestDOM()
        dom.mount {
            SVG.svg {
                ShapeTreeView(node: .group([.box(x: 0), .group([.box(x: 1)])]))
            }
        }
        dom.runNextFrame()

        let listeners = dom.ops.filter { if case .addListener(_, "click") = $0 { true } else { false } }
        #expect(listeners.count == 2)
    }
}

private indirect enum ShapeTree: Sendable {
    case group([ShapeTree])
    case box(x: Double)
}

@View
private struct ShapeTreeView: SVGView {
    let node: ShapeTree

    var body: some SVGView {
        switch node {
        case let .group(children):
            SVG.g {
                for child in children {
                    ShapeTreeView(node: child)
                }
            }
        case let .box(x):
            SVG.rect(.x(.init(x)), .y(0), .width(1), .height(1)).onClick { _ in }
        }
    }
}
