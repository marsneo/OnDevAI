include("Setting.jl")
using Distributions
using HDF5

function to_watt(x)
    return 10^(x / 10)
end

function to_dBW(x)
    return 10*log10(x)
end

### Exponential distribution of channel_gain
function exp_gain(dist)
    g0 = -40 #dB
    g0_W = to_watt(g0)
    d0 = 1 #1 m
    mean = g0_W*((d0/dist)^4)
    gain_h = rand(Exponential(mean))

    return gain_h #in Watts
end

function noise_per_gain(gain)  #N0/h
    return N0/gain
end

# def shanon_capacity():
#     return

function mobile_gen()
    if(REUSED_TRAFFIC)
        return simple_read_data()
    else
        dist_list = rand(Dist_min:Dist_max,NumbDevs)
        gain_list = zeros(NumbDevs)
        ratios    = zeros(NumbDevs)

        for n=1:NumbDevs
            gain_list[n] = exp_gain(dist_list[n])
            ratios[n]    = noise_per_gain(gain_list[n])
        end

        D_n       = rand(D_min:D_max,NumbDevs)

        simple_save_data(dist_list, gain_list, ratios, D_n)

        return dist_list, gain_list, ratios, D_n
    end
end

function simple_save_data(dist_list, gain_list, ratios, D_n)
    h5open("data.h5", "w") do file
        write(file,"dist_list", dist_list)
        write(file,"gain_list", gain_list)
        write(file,"ratios", ratios)
        write(file,"D_n", D_n)
    end
end

function simple_read_data()
    h5open("data.h5", "r") do file
        dist_list =read(file,"dist_list")
        gain_list =read(file,"gain_list")
        ratios =read(file,"ratios")
        D_n = read(file,"D_n")
        return dist_list, gain_list, ratios, D_n
    end
end

mobile_gen()
