#!/usr/bin/env julia
export advertise, subscribe

# -------------------------------------------------------------------
# roscpp functions
# -------------------------------------------------------------------

# TODO support TransportHints in subscribe function

# TODO investigate this further
advertise(nodehandle, topic_name::String, topic_type, queue_size::Int) = icxx"$(nodehandle)->advertise<$(topic_type)>($(pointer(topic_name)), $(queue_size));"
# TODO investigate this further
function subscribe(nodehandle, topic_name::String, queue_size::Int, topic_type, callback)
    #icxx"$(nodehandle)->subscribe($(pointer(topic_name)),$(queue_size),&($(test)));"
    icxx"""
        //std::function<void (sensor_msgs::Imu::ConstPtr)> cb = [&](sensor_msgs::Imu::ConstPtr msg) {
        boost::function<void ($(topic_type))> cpp_callback = [&]($(topic_type) msg) {
            $:(callback(icxx"return msg;"));
        };
        return $(nodehandle)->subscribe<$(topic_type)>($(pointer(topic_name)), $(queue_size), cpp_callback);
    """
end

