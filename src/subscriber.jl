#!/usr/bin/env julia
export getNumPublishers, getTopic

# -------------------------------------------------------------------
# roscpp functions
# -------------------------------------------------------------------

getNumPublishers(subscriber) = @cxx subscriber->getNumPublishers()
getTopic(subscriber) = unsafe_string(@cxx subscriber->getTopic())
