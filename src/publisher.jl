#!/usr/bin/env julia
export getNumSubscribers, getTopic, publish, shutdown

# -------------------------------------------------------------------
# roscpp functions
# -------------------------------------------------------------------

getNumPublishers(publisher) = @cxx publisher->getNumPublishers()
getTopic(publisher) = unsafe_string(@cxx publisher->getTopic())
# TODO investigate this further
publish(publisher, msg) = @cxx publisher->publish(*(msg));
shutdown(publisher) = @cxx publisher->shutdown()
