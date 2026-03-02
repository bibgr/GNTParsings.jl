"""
`struct parsing <: GNTParsings`\n

The `GNTParsings` module parsing internal representation.
"""
struct parsing <: GNTParsings
    # Part of speech
    # ("A-", "C-", "D-", "I-", "N-", "P-", "RA", "RD", "RI", "RP", "RR", "V-", "X-")
    pos::String
    # Person
    # ('-', '1', '2', '3')
    per::Char
    # Tense
    # ('-', 'A', 'F', 'I', 'P', 'X', 'Y')
    ten::Char
    # Voice
    # ('-', 'A', 'M', 'P')
    voi::Char
    # Mood
    # ('-', 'D', 'I', 'N', 'O', 'P', 'S')
    moo::Char
    # Case
    # ('-', 'A', 'D', 'G', 'N', 'V')
    cas::Char
    # Number
    # ('-', 'P', 'S')
    num::Char
    # Gender
    # ('-', 'F', 'M', 'N')
    gen::Char
    # Degree
    # ('-', 'C', 'S')
    deg::Char
    # Internal (validating) constructor
    function parsing(pos::S, per::C, ten::C,
                     voi::C, moo::C, cas::C,
                     num::C, gen::C, deg::C) where {S<:AbstractString, C<:AbstractChar}
        @assert(
            pos in ("A-", "C-", "D-", "I-", "N-", "P-","V-", "X-") ||
            pos in ("RA", "RD", "RI", "RP", "RR")
        )
        @assert per in "-123"
        @assert ten in "-AFIPXY"
        @assert voi in "-AMP"
        @assert moo in "-DINOPS"
        @assert cas in "-ADGNV"
        @assert num in "-PS"
        @assert gen in "-FMN"
        @assert deg in "-CS"
        return new(pos, per, ten, voi, moo, cas, num, gen, deg)
    end
end

export parsing

# External convenience constructors - two-arg splatting version
parsing(pos::S, par::S) where S<:AbstractString = parsing(pos, par...)

# External convenience constructors - one-arg, space-delimited version
parsing(all::S) where S<:AbstractString = begin
    spl = split(all, limit=2)
    parsing(spl[1], join(split(spl[2]), ""))
end

