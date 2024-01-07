function initvals!(grid::Matrix{Vector{Int8}}, coors::Vector{Tuple{Int,Int}}, vals::Vector{Int})
    for (i, coor) in enumerate(coors)
        grid[coor...] = [Int8(vals[i])]
    end
end

function initvals!(grid::Matrix{Vector{Int8}}, locval::Dict{Tuple{Int,Int},Int})
    for (loc, val) in locval
        grid[loc...] = [Int8(val)]
    end
end


function initrels!(grid::Matrix{Vector{Int8}}, greaters::Dict{Tuple{Int,Int},Tuple{Int,Int}})
    ogrid = deepcopy(grid)
    for (k,v) in greaters
        filter!(x -> any(x .> grid[v...]), grid[k...])
        filter!(x -> any(x .< grid[k...]), grid[v...])
    end
    ogrid != grid && initrels!(grid, greaters)
end

function exclusion(sets::Vector{Vector{Int8}})
    uni = union(sets...)
    counts = [count(x -> n ∈ x, sets) for n in uni]
    uni[counts .== 1]
end

function singres(singles::Vector{Int8}, scope::Vector{Vector{Int8}})
    for sc in scope
        found = Bool[]
        for si in singles
            si ∈ sc ? append!(found, true) : append!(found, false)
        end
        any(found) && filter!(x -> x ∈ singles[found], sc)
    end
end

function singularities(grid::Matrix{Vector{Int8}})
    for i in 1:5
        vsingles = exclusion(grid[:,i])
        !isempty(vsingles) && singres(vsingles, grid[:,i])
        hsingles = exclusion(grid[i,:])
        !isempty(hsingles) && singres(hsingles, grid[i,:])
    end    
end    

function resolve!(grid::Matrix{Vector{Int8}})
    for (i, cell) in pairs(IndexCartesian(), grid)
        if length(cell) == 1
            for j in 1:5
                length(grid[i[1],j]) != 1 && filter!(x -> x ∉ cell, grid[i[1],j])
                length(grid[j,i[2]]) != 1 && filter!(x -> x ∉ cell, grid[j,i[2]])
            end
        end
    end
end

function subroutine!(grid, greaters)
    resolve!(grid)
    initrels!(grid, greaters)
    resolve!(grid)
    singularities(grid)
    resolve!(grid)
end

function checksolution(grid, greaters)
    checks = Bool[]
    for i in 1:5
        append!(checks, all([count(x -> n ∈ x, grid[:,i]) for n in 1:5] .== 1))
        append!(checks, all([count(x -> n ∈ x, grid[i,:]) for n in 1:5] .== 1))
        !all(checks) && return false
    end
    for (k,v) in greaters
        append!(checks, grid[k...] > grid[v...])
    end
    all(checks) ? (return true) : (return false)
end

function comp(grid, greaters)
    ogrid = zeros(Int8, (5,5))
    while ogrid != grid
        ogrid = deepcopy(grid)
        subroutine!(grid, greaters)
    end
    checksolution(grid, greaters) && (return grid) #! BP

    tgrid = deepcopy(grid)
    for (n, cell) in pairs(tgrid)
        if length(cell) != 1
            for c in cell
                grid = deepcopy(tgrid)
                grid[n] = [c]
                comp(grid, greaters)
                checksolution(grid, greaters) && (return grid)
            end
        end
    end

    @error "failed to determine the solution"
end


#???????????????????????????????

grid = [Int8.(1:5) for n in 1:5, m in 1:5]
values = Dict(
    (5,3) => 3,
    (1,5) => 4
)
greaters = Dict(
    (1,1) => (2,1),
    (2,2) => (3,2),
    (3,2) => (3,3),
    (1,4) => (2,4),
    (3,4) => (4,4),
    (4,4) => (5,4),
    (5,4) => (5,5),
    (4,5) => (4,4)
)
initvals!(grid, values); grid


#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# resolve!(grid); grid
# initrels!(grid, greaters); grid
# resolve!(grid); grid
# singularities(grid); grid
# resolve!(grid); grid
sol = comp(grid, greaters)

#???????????????????????????????

grid = [Int8.(1:5) for n in 1:5, m in 1:5]
values = Dict(
    (3,5) => 2,
    (5,5) => 1
)
greaters = Dict(
    (3,1) => (2,1),
    (2,1) => (2,2),
    (4,2) => (4,3),
    (4,3) => (5,3),
    (3,3) => (2,3),
    (1,5) => (1,4),
    (1,4) => (2,4)
)
initvals!(grid, values); grid


#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

# comp!(grid, greaters)

#???????????????????????????????

grid = [Int8.(1:5) for n in 1:5, m in 1:5]
values = Dict(
    (1,1) => 3,
    (1,2) => 5
)
greaters = Dict(
    (3,2) => (3,1),
    (2,3) => (2,2),
    (2,3) => (2,4),
    (1,4) => (1,5),
    (2,5) => (3,5),
    (4,4) => (5,4),
    (5,3) => (4,3),
    (4,3) => (3,3),
    (4,3) => (4,2),
    (4,2) => (4,1)
)
initvals!(grid, values); grid


#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

comp!(grid, greaters)