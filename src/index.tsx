import React from "react";
import { render } from "ink";
import { App } from "./ui/App";
import { setupGlobalErrorHandlers } from "./runtime-errors";

setupGlobalErrorHandlers();

const strategyArg = process.argv[2];
const strategy = strategyArg === "1" ? "trend" : strategyArg === "2" ? "maker" : strategyArg === "3" ? "offset-maker" : null;

render(<App strategy={strategy} />);