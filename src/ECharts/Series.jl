function set_axis!(ec::EChart, options::SeriesOptions)
    
    function append_axis!(ec::EChart, axis::Type{A}, axis_value) where A<:Axis
        
        if length(ec[axis]) == 2
            existing_axis_types = map(x->x["type"], ec[axis])
            @assert axis_value["type"] in existing_axis_types """$(string(axis)) type must be one of the two already existent: $(join(existing_axis_types, ", "))..."""
        end
        
        # no axis defined, or new axis type differs from previously added axis
        if isempty(ec[axis]) ||
            all(x->x["type"] != axis_value["type"], ec[axis])
            
            push!(ec.options[string(axis)], axis_value)
            
            # add [xAxis/yAxis]Index key pointing to axis position, key "xAxisIndex" or "yAxisIndex"
            ec["series"][end][string(string(Axis), "Index")] = length(ec[axis])
        end
    end
    [append_axis!(ec, axis, Base.getproperty(options, axis)) for axis in [xAxis, yAxis]]
end

"""
    series!(ec::EChart, kind::String, args...; kwargs...)

Examples

```julia
series!(mychart, "bar", ["A","B","C"], [1,2,3], name="My Series")
```
"""
function series!(ec::EChart, kind::String, args...; kwargs...)
    data = Vector{DataAttrs}([DataAttrs(arg) for arg in args])
    
    series_options = Dict()
    series_name = string("Series", string(length(ec["series"]) + 1))
    
    for (k,v) in kwargs
       k = string(k)
       if k == "name"
          series_name = v
       else
         series_options[k] = v 
       end
    end
    
    # init empty axis if not present
    if !haskey(ec.options, "xAxis")
        ec.options["xAxis"] = []
    end
    if !haskey(ec.options, "yAxis")
        ec.options["yAxis"] = []
    end
    
    nt = Options(Series(kind, series_name, data, series_options))
    push!(ec["series"], nt.options)
    
    # set axis according to SeriesOptions
    set_axis!(ec, nt)
    
    ## legend
    if length(ec["series"]) > 1
       ec.options["legend"] = Dict("data"=>map(x->x["name"],ec["series"])) 
    end
        
    ec.options = dict_any(ec.options)
    return;
end