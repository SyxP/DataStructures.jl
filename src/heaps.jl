# Various heap implementations

import Base.Order: Forward, Reverse, Ordering, lt,
                   ForwardOrdering, ReverseOrdering
import Base: length, pop!, push!, isempty

###########################################################
#
#   Heap interface specification
#
#   Each heap is associated with a handle type (H), and
#   a value type v.
#
#   Here, the value type must be comparable, and a handle
#   is an object through which one can refer to a specific
#   node of the heap and thus update its value.
#
#   Each heap type must implement all of the following
#   functions. Here, let h be a heap, i be a handle, and
#   v be a value.
#
#   - length(h)           returns the number of elements
#
#   - isempty(h)          returns whether the heap is
#                         empty
#
#   - push!(h, v)         add a value to the heap
#
#   - sizehint!(h)        set size hint to a heap
#
#   - top(h)              return the top value of a heap
#
#   - pop!(h)             removes the top value, and
#                         returns it
#
#  For mutable heaps, it should also support
#
#   - push!(h, v)         adds a value to the heap and
#                         returns a handle to v
#
#   - update!(h, i, v)    updates the value of an element
#                         (referred to by the handle i)
#
#   - top_with_handle(h)  return the top value of a heap
#                         and its handle
#
#
###########################################################

# HT: handle type
# VT: value type

abstract type AbstractHeap{VT} end
abstract type AbstractMutableHeap{VT,HT} <: AbstractHeap{VT} end
abstract type AbstractMinMaxHeap{VT} <: AbstractHeap{VT} end

# heap implementations

include("heaps/binary_heap.jl")
# include("heaps/mutable_binary_heap.jl")
include("heaps/minmax_heap.jl")

# generic functions

function extract_all!(h::AbstractHeap{VT}) where VT
    n = length(h)
    r = Vector{VT}(undef, n)
    for i = 1 : n
        r[i] = pop!(h)
    end
    r
end

function extract_all_rev!(h::AbstractHeap{VT}) where VT
    n = length(h)
    r = Vector{VT}(undef, n)
    for i = 1 : n
        r[n + 1 - i] = pop!(h)
    end
    r
end

# Array functions using Binary Heap

function nextreme(n::Int, arr::AbstractVector{T}, ord::Ordering = Forward, comp = lt) where T
    n <= 0 && return T[] # sort(arr)[1:n] returns [] for n <= 0
    n >= length(arr) && return sort(arr, order = ord, lt = (x,y)->comp(ord,y,x))

    buffer = BinaryHeap(T[], ord, comp)
    for i in 1:n
        @inbounds push!(buffer, arr[i])
    end

    for i in n+1:length(arr)
        @inbounds next = arr[i]
        if comp(ord, top(buffer), next)
            # This could use a pushpop method
            pop!(buffer)
            push!(buffer, next)
        end
    end
    return extract_all_rev!(buffer)
end

"""
    nlargest(n, arr)

Return the `n` largest elements of the array `arr`.
Equivalent to `sort(arr, lt = >)[1:min(n, end)]`
"""
nlargest(n::Int, arr::AbstractVector{T}) where T = nextreme(n, arr, Forward)


"""
    nsmallest(n, arr)

Return the `n` smallest elements of the array `arr`.
Equivalent to `sort(arr, lt = <)[1:min(n, end)]`
"""
nsmallest(n::Int, arr::AbstractVector{T}) where T = nextreme(n, arr, Reverse)
