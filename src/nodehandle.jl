#!/usr/bin/env julia
export advertise, advertiseService, subscribe, shutdown

# -------------------------------------------------------------------
# roscpp functions
# -------------------------------------------------------------------

# TODO support TransportHints in subscribe function
# TODO creating more than one subscriber of service advertiser, kills the first!

# TODO investigate this further
advertise(nodehandle, topic_name::String, topic_type, queue_size::Int) = icxx"$(nodehandle)->advertise<$(topic_type)>($(pointer(topic_name)), $(queue_size));"

function advertiseService(nodehandle, topic_name::String, topic_type, callback)
    icxx"""
        boost::function<bool ($(service_types[topic_type][1])&, $(service_types[topic_type][2])&)> cpp_srv_callback = [&]($(service_types[topic_type][1]) &req, $(service_types[topic_type][2]) &res) {
            return $:(callback(icxx"return &req;", icxx"return &res;")::Bool);
        };
        return $(nodehandle)->advertiseService($(pointer(topic_name)), cpp_srv_callback);
    """
end

# TODO investigate this further
function subscribe(nodehandle, topic_name::String, queue_size::Int, topic_type, callback)
    icxx"""
        boost::function<void ($(topic_type))> cpp_callback = [&]($(topic_type) msg) {
            $:(callback(icxx"return msg;")::Nothing);
        };
        return $(nodehandle)->subscribe<$(topic_type)>($(pointer(topic_name)), $(queue_size), cpp_callback);
    """
end

# NodeHandle, Publisher, Subscriber, ServiceServer
shutdown(n) = @cxx n->shutdown()

