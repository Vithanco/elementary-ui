import { init } from "virtual:swift-wasm?js";

await init();

document.getElementById("app")?.setAttribute("data-ready", "true");
