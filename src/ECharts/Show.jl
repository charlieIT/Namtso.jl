function str(dimension::GridDimension)
    dim = "$dimension"
    return dimension isa Int64 ? string(dim, "px") : dim
end

import Base.show
function Base.show(io::IO, mm::MIME"text/html", ec::EChart)

    id = ec.id*randstring(5) #????
    options = Namtso.echart_json(ec.options)

    renderer = JSON.json(ec.renderer)
    
    dom_str = """
        <div id="$(id)" style="height:$(str(ec.height)); width:$(str(ec.width));"></div>
        <script type="text/javascript">
        var myChart = echarts.init(document.getElementById("$(id)"), null, $renderer);
        myChart.setOption($options);
        """
    
    if ec.resize 
        domstr = string(dom_str, "window.onresize = function(){myChart.resize();};") 
    end
    
    dom_str = string(dom_str, "</script>")
    
    public_script="""<script src="$(PUBLIC_SCRIPT)"></script>"""
    println(io, string(public_script, dom_str))
end
