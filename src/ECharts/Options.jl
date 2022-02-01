"""
    Options

Abstract type used for implementing Options type constructors
"""
abstract type Options end

"""
    PlotOptions
"""
mutable struct PlotOptions <: Options
    options::OptionTypes
end

"""
    Options(plot::Plot) :: PlotOptions
"""
function Options(plot::Plot) :: PlotOptions
    
    options = plot.options
    parsed_series = Dict("series"=>[])
    for series in plot.series
        nt = Options(series)

        push!(parsed_series["series"], nt.options)
        
        if !isempty(nt.xaxis)
            options["xAxis"] = [nt.xaxis]
        end
        if !isempty(nt.yaxis)
            options["yAxis"] = [nt.yaxis]
        end
    end
    
    ## legend
    if !isempty(plot.series)
        if !haskey(options, "legend")
            options["legend"] = Dict("data"=>map(x->x.name, plot.series)) 
        end
    end
        
    merge!(options, parsed_series)
    
    return PlotOptions(dict_any(options))
end

"""
    SeriesOptions
"""
mutable struct SeriesOptions <: Options
    xaxis
    yaxis
    options::OptionTypes
end

"""
    Options(series::Series) :: SeriesOptions
"""
function Options(series::Series) :: SeriesOptions
    
    nt = Options(series.data)
    xaxis = nt.xaxis
    yaxis = nt.yaxis
    
    series_options = dict_any(Dict("type"=>series.plot_type, "name"=>series.name))
    if !isempty(nt.data)
       series_options["data"] = nt.data
    end
    merge!(series_options, series.options)
    return SeriesOptions(xaxis, yaxis, dict_any(series_options))
end

function Base.getindex(opts::T, i::String) where T<:Union{PlotOptions, SeriesOptions}
    if Base.hasproperty(opts, Symbol(i))
        return Base.getproperty(opts, Symbol(i))
    else
        return Base.getindex(opts.options, i)
    end
end

"""
    DataOptions
"""
mutable struct DataOptions <: Options
    xaxis
    yaxis
    data::Vector
end

"""
    Options(data::Vector{DataAttrs}) :: DataOptions
"""
function Options(data::Vector{DataAttrs})
    
    xaxis = Dict()
    yaxis = Dict()
    
    if isempty(data)
        return DataOptions(Dict("type"=>"value"), Dict("type"=>"value"), [])
    end
    data_len = length(data[1].data)
    @assert unique(map(x->length(x.data), data))==[data_len] "All Axis should have the same length!"
    
    options_data = []
    axis_len = length(data)
    
    for data_index in 1:data_len
        dot = []
        for axis_index in 1:axis_len
            push!(dot, data[axis_index].data[data_index])
        end
        push!(options_data, dot)
    end
    
    for axis_index in 1:axis_len
        el_type   = eltype(data[axis_index].data)
        
        function str(::Type{T}) where T<:AxisTypes
            if T <: Number
                return "value"
            elseif T <: AbstractString
                return "category"
            elseif T <: Date
                return "time"
            end
        end
        
        if axis_index == 1    
           xaxis["type"] = str(el_type)
        end
        
        if axis_index == 2
            yaxis["type"] = str(el_type)
        end

    end
    return DataOptions(xaxis, yaxis, options_data)
end

# Access xAxis or yAxis entries given its respective Axis type
function Base.getproperty(option::T, axis::Type{A})where {T<:Union{DataOptions, SeriesOptions}, A<:Axis}
    if axis <: xAxis
        return option.xaxis
    elseif axis <: yAxis
        return option.yaxis
    end
end

function Base.Dict(options::Options) :: OptionTypes
    d = convert(OptionTypes, d)
    for (k,v) in d
        if v isa Dict d[k] = dict_any(v) end
    end
    return d
end