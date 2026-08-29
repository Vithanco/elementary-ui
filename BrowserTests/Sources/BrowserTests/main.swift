import ElementaryUI

// Every case draws the same 40x40 rect at (20,20) in a 200x200 viewBox, so one user
// unit is one CSS pixel and the runner can compare rendered geometry against what the
// modifier is supposed to mean. TestDOM cannot check this: it records the CSS we emit,
// not what a browser resolves it to, and the SVG transform-origin bug lived entirely in
// that gap.
let cases = div {
    SVG.svg(.id("canvas"), .width(200), .height(200), .viewBox(0, 0, 200, 200)) {
        SVG.rect(.id("plain"), .x(20), .y(20), .width(40), .height(40))

        SVG.rect(.id("rotated"), .x(20), .y(20), .width(40), .height(40))
            .rotationEffect(.degrees(45))

        SVG.rect(.id("rotatedTopLeading"), .x(20), .y(20), .width(40), .height(40))
            .rotationEffect(.degrees(45), anchor: .topLeading)

        SVG.rect(.id("scaled"), .x(20), .y(20), .width(40), .height(40))
            .scaleEffect(2)

        SVG.rect(.id("scaledXY"), .x(20), .y(20), .width(40), .height(40))
            .scaleEffect(x: 2, y: 1)

        SVG.rect(.id("offset"), .x(20), .y(20), .width(40), .height(40))
            .offset(x: 10, y: 5)

        SVG.g(.id("group")) {
            SVG.rect(.x(20), .y(20), .width(40), .height(40))
        }
        .rotationEffect(.degrees(45))
    }
}

Application(cases).mount(in: "#app")
