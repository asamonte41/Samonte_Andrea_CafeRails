// Load all Stimulus controllers from the controllers folder
import { application } from "./application"
import { definitionsFromContext } from "@hotwired/stimulus-loading"

const context = require.context(".", true, /\.js$/)
application.load(definitionsFromContext(context))
