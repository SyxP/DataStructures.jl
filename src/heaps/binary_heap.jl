# This contains code that was formerly a part of Julia. License is MIT: http://julialang.org/license
# Binary Heaps (using Flat Vectors)

# Binary Heap Indexing
heapleft(i::Integer) = 2i
heapright(i::Integer) = 2i + 1
heapparent(i::Integer) = div(i, 2)

# Binary Heap Percolate Down
function percolatedown!(xs::AbstractVector{T}, i::Integer, x::T = xs[i],
                        o::Ordering = Forward, comp = lt, len::Integer = length(xs)) where T
    @inbounds while (l = heapleft(i)) <= len
        r = heapright(i)
        j = r > len || comp(o, xs[l], xs[r]) ? l : r
        if comp(o, xs[j], x)
            xs[i] = xs[j]
            i = j
        else
            break
        end
    end
    xs[i] = x
end

# Binary Heap Percolate Up
function percolateup!(xs::AbstractVector{T}, i::Integer, x::T = xs[i],
                      o::Ordering = Forward, comp = lt, len::Integer = length(xs)) where T
    @inbounds while (j = heapparent(i)) >= 1
        if comp(o, x, xs[j])
            xs[i] = xs[j]
            i = j
        else
            break
        end
    end
    xs[i] = x
end

"""
    heappop!(v, ord::Ordering = Forward, comp = lt)

Given a binary heap-ordered vector, remove and return the lowest ordered element.
For efficiency, this function does not check that the array is indeed heap-ordered.
"""
function heappop!(xs::AbstractVector, ord::Ordering = Forward, comp = lt)
    x = xs[1]
    y = pop!(xs)
    if !isempty(xs)
        percolatedown!(xs, 1, y, ord, comp)
    end
    x
end

"""
    heappush!(v, x, ord::Ordering = Forward, comp = lt)

Given a binary heap-ordered vector, push a new element `x`, preserving the heap property.
For efficiency, this function does not check that the array is indeed heap-ordered.
"""
function heappush!(xs::AbstractVector{T}, x::T, ord::Ordering = Forward, comp = lt) where T
    push!(xs, x)
    len = length(xs)
    percolateup!(xs, len, x, ord, comp, len)
    xs
end

# Turn an arbitrary vector into a binary heap in linear time.
"""
    heapify!(v, ord::Ordering = Forward, comp = lt)

In-place [`heapify`](@ref).
"""
function heapify!(xs::AbstractVector, ord::Ordering = Forward, comp = lt)
    len = length(xs)
    for i in heapparent(len):-1:1
        percolatedown!(xs, i, xs[i], ord, comp, len)
    end
    xs
end

"""
    heapify(v, ord::Ordering = Forward, comp = lt)

Returns a new vector in binary heap order, optionally using the given ordering.
```jldoctest
julia> a = [1,3,4,5,2];

julia> heapify(a)
5-element Array{Int64,1}:
 1
 2
 4
 5
 3

julia> heapify(a, Base.Order.Reverse)
5-element Array{Int64,1}:
 5
 3
 4
 1
 2
```
"""
heapify(xs::AbstractVector, ord::Ordering = Forward, comp = lt) = heapify!(copyto!(similar(xs), xs), ord, comp)

"""
    isheap(v, ord::Ordering=Forward, comp = lt)

Return `true` if an array is heap-ordered according to the given order.

```jldoctest
julia> a = [1,2,3]
3-element Array{Int64,1}:
 1
 2
 3

julia> isheap(a, Base.Order.Forward)
true

julia> isheap(a, Base.Order.Reverse)
false
```
"""
function isheap(xs::AbstractVector, ord::Ordering = Forward, comp = lt)
    for i in 1:div(length(xs), 2)
        if comp(ord, xs[heapleft(i)], xs[i]) ||
           (heapright(i) <= length(xs) && comp(ord, xs[heapright(i)], xs[i]))
            return false
        end
    end
    true
end

struct BinaryHeap{T} <: AbstractHeap{T}
    xs       :: Vector{T}
    ord      :: Ordering
    comp

    BinaryHeap(xs::AbstractVector{T}, ord::Ordering = Forward, comp = lt) where T =
        new{T}(heapify(xs, ord, comp), ord, comp)
end

BinaryHeap{T}(ord::Ordering = Forward, comp = lt) where T =
    BinaryHeap(Vector{T}(), ord, comp)
BinaryMinHeap(xs::AbstractVector{T}) where T = BinaryHeap(xs, Forward)
BinaryMaxHeap(xs::AbstractVector{T}) where T = BinaryHeap(xs, Reverse)
BinaryMinHeap(::Type{T}) where T = BinaryMinHeap(Vector{T}())
BinaryMaxHeap(::Type{T}) where T = BinaryMaxHeap(Vector{T}())

"""
    length(h::BinaryHeap)

Returns the number of elements in `h`. Takes constant time.
"""
@inline length(h::BinaryHeap) = length(h.xs)

"""
    isempty(h::BinaryHeap)

Returns `true` if `h` is empty, `false` otherwise. Takes constant time.
"""
@inline isempty(h::BinaryHeap) = (length(h.xs) == 0)

"""
    push!(h::BinaryHeap, v)

Inserts the element `v` into `h`, maintaining the heap order.
"""
function push!(h::BinaryHeap{T}, v) where T
    heappush!(h.xs, T(v), h.ord, h.comp)
    h
end

"""
    top(h::BinaryHeap)

Returns the element at the top of the heap `h`. Takes constant time.
"""
function top(h::BinaryHeap)
    isempty(h) && error("Accessing element of empty heap.")
    h.xs[1]
end

"""
    pop!(h::BinaryHeap)

Removes and returns the element at the top of the heap `h`.
"""
function pop!(h::BinaryHeap)
    isempty(h) && error("Removing element from empty heap.")
    heappop!(h.xs, h.ord, h.comp)
end
