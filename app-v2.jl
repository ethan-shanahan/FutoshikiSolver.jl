struct Futoshiki
    dims::Int
    vals::Dict{Tuple{Int,Int},Int8}
    rels::Dict{Tuple{Int,Int},Tuple{Int,Int}}
    grid::Matrix{Vector{Int8}}
    function Futoshiki(dims,vals,rels)
        grid = [Int8.(1:dims) for _ in 1:dims, _ in 1:dims]
        for (loc, val) in vals
            grid[loc...] = [val]
        end
        new(dims,vals,rels,grid)
    end
end

function resolve!(f::Futoshiki)
    ogrid = zeros(Int8, (f.dims,f.dims))
    while ogrid != f.grid
        ogrid = deepcopy(f.grid)
        sweep!(f)
        inequalities!(f)
    end
end

function sweep!(f::Futoshiki)
    ogrid = deepcopy(f.grid)
    for (i,cell) in pairs(f.grid)
        length(cell) == 1 || continue
        filter!.(x -> x ∉ cell, f.grid[i[1],length.(f.grid[i[1],:]) .!= 1])
        filter!.(x -> x ∉ cell, f.grid[length.(f.grid[:,i[2]]) .!= 1,i[2]])
    end
    ogrid != f.grid && sweep!(f)
end

function inequalities!(f::Futoshiki)
    ogrid = deepcopy(f.grid)
    for (k,v) in f.rels
        filter!(x -> any(x .> f.grid[v...]), f.grid[k...])
        filter!(x -> any(x .< f.grid[k...]), f.grid[v...])
    end
    ogrid != f.grid && inequalities!(f)
end



function pluralities(f::Futoshiki)
    vcounts = [[count(x -> n ∈ x, f.grid[:,m]) for n in 1:f.dims] for m in 1:f.dims]
    # hcounts = [[count(x -> n ∈ x, f.grid[i,:]) for n in 1:f.dims] for m in 1:f.dims]
    for n in 1:f.dims, m in 1:f.dims
        if count(x -> x == n, vcounts[m]) == n #! excludes three pairs, even if one pair is effective
            search = findall(x -> x == n, vcounts[m])
            findings = [findall(x -> s ∈ x, f.grid[:,m]) for s in search]
            conclusion = allequal(findings)
            conclusion && filter!.(x -> x ∉ f.grid[findings[1][1],m], f.grid[length.(f.grid[:,m]) .!= 1,m]) #! wrong result
        end
    end
end

futo = Futoshiki(
    5,
    Dict(
        (5,3) => 3,
        (1,5) => 4
    ),
    Dict(
        (1,1) => (2,1),
        (2,2) => (3,2),
        (3,2) => (3,3),
        (1,4) => (2,4),
        (3,4) => (4,4),
        (4,4) => (5,4),
        (5,4) => (5,5),
        (4,5) => (4,4)
    )
)
resolve!(futo); futo.grid
futo.grid[1,5] = [4,5]
futo.grid[5,5] = [1,5]
pluralities(futo)


# @benchmark filter!.(x -> x ∉ [4], fg[1,length.(fg[1,:]) .!= 1]) setup=(fg = deepcopy(futo.grid)) samples = 1000000 evals = 1 seconds = 10
# @benchmark deleteat!.(fg[1,:], [length(fg[1,n]) == 1 ? falses(length(fg[1,n])) : fg[1,n] .== 4 for n in 1:5]) setup=(fg = deepcopy(futo.grid)) samples = 1000000 evals = 1 seconds = 10
# fg = deepcopy(futo.grid)

# Base.propertynames(::Futoshiki) = (:dims, :vals, :rels, :grid)
# function Base.getproperty(s::S, p::Symbol)
#     if p == :grid
#         return 3 * getfield(s, :dims)
#     end
#     return getfield(s, p)
# end