#!/usr/bin/env julia
export getNumPublishers, getTopic, shutdown

# -------------------------------------------------------------------
# roscpp functions
# -------------------------------------------------------------------

getNumPublishers(subscriber) = @cxx subscriber->getNumPublishers()
getTopic(subscriber) = unsafe_string(@cxx subscriber->getTopic())
shutdown(subscriber) = @cxx subscriber->shutdown()
