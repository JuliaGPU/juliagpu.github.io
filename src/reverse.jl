# reversing

# the kernel works by treating the array as 1d. after reversing by dimension x an element at
# pos [i1, i2, i3, ... , i{x},            ..., i{n}] will be at
# pos [i1, i2, i3, ... , d{x} - i{x} + 1, ..., i{n}] where d{x} is the size of dimension x

# out-of-place version, copying a single value per thread from input to output
function _reverse_nd(data::AnyCuArray{T, N}, data_out::AnyCuArray{T, N}; dims=1:ndims(data)) where {T, N}
    rev_dims = ntuple((d)-> d in dims && size(data, d) > 1, N)
    first_dim = findfirst(rev_dims)
    if isnothing(first_dim)
        # no reverse operation needed at all in this case.
        return
    end
    ref = size(data) .+ 1
    # converts an ND-index in the data array to the linear index
    lin_idx = LinearIndices(data)
    # converts a linear index in a reduced array to an ND-index, but using the reduced size
    nd_idx = CartesianIndices(data)

    function kernel(data::AbstractArray{T, N}) where {T, N}
        offset_in = blockDim().x * (blockIdx().x - 1i32)
        index_in = offset_in + threadIdx().x

        if index_in <= length(data)
            idx = Tuple(nd_idx[index_in])
            idx = ifelse.(rev_dims, ref .- idx, idx)
            index_out =  lin_idx[idx...]
            @inbounds begin
                data_out[index_out] = data[index_in]
            end
        end

        return
    end

    nthreads = 256
    nblocks = cld(length(data), nthreads)

    @cuda threads=nthreads blocks=nblocks kernel(data)
end

# in-place version for multiple dimensions
function _reverse_nd!(data::AnyCuArray{T, N}; dims=1:ndims(data)) where {T, N}
    rev_dims = ntuple((d)-> d in dims && size(data, d) > 1, N)
    half_dim = findlast(rev_dims)
    if isnothing(half_dim)
        # no reverse operation needed at all in this case.
        return
    end
    ref = size(data) .+ 1
    # converts an ND-index in the data array to the linear index
    lin_idx = LinearIndices(data)
    reduced_size = ntuple((d)->ifelse(d==half_dim, cld(size(data,d),2), size(data,d)), N)
    reduced_length = prod(reduced_size)
    # converts a linear index in a reduced array to an ND-index, but using the reduced size
    nd_idx = CartesianIndices(reduced_size)

    function kernel(data::AbstractArray{T, N}) where {T, N}
        offset_in = blockDim().x * (blockIdx().x - 1i32)

        index_in = offset_in + threadIdx().x

        if index_in <= reduced_length 
            idx = Tuple(nd_idx[index_in])
            index_in = lin_idx[idx...]
            idx = ifelse.(rev_dims, ref .- idx, idx)
            index_out =  lin_idx[idx...] 

            if index_in < index_out
                @inbounds begin
                    temp = data[index_out]
                    data[index_out] = data[index_in]
                    data[index_in] = temp
                end
            end
        end

        return
    end

    # NOTE: we launch slightly more than half the number of elements in the array as threads.
    # The last non-singleton dimension along which to revert is used to define how the array is split.
    # Only the middle row in case of an odd array dimension could cause trouble, but this is prevented by
    # ignoring the threads that cross the mid-point

    nthreads = 256
    nblocks = cld(prod(reduced_size), nthreads)

    @cuda threads=nthreads blocks=nblocks kernel(data)
end


# n-dimensional API

function Base.reverse!(data::AnyCuArray{T, N}; dims=:) where {T, N}
    if isa(dims, Colon)
        dims = 1:ndims(data)
    end
    if !applicable(iterate, dims)
        throw(ArgumentError("dimension $dims is not an iterable"))
    end
    if !all(1 .≤ dims .≤ ndims(data))
        throw(ArgumentError("dimension $dims is not 1 ≤ $dims ≤ $(ndims(data))"))
    end

    _reverse_nd!(data; dims=dims);

    return data
end

# out-of-place
function Base.reverse(input::AnyCuArray{T, N}; dims=:) where {T, N}
    if isa(dims, Colon)
        dims = 1:ndims(input)
    end
    if !applicable(iterate, dims)
        throw(ArgumentError("dimension $dims is not an iterable"))
    end
    if !all(1 .≤ dims .≤ ndims(input))
        throw(ArgumentError("dimension $dims is not 1 ≤ $dims ≤ $(ndims(input))"))
    end

    output = similar(input)
    _reverse_nd(input, output; dims=dims)

    return output
end


# 1-dimensional API

# in-place
Base.@propagate_inbounds function Base.reverse!(data::AnyCuVector{T}, start::Integer,
                                                stop::Integer=length(data)) where {T}
    _reverse(view(data, start:stop))
    return data
end

Base.reverse(data::AnyCuVector{T}) where {T} = @inbounds reverse(data, 1, length(data))

# out-of-place
Base.@propagate_inbounds function Base.reverse(input::AnyCuVector{T}, start::Integer,
                                               stop::Integer=length(input)) where {T}
    output = similar(input)

    start > 1 && copyto!(output, 1, input, 1, start-1)
    _reverse(view(input, start:stop), view(output, start:stop))
    stop < length(input) && copyto!(output, stop+1, input, stop+1)

    return output
end

Base.reverse!(data::AnyCuVector{T}) where {T} = @inbounds reverse!(data, 1, length(data))
