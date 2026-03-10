// Entry point for the modern JS setup in Rails 7
import { Application } from "@hotwired/stimulus"
import { definitionsFromContext } from "@hotwired/stimulus-webpack-helpers"

const application = Application.start()
const context = require.context("./controllers", true, /_controller\.js$/)
application.load(definitionsFromContext(context))
